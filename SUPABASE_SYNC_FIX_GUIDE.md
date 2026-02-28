# Supabase Sync Error Fix Guide

## Problem

**Error**: `Could not find the 'acquiredStrengths' column of 'user_profiles' in the schema cache`

**Root Cause**: Supabase database table `user_profiles` is missing the `acquiredStrengths` column (and possibly other columns) that exist in the Swift `UserProfile` model.

**This is NOT an SDK issue** - Installing Supabase Swift SDK won't fix this. The problem is the database schema doesn't match the code.

## Solution Options

### Option 1: Database Migration (RECOMMENDED) ✅

**Add missing columns to Supabase database:**

1. Go to [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project
3. Go to **SQL Editor**
4. Run the migration script: `SUPABASE_DATABASE_MIGRATION.sql`

**The script adds:**
- `acquiredStrengths` (JSONB)
- `basicInfo` (JSONB)
- `flowDiaryEntries` (JSONB)
- `valuesQuestions` (JSONB)
- `resourceInventory` (JSONB)
- `feasibilityAssessment` (JSONB)
- `lifeBlueprint` (JSONB)
- `lifeBlueprints` (JSONB)
- `actionPlan` (JSONB)
- `lastBlueprintGenerationTime` (TIMESTAMPTZ)
- And other columns if missing

**After running migration:**
- Data sync should work immediately
- No code changes needed
- All existing data preserved

### Option 2: Temporary Code Fix (If Migration Not Possible)

If you can't modify the database immediately, you can temporarily exclude missing fields:

**Modify `encodeUserProfile` to exclude fields that don't exist:**

```swift
private func encodeUserProfile(_ profile: UserProfile) throws -> [String: Any] {
    let encoder = JSONEncoder()
    encoder.dateEncodingStrategy = .iso8601
    
    let jsonData = try encoder.encode(profile)
    guard var dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
        throw NSError(...)
    }
    
    // TEMPORARY: Remove fields that don't exist in database
    // Remove this after running database migration
    dict.removeValue(forKey: "acquiredStrengths")
    // Add other missing fields here if needed
    
    return dict
}
```

**⚠️ Warning**: This will prevent `acquiredStrengths` from syncing to Supabase. Use only as temporary workaround.

## About Supabase Swift SDK

**Installing Supabase Swift SDK will NOT fix this issue** because:
- The error is about database schema, not SDK functionality
- Your current implementation uses REST API directly (which works fine)
- SDK would still fail with the same error if columns don't exist

**When to use Supabase Swift SDK:**
- If you want to use Supabase's built-in features (Realtime, Storage, etc.)
- If you want cleaner API calls
- If you want type-safe queries

**Current implementation is fine** - you just need to fix the database schema.

## Verification Steps

After running migration:

1. **Check columns exist:**
   ```sql
   SELECT column_name, data_type 
   FROM information_schema.columns 
   WHERE table_name = 'user_profiles'
   ORDER BY column_name;
   ```

2. **Test sync:**
   - Save a user profile in the app
   - Check Supabase dashboard → Table Editor → `user_profiles`
   - Verify data appears correctly

3. **Check console logs:**
   - Should see: `✅✅✅ PROFILE CREATED/UPDATED SUCCESSFULLY ✅✅✅`
   - No more "Could not find column" errors

## Complete Column List

Based on `UserProfile` model, these columns should exist:

**Required columns:**
- `id` (UUID, PRIMARY KEY)
- `interests` (JSONB)
- `strengths` (JSONB)
- `values` (JSONB)
- `createdAt` (TIMESTAMPTZ)
- `updatedAt` (TIMESTAMPTZ)

**Optional columns (can be NULL):**
- `basicInfo` (JSONB)
- `flowDiaryEntries` (JSONB)
- `valuesQuestions` (JSONB)
- `resourceInventory` (JSONB)
- `acquiredStrengths` (JSONB) ⚠️ **MISSING - causing error**
- `feasibilityAssessment` (JSONB)
- `lifeBlueprint` (JSONB)
- `lifeBlueprints` (JSONB)
- `actionPlan` (JSONB)
- `lastBlueprintGenerationTime` (TIMESTAMPTZ)

## Quick Fix SQL (Copy-Paste Ready)

```sql
-- Quick fix: Add only the missing column causing the error
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "acquiredStrengths" JSONB;

-- Verify it was added
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_profiles' 
AND column_name = 'acquiredStrengths';
```

## Next Steps

1. ✅ Run database migration SQL script
2. ✅ Test sync in app
3. ✅ Verify data appears in Supabase dashboard
4. ✅ Remove any temporary code fixes if applied

## Notes

- All nested structures (like `AcquiredStrengths`, `BasicUserInfo`) are stored as JSONB
- Arrays (like `interests`, `strengths`) are stored as JSONB arrays
- Dates are stored as TIMESTAMPTZ
- The `IF NOT EXISTS` clause prevents errors if column already exists
