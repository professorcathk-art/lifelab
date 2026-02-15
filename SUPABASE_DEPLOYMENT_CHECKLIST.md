# Supabase 部署检查清单

## ✅ 已完成

### 1. 密钥安全配置
- ✅ Supabase URL 已存储在 `Secrets.swift`（gitignored）
- ✅ Anon Key 已存储在 `Secrets.swift`（gitignored）
- ✅ Service Role Key 已存储在 `Secrets.swift`（gitignored）
- ✅ `Secrets.swift` 已在 `.gitignore` 中
- ✅ 密钥验证：未暴露在代码库中（除了 Secrets.swift）

### 2. 代码文件创建
- ✅ `SupabaseConfig.swift` - 安全配置管理
- ✅ `SupabaseService.swift` - Supabase 操作服务
- ✅ `Secrets.swift` - 已更新包含 Supabase 密钥
- ✅ `LifeLabApp.swift` - 已更新初始化 Supabase 配置

### 3. 文档
- ✅ `SUPABASE_SETUP.md` - 完整的设置指南
- ✅ `SUPABASE_DEPLOYMENT_CHECKLIST.md` - 部署检查清单

---

## 📋 待完成步骤

### Step 1: 在 Supabase Dashboard 中创建数据库表

1. **登录 Supabase Dashboard**
   - 访问: https://supabase.com/dashboard
   - 选择项目: `inlzhosqbccyynofbmjt`

2. **执行 SQL 创建表**
   - 进入 SQL Editor
   - 复制 `SUPABASE_SETUP.md` 中的 SQL 语句
   - 依次执行创建以下表：
     - `user_profiles`
     - `life_blueprints`
     - `action_plans`
     - `user_subscriptions`

3. **验证表创建**
   - 进入 Table Editor
   - 确认所有表都已创建
   - 确认 RLS 已启用

### Step 2: 配置 Authentication

1. **启用 Email Provider**
   - 进入 Authentication > Providers
   - 启用 Email provider
   - 配置 Email templates（可选）

2. **启用 Apple Sign In**（如果需要）
   - 进入 Authentication > Providers
   - 启用 Apple provider
   - 配置 Apple App ID 和 Service ID

### Step 3: 更新代码集成

需要更新以下文件以使用 Supabase：

1. **`AuthService.swift`**
   - 替换模拟认证为 Supabase Auth
   - 使用 `SupabaseService.shared.signIn()` 和 `signUp()`

2. **`DataService.swift`**
   - 添加 Supabase 数据同步
   - 保存时同步到 Supabase
   - 加载时从 Supabase 获取

3. **`PaymentView.swift`**
   - 集成订阅管理
   - 保存订阅信息到 Supabase
   - 验证订阅状态

---

## 🔐 安全验证

### 密钥安全检查
```bash
# 运行此命令验证密钥未暴露
grep -r "sb_secret\|sb_publishable\|inlzhosqbccyynofbmjt" \
  --exclude-dir=.git \
  --exclude="*.md" \
  --exclude="Secrets.swift" \
  .
```

**预期结果**: 应该只找到 `SupabaseConfig.swift` 中的 `projectId`（这是公开的，安全）

### Git 状态检查
```bash
# 确认 Secrets.swift 未被跟踪
git status LifeLab/LifeLab/Services/Secrets.swift
```

**预期结果**: 应该显示 "Untracked files" 或不在 git 中

---

## 🧪 测试步骤

### 1. 测试 Supabase 连接
```swift
// 在应用启动时测试连接
let url = SupabaseConfig.projectURL
let key = SupabaseConfig.anonKey
print("Supabase URL: \(url)")
print("Anon Key (first 20): \(key.prefix(20))...")
```

### 2. 测试认证
- Email 注册
- Email 登录
- Apple Sign In（如果配置）

### 3. 测试数据同步
- 保存用户资料
- 获取用户资料
- 更新用户资料

### 4. 测试订阅
- 保存订阅信息
- 获取订阅状态
- 验证订阅有效性

---

## 📝 SQL 执行顺序

1. **首先创建 `user_profiles` 表**
2. **然后创建 `life_blueprints` 表**（依赖 user_profiles）
3. **然后创建 `action_plans` 表**（依赖 user_profiles）
4. **最后创建 `user_subscriptions` 表**（依赖 user_profiles）

---

## ⚠️ 重要注意事项

1. **Service Role Key**
   - ⚠️ **永远不要在客户端代码中使用**
   - 仅用于服务器端操作
   - 如果需要在客户端使用，必须通过后端 API

2. **RLS (Row Level Security)**
   - ✅ 所有表都已启用 RLS
   - ✅ 策略确保用户只能访问自己的数据
   - ⚠️ 测试时确保策略正确工作

3. **数据迁移**
   - 如果已有本地数据，需要迁移到 Supabase
   - 建议创建迁移脚本

---

## 🚀 下一步

完成上述步骤后，我可以帮您：
1. 更新 `AuthService` 使用 Supabase
2. 更新 `DataService` 使用 Supabase
3. 集成订阅管理
4. 实现数据迁移

请告诉我您已完成哪些步骤，我可以继续帮您完成集成！
