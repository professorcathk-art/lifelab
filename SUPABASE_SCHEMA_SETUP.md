# Supabase Database Schema Setup Guide

## 📋 Overview

This document explains how to set up the Supabase database schema for the LifeLab app to ensure data synchronization works correctly.

## 🔍 Current Issue

If you're seeing errors like:
- `Could not find the 'createdAt' column of 'user_profiles' in the schema cache`
- `Could not find the 'acquiredStrengths' column of 'user_profiles' in the schema cache`
- `PGRST204` errors

This means the database schema doesn't match the Swift model structure.

## 📊 Required Database Schema

### Table: `user_profiles`

The `user_profiles` table should have the following structure:

```sql
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  basicInfo JSONB,
  interests JSONB,
  strengths JSONB,
  values JSONB,
  flowDiaryEntries JSONB,
  valuesQuestions JSONB,
  resourceInventory JSONB,
  acquiredStrengths JSONB,
  feasibilityAssessment JSONB,
  lifeBlueprint JSONB,
  lifeBlueprints JSONB,
  actionPlan JSONB,
  lastBlueprintGenerationTime TIMESTAMPTZ
);

-- Create index on basicInfo for better query performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_basic_info ON user_profiles USING GIN (basicInfo);

-- Note: createdAt and updatedAt are NOT stored in database
-- They are managed locally in the app and removed before syncing
```

## 🔧 Setup Steps

### Step 1: Access Supabase Dashboard

1. Go to your Supabase project dashboard
2. Navigate to **SQL Editor**

### Step 2: Create/Update Table Schema

Run the following SQL in the SQL Editor:

```sql
-- Create user_profiles table if it doesn't exist
-- CRITICAL: Use snake_case column names to match Swift JSONEncoder's convertToSnakeCase strategy
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  basic_info JSONB,
  interests JSONB,
  strengths JSONB,
  values JSONB,
  flow_diary_entries JSONB,
  values_questions JSONB,
  resource_inventory JSONB,
  acquired_strengths JSONB,
  feasibility_assessment JSONB,
  life_blueprint JSONB,
  life_blueprints JSONB,
  action_plan JSONB,
  last_blueprint_generation_time TIMESTAMPTZ
);

-- Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_basic_info ON user_profiles USING GIN (basic_info);
CREATE INDEX IF NOT EXISTS idx_user_profiles_interests ON user_profiles USING GIN (interests);
CREATE INDEX IF NOT EXISTS idx_user_profiles_strengths ON user_profiles USING GIN (strengths);
```

### Step 3: Enable Row Level Security (RLS)

```sql
-- Enable RLS on user_profiles table
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- IMPORTANT: Drop existing policies first to avoid conflicts
-- This makes the script idempotent (safe to run multiple times)
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;

-- Policy: Users can view their own profile
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

-- Policy: Users can insert their own profile
CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- Policy: Users can update their own profile
CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

-- Policy: Users can delete their own profile
CREATE POLICY "Users can delete own profile"
  ON user_profiles FOR DELETE
  USING (auth.uid() = id);
```

**⚠️ Quick Setup**: Use the complete script `SUPABASE_SETUP_COMPLETE.sql` which handles all of this automatically!

### Step 4: Verify Schema

Run this query to verify the table structure:

```sql
SELECT 
  column_name,
  data_type,
  is_nullable
FROM information_schema.columns
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;
```

Expected columns (snake_case):
- `id` (UUID)
- `basic_info` (JSONB)
- `interests` (JSONB)
- `strengths` (JSONB)
- `values` (JSONB)
- `flow_diary_entries` (JSONB)
- `values_questions` (JSONB)
- `resource_inventory` (JSONB)
- `acquired_strengths` (JSONB)
- `feasibility_assessment` (JSONB)
- `life_blueprint` (JSONB)
- `life_blueprints` (JSONB)
- `action_plan` (JSONB)
- `last_blueprint_generation_time` (TIMESTAMPTZ)

## 📝 Important Notes

### JSONB Structure

Since we use JSONB columns, the structure is flexible. The `basic_info` JSONB will contain:

```json
{
  "region": "香港",
  "age": 28,
  "name": "小明",
  "occupation": "軟體工程師",
  "yearsOfExperience": 5,
  "annualSalaryUSD": 50000,
  "familyStatus": "單身",
  "education": "學士"
}
```

### Fields NOT Stored in Database

The following fields are managed locally and removed before syncing:
- `createdAt` - Managed locally
- `updatedAt` - Managed locally

These are removed in `SupabaseService.encodeUserProfile()` to avoid schema errors.

## 🔍 Troubleshooting

### Error: "Could not find column X"

1. **Check if column exists**: Run the verification query above
2. **Add missing column**: If a column is missing, add it:
   ```sql
   ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS columnName JSONB;
   ```

### Error: "PGRST204" (Schema cache)

PostgREST schema cache refreshes automatically, but you can force a refresh:

**Option 1: Wait (Recommended)**
- Schema cache refreshes automatically every few minutes (usually 1-5 minutes)
- After running SQL migrations, wait a few minutes and try again

**Option 2: Restart PostgREST via API**
- Supabase Dashboard → Settings → API
- Look for "Restart PostgREST" button (may not be available in all Supabase plans)
- If not available, the cache will refresh automatically

**Option 3: Use Supabase CLI (if available)**
```bash
supabase db reset
```

**Option 4: Contact Supabase Support**
- If schema cache issues persist, contact Supabase support
- They can manually refresh the cache for you

### Data Not Syncing

1. **Check RLS policies**: Ensure policies allow INSERT/UPDATE for authenticated users
2. **Check authentication**: Verify user is authenticated (`AuthService.shared.isAuthenticated`)
3. **Check network**: Verify network connectivity
4. **Check logs**: Look for errors in Xcode console

## ✅ Verification Checklist

- [ ] `user_profiles` table exists
- [ ] All required JSONB columns exist
- [ ] RLS is enabled
- [ ] RLS policies are created
- [ ] Indexes are created
- [ ] Test user can insert/update their profile
- [ ] Data appears in Supabase Dashboard → Table Editor

## 🧪 Test Query

After setup, test with this query:

```sql
-- Insert test profile (replace UUID with your user ID)
INSERT INTO user_profiles (id, basicInfo)
VALUES (
  'your-user-id-here',
  '{"region": "香港", "age": 28, "name": "測試", "occupation": "工程師", "yearsOfExperience": 5, "education": "學士"}'::jsonb
)
ON CONFLICT (id) DO UPDATE
SET basicInfo = EXCLUDED.basicInfo;

-- Verify data
SELECT id, basic_info FROM user_profiles WHERE id = 'your-user-id-here';
```

## 📚 Additional Resources

- [Supabase RLS Documentation](https://supabase.com/docs/guides/auth/row-level-security)
- [Supabase JSONB Guide](https://supabase.com/docs/guides/database/tables#jsonb-columns)
- [PostgREST API Documentation](https://postgrest.org/en/stable/api.html)
