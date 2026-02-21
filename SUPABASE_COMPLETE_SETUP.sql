-- ============================================
-- Supabase 完整数据库设置脚本
-- ============================================
-- 在 Supabase SQL Editor 中运行此脚本
-- 按顺序执行所有语句
-- ============================================

-- ============================================
-- 1. 创建 user_profiles 表
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_profiles (
    id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
    basic_info JSONB,
    interests TEXT[] DEFAULT '{}',
    strengths JSONB DEFAULT '[]',
    values JSONB DEFAULT '[]',
    flow_diary_entries JSONB DEFAULT '[]',
    values_questions JSONB,
    resource_inventory JSONB,
    acquired_strengths JSONB,
    feasibility_assessment JSONB,
    life_blueprint JSONB,
    life_blueprints JSONB DEFAULT '[]',
    action_plan JSONB,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW(),
    last_blueprint_generation_time TIMESTAMPTZ
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_profiles_id ON public.user_profiles(id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_updated_at ON public.user_profiles(updated_at);

-- 添加注释
COMMENT ON TABLE public.user_profiles IS 'Stores complete user profile data including questionnaire answers, life blueprint, and action plans';

-- ============================================
-- 2. 创建 user_subscriptions 表
-- ============================================

CREATE TABLE IF NOT EXISTS public.user_subscriptions (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES auth.users(id) ON DELETE CASCADE,
    plan_type TEXT NOT NULL CHECK (plan_type IN ('yearly', 'quarterly', 'monthly')),
    status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'cancelled')) DEFAULT 'active',
    start_date TIMESTAMPTZ NOT NULL,
    end_date TIMESTAMPTZ NOT NULL,
    created_at TIMESTAMPTZ DEFAULT NOW(),
    updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 创建索引
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_status ON public.user_subscriptions(user_id, status);

-- 添加注释
COMMENT ON TABLE public.user_subscriptions IS 'Stores user subscription information for in-app purchases';

-- ============================================
-- 3. 启用 Row Level Security (RLS)
-- ============================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;

-- ============================================
-- 4. 删除现有策略（如果存在）
-- ============================================

DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.user_profiles;

DROP POLICY IF EXISTS "Users can view own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can update own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can insert own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can delete own subscriptions" ON public.user_subscriptions;

-- ============================================
-- 5. 创建 user_profiles 的 RLS 策略
-- ============================================

CREATE POLICY "Users can view own profile"
    ON public.user_profiles FOR SELECT
    USING (auth.uid() = id);

CREATE POLICY "Users can update own profile"
    ON public.user_profiles FOR UPDATE
    USING (auth.uid() = id);

CREATE POLICY "Users can insert own profile"
    ON public.user_profiles FOR INSERT
    WITH CHECK (auth.uid() = id);

CREATE POLICY "Users can delete own profile"
    ON public.user_profiles FOR DELETE
    USING (auth.uid() = id);

-- ============================================
-- 6. 创建 user_subscriptions 的 RLS 策略
-- ============================================

CREATE POLICY "Users can view own subscriptions"
    ON public.user_subscriptions FOR SELECT
    USING (auth.uid() = user_id);

CREATE POLICY "Users can update own subscriptions"
    ON public.user_subscriptions FOR UPDATE
    USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions"
    ON public.user_subscriptions FOR INSERT
    WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can delete own subscriptions"
    ON public.user_subscriptions FOR DELETE
    USING (auth.uid() = user_id);

-- ============================================
-- 7. 创建自动更新 updated_at 的函数
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================
-- 8. 创建触发器
-- ============================================

DROP TRIGGER IF EXISTS set_updated_at_user_profiles ON public.user_profiles;
CREATE TRIGGER set_updated_at_user_profiles
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

DROP TRIGGER IF EXISTS set_updated_at_user_subscriptions ON public.user_subscriptions;
CREATE TRIGGER set_updated_at_user_subscriptions
    BEFORE UPDATE ON public.user_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

-- ============================================
-- 9. 验证设置（可选，用于检查）
-- ============================================

-- 检查表是否存在
SELECT 
    table_name,
    table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('user_profiles', 'user_subscriptions')
ORDER BY table_name;

-- 检查 RLS 状态
SELECT 
    tablename,
    rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('user_profiles', 'user_subscriptions');

-- 检查策略
SELECT 
    schemaname,
    tablename,
    policyname,
    cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('user_profiles', 'user_subscriptions')
ORDER BY tablename, policyname;

-- ============================================
-- 完成！
-- ============================================
-- 现在你的 Supabase 数据库已经设置完成
-- 可以开始使用 iOS 应用进行数据同步了
-- ============================================
