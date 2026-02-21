-- ============================================
-- Fix RLS Policies for Supabase Tables
-- ============================================
-- Run this in Supabase SQL Editor if tables are empty
-- This ensures users can insert/update/select their own data
-- ============================================

-- 1. Check if RLS is enabled
SELECT tablename, rowsecurity 
FROM pg_tables 
WHERE schemaname = 'public' 
AND tablename IN ('user_profiles', 'life_blueprints', 'action_plans', 'user_subscriptions');

-- 2. Enable RLS on all tables (if not already enabled)
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE life_blueprints ENABLE ROW LEVEL SECURITY;
ALTER TABLE action_plans ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- 3. Drop existing policies (if any) to avoid conflicts
DROP POLICY IF EXISTS "Users can view own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON user_profiles;

DROP POLICY IF EXISTS "Users can view own blueprints" ON life_blueprints;
DROP POLICY IF EXISTS "Users can insert own blueprints" ON life_blueprints;
DROP POLICY IF EXISTS "Users can update own blueprints" ON life_blueprints;

DROP POLICY IF EXISTS "Users can view own action plans" ON action_plans;
DROP POLICY IF EXISTS "Users can insert own action plans" ON action_plans;
DROP POLICY IF EXISTS "Users can update own action plans" ON action_plans;

DROP POLICY IF EXISTS "Users can view own subscriptions" ON user_subscriptions;
DROP POLICY IF EXISTS "Users can insert own subscriptions" ON user_subscriptions;
DROP POLICY IF EXISTS "Users can update own subscriptions" ON user_subscriptions;

-- 4. Create policies for user_profiles
-- IMPORTANT: auth.uid() returns UUID, id is also UUID, but we need to compare as text
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid()::text = id::text);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid()::text = id::text);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid()::text = id::text);

-- 5. Create policies for life_blueprints
CREATE POLICY "Users can view own blueprints"
  ON life_blueprints FOR SELECT
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own blueprints"
  ON life_blueprints FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own blueprints"
  ON life_blueprints FOR UPDATE
  USING (auth.uid()::text = user_id::text);

-- 6. Create policies for action_plans
CREATE POLICY "Users can view own action plans"
  ON action_plans FOR SELECT
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own action plans"
  ON action_plans FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own action plans"
  ON action_plans FOR UPDATE
  USING (auth.uid()::text = user_id::text);

-- 7. Create policies for user_subscriptions
CREATE POLICY "Users can view own subscriptions"
  ON user_subscriptions FOR SELECT
  USING (auth.uid()::text = user_id::text);

CREATE POLICY "Users can insert own subscriptions"
  ON user_subscriptions FOR INSERT
  WITH CHECK (auth.uid()::text = user_id::text);

CREATE POLICY "Users can update own subscriptions"
  ON user_subscriptions FOR UPDATE
  USING (auth.uid()::text = user_id::text);

-- 8. Verify policies were created
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('user_profiles', 'life_blueprints', 'action_plans', 'user_subscriptions')
ORDER BY tablename, policyname;

-- ============================================
-- IMPORTANT NOTES:
-- ============================================
-- 1. auth.uid() returns the UUID of the authenticated user
-- 2. We convert both to text for comparison because UUID comparison can be tricky
-- 3. These policies ensure users can ONLY access their own data
-- 4. After running this, test the app again
-- ============================================
