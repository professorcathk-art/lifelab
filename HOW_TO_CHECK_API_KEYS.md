# 如何检查 API 密钥配置

## 📋 检查 Secrets.swift

### 步骤 1：打开 Secrets.swift 文件

文件位置：`LifeLab/LifeLab/Services/Secrets.swift`

### 步骤 2：验证配置

检查以下内容：

```swift
struct Secrets {
    // ✅ Supabase URL 应该是：
    static let supabaseURL = "https://inlzhosqbccyynofbmjt.supabase.co"
    
    // ✅ Supabase Anon Key 应该是：
    static let supabaseAnonKey = "sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0"
    
    // ⚠️ Service Role Key（不要用于客户端）
    // NOTE: Service role key should be kept secret and never committed to git
    // static let supabaseServiceRoleKey = "YOUR_SERVICE_ROLE_KEY_HERE"
}
```

### 步骤 3：验证密钥是否正确

**方法 1：在 Supabase Dashboard 中验证**

1. 登录 [Supabase Dashboard](https://supabase.com/dashboard)
2. 选择项目：`inlzhosqbccyynofbmjt`
3. 进入 **Settings** → **API**
4. 检查以下内容：
   - **Project URL**：应该与 `supabaseURL` 匹配
   - **anon/public key**：应该与 `supabaseAnonKey` 匹配

**方法 2：在 Xcode Console 中检查**

运行应用，查看控制台输出：

```
✅ Supabase initialized with URL: https://inlzhosqbccyynofbmjt.supabase.co
✅ Using anon key (first 20 chars): sb_publishable_IaUnj6C...
```

如果看到这些日志，说明密钥配置正确。

### 步骤 4：常见错误

**错误 1：密钥为空**
```
⚠️ Supabase configuration missing. Please check Secrets.swift or UserDefaults.
```
**解决方法**：确保 `Secrets.swift` 中的密钥不为空

**错误 2：URL 格式错误**
```
❌ Invalid Supabase URL: ...
```
**解决方法**：确保 URL 格式为 `https://[project-ref].supabase.co`

**错误 3：密钥不匹配**
```
❌ Auth error (401): Invalid API key
```
**解决方法**：从 Supabase Dashboard 复制最新的 anon key

---

## 🔍 如何验证连接是否正常

### 测试 1：检查初始化日志

运行应用，查看 Xcode Console：

```
✅ Supabase initialized with URL: https://inlzhosqbccyynofbmjt.supabase.co
✅ Using anon key (first 20 chars): sb_publishable_IaUnj6C...
```

### 测试 2：检查 API 请求日志

查看是否有以下日志：

```
🌐🌐🌐 MAKING REQUEST TO SUPABASE
   Endpoint: /rest/v1/user_profiles
   Method: GET
   Headers: apikey=sb_publishable_..., Authorization=Bearer ...
```

### 测试 3：检查响应日志

成功响应：
```
📥📥📥 SUPABASE RESPONSE RECEIVED
   Status: 200
   ✅ Profile fetched successfully
```

失败响应：
```
❌❌❌ FAILED TO CREATE PROFILE
   Error: ...
```

---

## 🛠️ 如果密钥配置错误

### 步骤 1：从 Supabase Dashboard 获取最新密钥

1. 登录 Supabase Dashboard
2. 选择项目
3. 进入 **Settings** → **API**
4. 复制 **Project URL** 和 **anon/public key**

### 步骤 2：更新 Secrets.swift

```swift
struct Secrets {
    static let supabaseURL = "https://inlzhosqbccyynofbmjt.supabase.co" // 更新这里
    static let supabaseAnonKey = "sb_publishable_..." // 更新这里
}
```

### 步骤 3：清理并重新构建

```bash
# 清理构建缓存
cd /Users/mickeylau/lifelab
xcodebuild clean -project LifeLab/LifeLab.xcodeproj -scheme LifeLab

# 重新构建
xcodebuild build -project LifeLab/LifeLab.xcodeproj -scheme LifeLab
```

---

## ✅ 验证清单

- [ ] `Secrets.swift` 文件存在
- [ ] `supabaseURL` 格式正确（`https://...supabase.co`）
- [ ] `supabaseAnonKey` 不为空
- [ ] 密钥与 Supabase Dashboard 中的匹配
- [ ] Xcode Console 显示初始化成功日志
- [ ] API 请求日志显示正确的密钥

---

## 📚 相关文档

- `SUPABASE_CONNECTION_EXPLAINED.md` - Supabase 连接方式说明
- `SUPABASE_SETUP_GUIDE.md` - Supabase 完整设置指南
