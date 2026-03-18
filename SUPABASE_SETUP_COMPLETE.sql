-- Complete Supabase Setup Script for LifeLab
-- Run this in Supabase Dashboard → SQL Editor
-- This script is idempotent - safe to run multiple times

-- Step 1: Create user_profiles table if it doesn't exist
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

-- Step 2: Create indexes for better performance
CREATE INDEX IF NOT EXISTS idx_user_profiles_basic_info ON user_profiles USING GIN (basic_info);
CREATE INDEX IF NOT EXISTS idx_user_profiles_interests ON user_profiles USING GIN (interests);
CREATE INDEX IF NOT EXISTS idx_user_profiles_strengths ON user_profiles USING GIN (strengths);

-- Step 3: Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Step 4: Drop existing policies if they exist (to avoid conflicts)
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON user_profiles;

-- Step 5: Create RLS policies
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
  ON user_profiles FOR DELETE
  USING (auth.uid() = id);

-- Step 6: Verify setup (optional - uncomment to run)
-- SELECT 
--   column_name,
--   data_type,
--   is_nullable
-- FROM information_schema.columns
-- WHERE table_name = 'user_profiles'
-- ORDER BY ordinal_position;

-- Success message
DO $$
BEGIN
  RAISE NOTICE '✅ Supabase setup completed successfully!';
  RAISE NOTICE '   - user_profiles table created/verified';
  RAISE NOTICE '   - Indexes created';
  RAISE NOTICE '   - RLS enabled';
  RAISE NOTICE '   - RLS policies created';
  RAISE NOTICE '';
  RAISE NOTICE 'Next steps:';
  RAISE NOTICE '1. Wait 1-5 minutes for PostgREST schema cache to refresh automatically';
  RAISE NOTICE '   (Schema cache refreshes automatically - no manual action needed)';
  RAISE NOTICE '2. Test data sync from the app';
  RAISE NOTICE '';
  RAISE NOTICE 'Note: If you see "column does not exist" errors, wait a few minutes';
  RAISE NOTICE '      and try again. The schema cache will update automatically.';
END $$;
