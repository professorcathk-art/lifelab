# Supabase API Keys 存储和配置说明

## 🔐 重要安全说明

**⚠️ 警告：Secret Key (Service Role Key) 不应该存储在客户端应用中！**

### Key 类型说明

1. **Publishable Key (Anon Key)** ✅ **可以存储在客户端**
   - 格式：`sb_publishable_...` 或 `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - 用途：客户端应用使用
   - 安全性：通过 Row Level Security (RLS) 保护数据
   - **这是您应该使用的 key**

2. **Secret Key (Service Role Key)** ❌ **不应该存储在客户端**
   - 格式：`sb_secret_...` 或 `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`
   - 用途：服务器端使用（绕过 RLS）
   - 安全性：**完全访问权限，非常危险**
   - **永远不要放在客户端应用中！**

## 📱 iOS 应用中的 Key 存储方式

### 方式 1：使用 Secrets.swift（推荐，但需要添加到 .gitignore）

1. **创建 `Secrets.swift` 文件**：
   ```swift
   // LifeLab/LifeLab/Services/Secrets.swift
   struct Secrets {
       static let supabaseAnonKey = "sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0"
       static let supabaseProjectURL = "https://inlzhosqbccyynofbmjt.supabase.co"
   }
   ```

2. **添加到 .gitignore**：
   ```
   # Secrets.swift 不应该提交到 Git
   LifeLab/LifeLab/Services/Secrets.swift
   ```

3. **SupabaseConfig.swift 会自动使用 Secrets.swift**（如果存在）

### 方式 2：使用 UserDefaults（开发/测试用）

在应用启动时设置：
```swift
UserDefaults.standard.set("sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0", forKey: "supabase_anon_key")
UserDefaults.standard.set("https://inlzhosqbccyynofbmjt.supabase.co", forKey: "supabase_project_url")
```

### 方式 3：环境变量（CI/CD 用）

在构建脚本中设置环境变量。

## 🔗 应用如何连接到 Supabase

### 架构说明

```
iOS App (客户端)
    ↓ HTTPS 请求
Supabase REST API (https://inlzhosqbccyynofbmjt.supabase.co)
    ↓
PostgreSQL 数据库
```

**不需要 Vercel 或其他中间层！**

### 连接流程

1. **应用启动时**：
   - `SupabaseConfig` 读取配置（从 Secrets.swift 或 UserDefaults）
   - `SupabaseService` 初始化，验证 URL 和 Key

2. **API 请求时**：
   - 使用 `URLSession` 直接发送 HTTPS 请求到 Supabase REST API
   - 请求头包含：
     - `Authorization: Bearer [anon_key]`
     - `apikey: [anon_key]`
     - `Content-Type: application/json`

3. **数据安全**：
   - Row Level Security (RLS) 确保用户只能访问自己的数据
   - Anon Key 权限有限，只能执行 RLS 允许的操作

## 📝 配置步骤

### 步骤 1：获取正确的 Key

1. 登录 Supabase Dashboard
2. 进入 **Settings** → **API**
3. 找到 **Project API keys**
4. 复制 **`anon` `public`** key（不是 `service_role` key！）

### 步骤 2：创建 Secrets.swift

```bash
cd /Users/mickeylau/lifelab
cat > LifeLab/LifeLab/Services/Secrets.swift << 'EOF'
import Foundation

struct Secrets {
    // Supabase Configuration
    static let supabaseAnonKey = "sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0"
    static let supabaseProjectURL = "https://inlzhosqbccyynofbmjt.supabase.co"
    
    // Service Role Key - ONLY for server-side use (NOT used in iOS app)
    // static let supabaseServiceRoleKey = "sb_secret_..." // DO NOT USE IN CLIENT APP!
}
EOF
```

### 步骤 3：添加到 .gitignore

```bash
echo "LifeLab/LifeLab/Services/Secrets.swift" >> .gitignore
```

### 步骤 4：验证配置

运行应用，检查控制台日志：
```
✅ Supabase initialized with URL: https://inlzhosqbccyynofbmjt.supabase.co
✅ Using anon key (first 20 chars): sb_publishable_IaUnj6...
```

## 🔒 安全最佳实践

1. ✅ **只使用 Anon Key** 在客户端应用中
2. ✅ **使用 Row Level Security (RLS)** 保护数据
3. ✅ **将 Secrets.swift 添加到 .gitignore**
4. ❌ **永远不要提交 Secret Key 到 Git**
5. ❌ **永远不要在客户端使用 Service Role Key**

## 🚨 如果 Secret Key 已泄露

如果您已经将 Secret Key 提交到 Git 或公开：

1. **立即在 Supabase Dashboard 中重置 Service Role Key**：
   - Settings → API → Project API keys
   - 点击 Service Role Key 旁边的 "Reset"

2. **检查是否有未授权访问**：
   - Supabase Dashboard → Logs
   - 检查异常请求

3. **更新 .gitignore**：
   - 确保 Secrets.swift 不会被提交

## 📚 参考

- [Supabase Client Libraries](https://supabase.com/docs/reference)
- [Row Level Security](https://supabase.com/docs/guides/auth/row-level-security)
- [API Keys Security](https://supabase.com/docs/guides/api/api-keys)

---

**最后更新**: 2024年
**版本**: 1.0
