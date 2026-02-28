# Supabase Sync Error - Quick Fix Guide

## ⚠️ Error Message
```
Could not find the 'acquiredStrengths' column of 'user_profiles' in the schema cache
```

## 🔍 Root Cause
**This is a DATABASE SCHEMA issue, NOT an SDK issue.**

Your Supabase `user_profiles` table is missing the `acquiredStrengths` column (and possibly other columns).

**Installing Supabase Swift SDK will NOT fix this** - the problem is the database table structure, not the code.

## ✅ Solution: Database Migration

### Step 1: Go to Supabase Dashboard
1. Open [Supabase Dashboard](https://supabase.com/dashboard)
2. Select your project: `inlzhosqbccyynofbmjt`
3. Click **SQL Editor** in the left sidebar

### Step 2: Run Migration SQL

Copy and paste this SQL into the SQL Editor and click **Run**:

```sql
-- Add missing acquiredStrengths column
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "acquiredStrengths" JSONB;

-- Add other potentially missing columns
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "basicInfo" JSONB;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "flowDiaryEntries" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "valuesQuestions" JSONB;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "resourceInventory" JSONB;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "feasibilityAssessment" JSONB;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "lifeBlueprint" JSONB;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "lifeBlueprints" JSONB DEFAULT '[]'::jsonb;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "actionPlan" JSONB;
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS "lastBlueprintGenerationTime" TIMESTAMPTZ;
```

### Step 3: Verify Columns Exist

Run this query to check:

```sql
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_profiles'
ORDER BY column_name;
```

You should see `acquiredStrengths` in the list.

### Step 4: Test Sync

1. Save a user profile in your app
2. Check Supabase Dashboard → **Table Editor** → `user_profiles`
3. Verify data appears correctly
4. Check console - should see: `✅✅✅ PROFILE CREATED/UPDATED SUCCESSFULLY ✅✅✅`

## 📋 Complete Column Checklist

Your `user_profiles` table should have these columns:

- ✅ `id` (UUID, PRIMARY KEY)
- ✅ `interests` (JSONB)
- ✅ `strengths` (JSONB)
- ✅ `values` (JSONB)
- ✅ `createdAt` (TIMESTAMPTZ)
- ✅ `updatedAt` (TIMESTAMPTZ)
- ⚠️ `acquiredStrengths` (JSONB) - **MISSING - causing error**
- ⚠️ `basicInfo` (JSONB) - may be missing
- ⚠️ `flowDiaryEntries` (JSONB) - may be missing
- ⚠️ `valuesQuestions` (JSONB) - may be missing
- ⚠️ `resourceInventory` (JSONB) - may be missing
- ⚠️ `feasibilityAssessment` (JSONB) - may be missing
- ⚠️ `lifeBlueprint` (JSONB) - may be missing
- ⚠️ `lifeBlueprints` (JSONB) - may be missing
- ⚠️ `actionPlan` (JSONB) - may be missing
- ⚠️ `lastBlueprintGenerationTime` (TIMESTAMPTZ) - may be missing

## 🚫 Why Installing SDK Won't Help

The Supabase Swift SDK documentation you found is for:
- Installing the SDK package
- Using SDK features (Realtime, Storage, etc.)

**But your error is about:**
- Database table structure
- Missing columns in PostgreSQL

**Even with the SDK, you'd still get the same error** because the database table doesn't have the required columns.

## ✅ After Migration

Once you run the migration:
- ✅ Data sync will work immediately
- ✅ No code changes needed
- ✅ All existing data preserved
- ✅ Future syncs will work correctly

## 📝 Notes

- `IF NOT EXISTS` prevents errors if column already exists
- All nested structures stored as JSONB (PostgreSQL's JSON type)
- Arrays stored as JSONB arrays (e.g., `[]`)
- Dates stored as TIMESTAMPTZ (timezone-aware timestamps)

## 🔗 Full Migration Script

See `SUPABASE_DATABASE_MIGRATION.sql` for the complete migration script with all columns.
