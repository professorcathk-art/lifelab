# Supabase 连接方式说明

## 📋 重要说明

### 问题 1：IPv4 直接连接限制

**您看到的信息**：
- Supabase Dashboard 显示 "IPv4 not compatible for direct connection"
- 但显示 "available for session pooler or transaction pooler"

**这意味着什么**：
- ✅ **这不影响您的 iOS 应用连接**
- ❌ 这只影响**直接数据库连接**（如使用 `psql` 命令行工具）
- ✅ 您的应用使用 **HTTPS REST API**，不受此限制影响

### 问题 2：是否需要 Supabase 密码？

**答案：不需要！**

您的 iOS 应用**不使用数据库密码**，原因如下：

1. **使用 REST API**：应用通过 HTTPS REST API 连接，不是直接数据库连接
2. **使用 Anon Key**：应用使用 Supabase 的 "anon key"（公开密钥）进行认证
3. **受 RLS 保护**：Row Level Security (RLS) 策略确保数据安全

---

## 🔌 您的应用如何连接 Supabase

### 连接方式

```
iOS App (LifeLab)
    ↓ HTTPS REST API
    ↓ 使用 Anon Key 认证
    ↓
Supabase REST API (https://inlzhosqbccyynofbmjt.supabase.co)
    ↓
PostgreSQL Database (受 RLS 保护)
```

### 代码中的连接

**1. URL 配置** (`SupabaseConfig.swift`):
```swift
static var projectURL: String {
    return "https://inlzhosqbccyynofbmjt.supabase.co"
}
```

**2. 认证方式** (`SupabaseService.swift`):
```swift
// 使用 Anon Key（公开密钥）
let anonKey = SupabaseConfig.anonKey

// HTTP 请求头
headers["apikey"] = anonKey
headers["Authorization"] = "Bearer \(accessToken)"
```

**3. 请求示例**:
```swift
// 示例：获取用户资料
GET https://inlzhosqbccyynofbmjt.supabase.co/rest/v1/user_profiles?id=eq.{userId}
Headers:
  apikey: sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0
  Authorization: Bearer {access_token}
```

---

## 🔐 密钥说明

### Anon Key（公开密钥）
- ✅ **安全用于客户端**（iOS 应用）
- ✅ **受 RLS 保护**（用户只能访问自己的数据）
- ✅ **存储在** `Secrets.swift` 和 `UserDefaults`
- 📍 **位置**：Supabase Dashboard → Settings → API → anon/public key

### Service Role Key（服务角色密钥）
- ❌ **不要用于客户端**
- ✅ **仅用于服务器端**（如 Vercel Edge Functions）
- ⚠️ **绕过 RLS**（有完全访问权限）
- 📍 **位置**：Supabase Dashboard → Settings → API → service_role key

### 数据库密码
- ❌ **iOS 应用不需要**
- ✅ **仅用于直接数据库连接**（如 `psql`、数据库管理工具）
- 📍 **位置**：Supabase Dashboard → Settings → Database → Connection string

---

## 🌐 IPv4 连接限制详解

### 什么是 "Direct Connection"？

**直接连接**指的是：
- 使用 `psql` 命令行工具
- 使用数据库管理工具（如 pgAdmin、DBeaver）
- 使用连接字符串直接连接 PostgreSQL

**示例**：
```bash
psql postgresql://postgres:[PASSWORD]@db.inlzhosqbccyynofbmjt.supabase.co:5432/postgres
```

### 为什么有 IPv4 限制？

某些网络环境（如某些移动网络、企业防火墙）可能：
- 不支持 IPv4 直接 TCP 连接
- 但支持 IPv6 或 SSL/TLS 连接

### 解决方案

**对于直接数据库连接**：
1. **使用 Session Pooler**：
   ```
   postgresql://postgres:[PASSWORD]@db.inlzhosqbccyynofbmjt.supabase.co:6543/postgres
   ```
   - 端口：`6543`（Session Pooler）
   - 支持 IPv4

2. **使用 Transaction Pooler**：
   ```
   postgresql://postgres:[PASSWORD]@db.inlzhosqbccyynofbmjt.supabase.co:5432/postgres
   ```
   - 端口：`5432`（Transaction Pooler）
   - 支持 IPv4

**对于 iOS 应用**：
- ✅ **不需要任何更改**
- ✅ 使用 HTTPS REST API（端口 443）
- ✅ 不受 IPv4 限制影响

---

## 🔍 如果连接仍然失败

### 检查清单

1. **网络连接**：
   - ✅ 设备是否连接到互联网？
   - ✅ Wi-Fi 或移动网络是否正常？
   - ✅ 防火墙是否阻止 HTTPS 连接？

2. **API 密钥**：
   - ✅ `Secrets.swift` 中的 `supabaseAnonKey` 是否正确？
   - ✅ Supabase Dashboard 中的 anon key 是否匹配？

3. **URL 配置**：
   - ✅ `SupabaseConfig.projectURL` 是否正确？
   - ✅ URL 格式：`https://[project-ref].supabase.co`

4. **RLS 策略**：
   - ✅ 是否已创建 `user_profiles` 和 `user_subscriptions` 表？
   - ✅ 是否已启用 RLS？
   - ✅ 是否已创建 RLS 策略？

5. **认证状态**：
   - ✅ 用户是否已登录？
   - ✅ `access_token` 是否有效？
   - ✅ 是否已保存到 `UserDefaults`？

### 调试步骤

**1. 检查日志**：
```swift
// 在 SupabaseService.swift 中查找：
print("✅ Supabase initialized with URL: \(url)")
print("✅ Using anon key (first 20 chars): \(anonKey.prefix(20))...")
```

**2. 检查网络请求**：
- 在 Xcode Console 中查找：
  - `🌐🌐🌐 MAKING REQUEST TO SUPABASE`
  - `📥📥📥 SUPABASE RESPONSE RECEIVED`
  - `❌❌❌ FAILED TO CREATE PROFILE`

**3. 测试连接**：
```bash
# 使用 curl 测试 REST API
curl -X GET \
  'https://inlzhosqbccyynofbmjt.supabase.co/rest/v1/user_profiles?id=eq.{userId}' \
  -H "apikey: sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0" \
  -H "Authorization: Bearer {access_token}"
```

---

## ✅ 总结

### 您的应用连接方式

1. **连接类型**：HTTPS REST API（不是直接数据库连接）
2. **认证方式**：Anon Key + Access Token（不是数据库密码）
3. **端口**：443（HTTPS）
4. **IPv4 限制**：**不影响**您的应用

### 如果连接失败

- ❌ **不是** IPv4 限制问题
- ✅ **可能是**：
  - 网络连接问题
  - API 密钥配置错误
  - RLS 策略未设置
  - 认证 token 无效

### 下一步

1. ✅ 检查网络连接
2. ✅ 验证 API 密钥配置
3. ✅ 确认 RLS 策略已设置
4. ✅ 查看 Xcode Console 日志

---

## 📚 相关文档

- `SUPABASE_SETUP_GUIDE.md` - Supabase 完整设置指南
- `SUPABASE_COMPLETE_SETUP.sql` - SQL 脚本创建表和 RLS 策略
- `SUPABASE_CONNECTION_DIAGNOSTICS.md` - 连接问题诊断指南
