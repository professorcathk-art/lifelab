-- ============================================
-- Supabase Database Setup SQL
-- Project: inlzhosqbccyynofbmjt
-- ============================================

-- 1. User Profiles Table
CREATE TABLE IF NOT EXISTS user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  basic_info JSONB,
  interests TEXT[],
  strengths JSONB,
  values JSONB,
  flow_diary_entries JSONB,
  values_questions JSONB,
  resource_inventory JSONB,
  acquired_strengths JSONB,
  feasibility_assessment JSONB,
  last_blueprint_generation_time TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own profile
CREATE POLICY "Users can view own profile"
  ON user_profiles FOR SELECT
  USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
  ON user_profiles FOR UPDATE
  USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
  ON user_profiles FOR INSERT
  WITH CHECK (auth.uid() = id);

-- ============================================

-- 2. Life Blueprints Table
CREATE TABLE IF NOT EXISTS life_blueprints (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  version INTEGER NOT NULL,
  vocation_directions JSONB NOT NULL,
  strengths_summary TEXT,
  feasibility_assessment TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id, version)
);

-- Enable Row Level Security
ALTER TABLE life_blueprints ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own blueprints
CREATE POLICY "Users can view own blueprints"
  ON life_blueprints FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own blueprints"
  ON life_blueprints FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own blueprints"
  ON life_blueprints FOR UPDATE
  USING (auth.uid() = user_id);

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_life_blueprints_user_id ON life_blueprints(user_id);
CREATE INDEX IF NOT EXISTS idx_life_blueprints_version ON life_blueprints(user_id, version);

-- ============================================

-- 3. Action Plans Table
CREATE TABLE IF NOT EXISTS action_plans (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  short_term JSONB,
  mid_term JSONB,
  long_term JSONB,
  milestones JSONB,
  today_tasks JSONB,
  today_tasks_last_generated TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(user_id)
);

-- Enable Row Level Security
ALTER TABLE action_plans ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own action plans
CREATE POLICY "Users can view own action plans"
  ON action_plans FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own action plans"
  ON action_plans FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update own action plans"
  ON action_plans FOR UPDATE
  USING (auth.uid() = user_id);

-- Index
CREATE INDEX IF NOT EXISTS idx_action_plans_user_id ON action_plans(user_id);

-- ============================================

-- 4. User Subscriptions Table
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('yearly', 'quarterly', 'monthly')),
  status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'cancelled')),
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Enable Row Level Security
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own subscriptions
CREATE POLICY "Users can view own subscriptions"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions"
  ON user_subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Create partial unique index to ensure only one active subscription per user
-- This replaces the invalid UNIQUE constraint with WHERE clause
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_subscriptions_active_unique 
  ON user_subscriptions(user_id) 
  WHERE status = 'active';

-- Index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON user_subscriptions(user_id, status);

-- ============================================
-- SQL Setup Complete!
-- ============================================
