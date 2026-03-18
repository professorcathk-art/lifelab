-- Migration: Add yearsOfExperience field to user_profiles table
-- This migration adds the yearsOfExperience field to the basicInfo JSONB column
-- Since basicInfo is stored as JSONB, we don't need to alter the table structure
-- However, we should ensure the column exists and has proper indexing if needed

-- Step 1: Verify user_profiles table exists
-- (This is a comment - actual table creation should be done via Supabase Dashboard or migration tool)

-- Step 2: Ensure basicInfo column exists (should already exist)
-- ALTER TABLE user_profiles ADD COLUMN IF NOT EXISTS basicInfo JSONB;

-- Step 3: Create index on basicInfo for better query performance (optional but recommended)
-- CREATE INDEX IF NOT EXISTS idx_user_profiles_basic_info ON user_profiles USING GIN (basicInfo);

-- Step 4: Update RLS policies if needed (ensure users can read/write their own basicInfo)
-- The following policy should already exist, but verify it includes basicInfo access:

-- Example RLS Policy (verify in Supabase Dashboard):
-- CREATE POLICY "Users can view own profile"
--   ON user_profiles FOR SELECT
--   USING (auth.uid() = id);

-- CREATE POLICY "Users can update own profile"
--   ON user_profiles FOR UPDATE
--   USING (auth.uid() = id);

-- CREATE POLICY "Users can insert own profile"
--   ON user_profiles FOR INSERT
--   WITH CHECK (auth.uid() = id);

-- Note: Since basicInfo is JSONB, the yearsOfExperience field will be automatically
-- included when the app sends the updated BasicUserInfo structure.
-- No database schema changes are required - JSONB columns are flexible.

-- Verification Query (run in Supabase SQL Editor):
-- SELECT 
--   id,
--   basicInfo->>'yearsOfExperience' as years_of_experience,
--   basicInfo->>'occupation' as occupation,
--   basicInfo->>'age' as age
-- FROM user_profiles
-- WHERE basicInfo IS NOT NULL
-- LIMIT 10;
