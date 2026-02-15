# Supabase 集成设置指南

## 🔐 密钥安全配置

✅ **密钥已安全存储在 `Secrets.swift`（gitignored）**

- ✅ `supabaseURL`: 已配置
- ✅ `supabaseAnonKey`: 已配置（发布密钥，客户端安全）
- ✅ `supabaseServiceRoleKey`: 已配置（服务端密钥，仅用于服务器端操作）

**重要**: `Secrets.swift` 已在 `.gitignore` 中，不会被提交到代码库。

---

## 📋 数据库表结构

请在 Supabase Dashboard 中执行以下 SQL 创建表：

### 1. 用户资料表 (`user_profiles`)

```sql
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
```

### 2. 生命蓝图表 (`life_blueprints`)

```sql
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
CREATE INDEX idx_life_blueprints_user_id ON life_blueprints(user_id);
CREATE INDEX idx_life_blueprints_version ON life_blueprints(user_id, version);
```

### 3. 行动计划表 (`action_plans`)

```sql
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
CREATE INDEX idx_action_plans_user_id ON action_plans(user_id);
```

### 4. 用户订阅表 (`user_subscriptions`)

```sql
CREATE TABLE IF NOT EXISTS user_subscriptions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID NOT NULL REFERENCES user_profiles(id) ON DELETE CASCADE,
  plan_type TEXT NOT NULL CHECK (plan_type IN ('yearly', 'quarterly', 'monthly')),
  status TEXT NOT NULL CHECK (status IN ('active', 'expired', 'cancelled')),
  start_date TIMESTAMPTZ NOT NULL,
  end_date TIMESTAMPTZ NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Create partial unique index to ensure only one active subscription per user
CREATE UNIQUE INDEX IF NOT EXISTS idx_user_subscriptions_active_unique 
  ON user_subscriptions(user_id) 
  WHERE status = 'active';

-- Enable Row Level Security
ALTER TABLE user_subscriptions ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only access their own subscriptions
CREATE POLICY "Users can view own subscriptions"
  ON user_subscriptions FOR SELECT
  USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own subscriptions"
  ON user_subscriptions FOR INSERT
  WITH CHECK (auth.uid() = user_id);

-- Index
CREATE INDEX idx_user_subscriptions_user_id ON user_subscriptions(user_id);
CREATE INDEX idx_user_subscriptions_status ON user_subscriptions(user_id, status);
```

---

## 🔧 Supabase Dashboard 设置步骤

### 1. 创建表
1. 登录 Supabase Dashboard: https://supabase.com/dashboard
2. 选择项目: `inlzhosqbccyynofbmjt`
3. 进入 SQL Editor
4. 执行上述 SQL 语句创建表

### 2. 配置 Authentication
1. 进入 Authentication > Providers
2. 启用 Email provider
3. 启用 Apple provider（如果需要）
4. 配置 Email templates（可选）

### 3. 配置 Row Level Security (RLS)
- RLS 已在上述 SQL 中启用
- 确保所有表都有正确的策略

### 4. 获取 API Keys
- ✅ 已配置在 `Secrets.swift`
- URL: `https://inlzhosqbccyynofbmjt.supabase.co`
- Anon Key: `sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0`

---

## 📱 代码集成

### 已创建的文件：
1. ✅ `SupabaseConfig.swift` - 安全配置管理
2. ✅ `SupabaseService.swift` - Supabase 操作服务
3. ✅ `Secrets.swift` - 密钥存储（已更新）

### 下一步需要更新：
1. `AuthService.swift` - 使用 Supabase Auth
2. `DataService.swift` - 使用 Supabase 数据库
3. `PaymentView.swift` - 集成订阅管理

---

## 🚀 部署检查清单

- [ ] 在 Supabase Dashboard 中执行 SQL 创建表
- [ ] 验证 RLS 策略已启用
- [ ] 测试认证功能（Email/Apple Sign In）
- [ ] 测试数据同步功能
- [ ] 测试订阅管理功能
- [ ] 验证密钥安全（确保 Secrets.swift 在 .gitignore 中）

---

## ⚠️ 安全注意事项

1. **Never commit Secrets.swift** - 已在 .gitignore 中
2. **Service Role Key** - 仅用于服务器端操作，不要在客户端使用
3. **Anon Key** - 可以安全地在客户端使用（配合 RLS）
4. **Access Token** - 存储在 UserDefaults，会自动管理

---

## 📝 测试步骤

1. **测试认证**:
   ```swift
   // Email sign up
   try await SupabaseService.shared.signUp(email: "test@example.com", password: "password123", name: "Test User")
   
   // Email sign in
   try await SupabaseService.shared.signIn(email: "test@example.com", password: "password123")
   ```

2. **测试数据同步**:
   ```swift
   // Save profile
   try await SupabaseService.shared.saveUserProfile(userProfile)
   
   // Fetch profile
   let profile = try await SupabaseService.shared.fetchUserProfile(userId: userId)
   ```

3. **测试订阅**:
   ```swift
   // Save subscription
   let subscription = UserSubscription(...)
   try await SupabaseService.shared.saveUserSubscription(subscription)
   
   // Fetch subscription
   let subscription = try await SupabaseService.shared.fetchUserSubscription(userId: userId)
   ```

---

## 🔗 相关资源

- Supabase Docs: https://supabase.com/docs
- Supabase Swift Guide: https://supabase.com/docs/reference/swift
- RLS Guide: https://supabase.com/docs/guides/auth/row-level-security
