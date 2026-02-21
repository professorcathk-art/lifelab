# Supabase 连接诊断指南

## 🔍 问题诊断

如果您看到以下错误或问题：
- ❌ "The network connection was lost"
- ❌ Supabase 表中没有数据
- ❌ 没有看到同步数据到 Supabase 的日志

## ✅ 已增强的日志输出

现在所有 Supabase 操作都有详细的日志输出，使用以下标记：

### 1. 同步检查日志
```
🔍🔍🔍 SYNC CHECK STARTED 🔍🔍🔍
   isOnline: true/false
   isAuthenticated: true/false
   currentUser: [user-id]
   profile provided: true/false
   local userProfile exists: true/false
```

### 2. 同步开始日志
```
💾💾💾 STARTING SYNC TO SUPABASE 💾💾💾
   User ID: [user-id]
   Profile has: X interests, Y strengths, Z values
   Has basicInfo: YES/NO
   Has lifeBlueprint: YES/NO
   Has actionPlan: YES/NO
```

### 3. 请求日志
```
🌐🌐🌐 MAKING REQUEST TO SUPABASE 🌐🌐🌐
   Method: GET/POST/PATCH
   URL: [full-url]
   Has access token: true/false
   Using token: [token-prefix]...
```

### 4. 响应日志
```
📥📥📥 SUPABASE RESPONSE RECEIVED 📥📥📥
   Status: 200/201/400/500
   Response body (first 500 chars): [response]
   Response body length: X bytes
```

### 5. 成功日志
```
✅✅✅ SYNC SUCCESSFUL ✅✅✅
   Successfully synced profile to Supabase for user [user-id]
   ✅ Data is now persisted in Supabase database
   Sync time saved: [timestamp]
```

### 6. 失败日志
```
❌❌❌ REQUEST FAILED (FINAL) ❌❌❌
   Error: [error-message]
   Error code: [code]
   Error domain: [domain]
   Attempts: X/3
```

## 🔍 诊断步骤

### 步骤 1: 检查日志输出

运行应用并完成登录后，在 Xcode 控制台中查找以下日志：

1. **查找同步检查日志**
   - 搜索：`SYNC CHECK STARTED`
   - 确认：`isOnline: true` 和 `isAuthenticated: true`

2. **查找同步开始日志**
   - 搜索：`STARTING SYNC TO SUPABASE`
   - 确认：有用户ID和数据字段

3. **查找请求日志**
   - 搜索：`MAKING REQUEST TO SUPABASE`
   - 确认：URL正确，有access token

4. **查找响应日志**
   - 搜索：`SUPABASE RESPONSE RECEIVED`
   - 确认：状态码是200或201

### 步骤 2: 检查网络连接

如果看到网络错误：
- ✅ 检查设备/模拟器的网络连接
- ✅ 确认可以访问互联网
- ✅ 尝试在浏览器中访问 Supabase URL: `https://inlzhosqbccyynofbmjt.supabase.co`

### 步骤 3: 检查认证状态

如果看到 "Not authenticated" 错误：
- ✅ 确认用户已登录（Email 或 Apple Sign In）
- ✅ 检查控制台是否有 "🔐 Saving authentication tokens..." 日志
- ✅ 确认 `supabase_access_token` 已保存在 UserDefaults

### 步骤 4: 检查 Supabase 配置

确认以下配置正确：
- ✅ Supabase URL: `https://inlzhosqbccyynofbmjt.supabase.co`
- ✅ Anon Key: `sb_publishable_IaUnj6C1mJGTHG8vXQmosg_oOz_uFk0`
- ✅ 表已创建：`user_profiles`, `user_subscriptions`
- ✅ RLS 策略已设置

### 步骤 5: 检查数据同步触发

数据同步会在以下情况触发：
1. ✅ 用户登录后（Email 或 Apple Sign In）
2. ✅ `updateUserProfile()` 被调用时
3. ✅ 购买订阅后
4. ✅ 订阅过期检查时

## 🛠️ 常见问题解决

### 问题 1: "The network connection was lost"

**原因**：网络连接不稳定或 Supabase 服务不可用

**解决方案**：
- 检查网络连接
- 代码已实现自动重试（最多3次）
- 数据会保存在本地，网络恢复后自动同步

### 问题 2: Supabase 表中没有数据

**可能原因**：
1. 同步没有触发
2. 网络错误导致同步失败
3. RLS 策略阻止了写入

**解决方案**：
- 查看控制台日志，确认是否有 `SYNC SUCCESSFUL` 日志
- 如果没有，检查是否有错误日志
- 确认 RLS 策略允许用户写入自己的数据

### 问题 3: 没有看到同步日志

**可能原因**：
1. 用户未登录
2. 没有 Supabase session token
3. 同步被跳过（例如：离线状态）

**解决方案**：
- 确认用户已登录
- 查看是否有 `SYNC CHECK STARTED` 日志
- 检查日志中是否有 "skipping sync" 消息

## 📊 验证数据同步

### 方法 1: 查看控制台日志

查找以下成功日志：
```
✅✅✅ SYNC SUCCESSFUL ✅✅✅
✅✅✅ PROFILE CREATED SUCCESSFULLY ✅✅✅
✅✅✅ PROFILE UPDATED SUCCESSFULLY ✅✅✅
```

### 方法 2: 检查 Supabase Dashboard

1. 登录 Supabase Dashboard
2. 进入 Table Editor
3. 查看 `user_profiles` 表
4. 确认有数据行

### 方法 3: 使用 Supabase SQL Editor

运行以下查询：
```sql
SELECT id, created_at, updated_at, 
       jsonb_array_length(interests) as interests_count,
       jsonb_array_length(strengths) as strengths_count
FROM user_profiles
ORDER BY created_at DESC
LIMIT 10;
```

## 🎯 下一步

如果问题仍然存在：
1. 复制完整的控制台日志（包括所有 🔍、💾、🌐、📥、✅、❌ 标记的日志）
2. 检查 Supabase Dashboard 中的 API 日志
3. 确认 RLS 策略是否正确设置
4. 验证 Supabase URL 和 API Key 是否正确

## 📝 注意事项

- 数据会先保存在本地（UserDefaults），然后同步到 Supabase
- 如果网络不可用，数据会保存在本地，网络恢复后自动同步
- 同步是异步的，不会阻塞 UI
- 所有操作都有重试机制（最多3次）
