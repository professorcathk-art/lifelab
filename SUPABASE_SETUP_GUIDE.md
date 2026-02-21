# Supabase 数据库设置完整指南

## 📋 重要说明

**你不需要 Vercel 或其他后端服务！** Supabase 本身就是完整的后端解决方案，包括：
- ✅ PostgreSQL 数据库
- ✅ REST API（自动生成）
- ✅ 认证服务（Email/Password, Apple Sign In）
- ✅ 实时订阅
- ✅ 存储服务

## 🚀 设置步骤

### 步骤 1: 登录 Supabase Dashboard

1. 访问 [Supabase Dashboard](https://app.supabase.com)
2. 登录你的账户
3. 选择你的项目（或创建新项目）

### 步骤 2: 打开 SQL Editor

1. 在左侧菜单中点击 **"SQL Editor"**
2. 点击 **"New query"** 创建新查询

### 步骤 3: 创建数据库表

复制并运行以下 SQL 脚本（按顺序执行）：

---

## 📊 数据库表结构

### 1. 创建 `user_profiles` 表

```sql
-- ============================================
-- Create user_profiles table
-- ============================================
-- This table stores all user profile data including:
-- - Basic info (name, age, occupation, etc.)
-- - Interests, strengths, values
-- - Life blueprint
-- - Action plans
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

-- Create index for faster queries
CREATE INDEX IF NOT EXISTS idx_user_profiles_id ON public.user_profiles(id);
CREATE INDEX IF NOT EXISTS idx_user_profiles_updated_at ON public.user_profiles(updated_at);

-- Add comment
COMMENT ON TABLE public.user_profiles IS 'Stores complete user profile data including questionnaire answers, life blueprint, and action plans';
```

### 2. 创建 `user_subscriptions` 表

```sql
-- ============================================
-- Create user_subscriptions table
-- ============================================
-- This table stores user subscription information:
-- - Plan type (yearly, quarterly, monthly)
-- - Status (active, expired, cancelled)
-- - Start and end dates
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

-- Create indexes for faster queries
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_id ON public.user_subscriptions(user_id);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_status ON public.user_subscriptions(status);
CREATE INDEX IF NOT EXISTS idx_user_subscriptions_user_status ON public.user_subscriptions(user_id, status);

-- Add comment
COMMENT ON TABLE public.user_subscriptions IS 'Stores user subscription information for in-app purchases';
```

### 3. 启用 Row Level Security (RLS)

```sql
-- ============================================
-- Enable Row Level Security (RLS)
-- ============================================
-- RLS ensures users can ONLY access their own data
-- ============================================

ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.user_subscriptions ENABLE ROW LEVEL SECURITY;
```

### 4. 创建 RLS 策略

```sql
-- ============================================
-- Create RLS Policies for user_profiles
-- ============================================

-- Drop existing policies (if any)
DROP POLICY IF EXISTS "Users can view own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can update own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can insert own profile" ON public.user_profiles;
DROP POLICY IF EXISTS "Users can delete own profile" ON public.user_profiles;

-- Create policies
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
```

```sql
-- ============================================
-- Create RLS Policies for user_subscriptions
-- ============================================

-- Drop existing policies (if any)
DROP POLICY IF EXISTS "Users can view own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can update own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can insert own subscriptions" ON public.user_subscriptions;
DROP POLICY IF EXISTS "Users can delete own subscriptions" ON public.user_subscriptions;

-- Create policies
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
```

### 5. 创建自动更新 `updated_at` 的触发器

```sql
-- ============================================
-- Create function to update updated_at timestamp
-- ============================================

CREATE OR REPLACE FUNCTION public.handle_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Create triggers
CREATE TRIGGER set_updated_at_user_profiles
    BEFORE UPDATE ON public.user_profiles
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();

CREATE TRIGGER set_updated_at_user_subscriptions
    BEFORE UPDATE ON public.user_subscriptions
    FOR EACH ROW
    EXECUTE FUNCTION public.handle_updated_at();
```

---

## ✅ 验证设置

运行以下查询来验证表是否创建成功：

```sql
-- Check if tables exist
SELECT table_name, table_type
FROM information_schema.tables
WHERE table_schema = 'public'
AND table_name IN ('user_profiles', 'user_subscriptions')
ORDER BY table_name;

-- Check RLS status
SELECT tablename, rowsecurity
FROM pg_tables
WHERE schemaname = 'public'
AND tablename IN ('user_profiles', 'user_subscriptions');

-- Check policies
SELECT schemaname, tablename, policyname, cmd
FROM pg_policies
WHERE schemaname = 'public'
AND tablename IN ('user_profiles', 'user_subscriptions')
ORDER BY tablename, policyname;
```

---

## 🔐 配置认证

### Apple Sign In 设置

1. 在 Supabase Dashboard 中：
   - 点击左侧菜单 **"Authentication"**
   - 点击 **"Providers"**
   - 找到 **"Apple"** 并启用它

2. 配置 Apple OAuth：
   - **Service ID**: 你的 Apple Service ID（例如：`com.resonance.lifelab`）
   - **Secret Key**: 从 Apple Developer Portal 下载的 `.p8` 密钥文件内容
   - **Redirect URL**: `https://[your-project-ref].supabase.co/auth/v1/callback`
     - 替换 `[your-project-ref]` 为你的 Supabase 项目引用 ID

3. 在 Apple Developer Portal：
   - 确保 Service ID 的 **Redirect URLs** 包含 Supabase callback URL
   - 格式：`https://[your-project-ref].supabase.co/auth/v1/callback`

### Email/Password 认证

1. 在 Supabase Dashboard：
   - **Authentication** → **Providers** → **Email**
   - 确保 **"Enable Email provider"** 已启用
   - 配置 SMTP（可选，用于发送验证邮件）

---

## 📝 重要说明

### 关于数据同步

1. **不需要 Vercel**：
   - Supabase 提供完整的 REST API
   - 你的 iOS 应用直接通过 HTTPS 调用 Supabase API
   - 使用 `anon key` 或 `access token` 进行认证

2. **数据流**：
   ```
   iOS App → HTTPS → Supabase REST API → PostgreSQL Database
   ```

3. **认证流程**：
   ```
   iOS App → Supabase Auth API → JWT Token → 存储在 UserDefaults
   ```

### 关于表结构

- `user_profiles` 表使用 **JSONB** 类型存储复杂数据：
  - `basic_info`: BasicUserInfo 对象
  - `strengths`: StrengthResponse 数组
  - `values`: ValueRanking 数组
  - `life_blueprint`: LifeBlueprint 对象
  - `action_plan`: ActionPlan 对象
  
  这样做的好处：
  - ✅ 灵活的数据结构
  - ✅ 不需要频繁修改表结构
  - ✅ 支持嵌套对象和数组

- `user_subscriptions` 表使用标准列：
  - 更易于查询和索引
  - 支持 SQL 查询和统计

---

## 🧪 测试数据同步

### 测试用户资料保存

1. 在 iOS 应用中完成注册/登录
2. 填写问卷并保存
3. 在 Supabase Dashboard：
   - **Table Editor** → **user_profiles**
   - 检查是否有新记录

### 测试订阅保存

1. 在 iOS 应用中完成支付
2. 在 Supabase Dashboard：
   - **Table Editor** → **user_subscriptions**
   - 检查是否有新记录

---

## ⚠️ 常见问题

### 问题 1: "relation does not exist"

**原因**：表还没有创建

**解决方案**：
- 运行上面的 CREATE TABLE 语句
- 确保在正确的数据库中执行（通常是 `public` schema）

### 问题 2: "permission denied"

**原因**：RLS 策略配置错误

**解决方案**：
- 检查 RLS 是否已启用
- 检查策略是否正确创建
- 确保用户已登录（`auth.uid()` 不为 NULL）

### 问题 3: 数据没有同步

**原因**：
- 用户未登录
- RLS 策略阻止了操作
- 网络问题

**解决方案**：
- 检查 iOS 应用的控制台日志
- 检查 Supabase Dashboard 的 **Logs** 标签页
- 验证用户是否已认证

---

## 📚 参考资源

- [Supabase 官方文档](https://supabase.com/docs)
- [PostgreSQL JSONB 文档](https://www.postgresql.org/docs/current/datatype-json.html)
- [Row Level Security 文档](https://supabase.com/docs/guides/auth/row-level-security)

---

**最后更新**: 2024年
**版本**: 1.0
