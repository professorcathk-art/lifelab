# 控制台错误解释

## 🔍 这些错误与 Supabase 连接无关

您看到的这些控制台错误都是 **iOS 系统级别的警告**，**不会影响 Supabase 连接**：

### 1. LaunchServices 数据库错误
```
Error Domain=NSOSStatusErrorDomain Code=-54 "com.apple.private.coreservices.canmaplsdatabase"
```
**含义**：iOS LaunchServices 数据库访问权限问题  
**影响**：无 - 这是模拟器/开发环境的常见警告  
**解决方案**：无需处理，不影响应用功能

### 2. 应用包记录错误
```
Failed to locate container app bundle record
```
**含义**：系统无法找到应用包记录  
**影响**：无 - 通常是模拟器问题  
**解决方案**：无需处理

### 3. 用户管理器服务错误
```
personaAttributesForPersonaType failed with error
```
**含义**：用户管理器服务连接问题  
**影响**：无 - 系统服务问题  
**解决方案**：无需处理

### 4. 键盘输入系统错误
```
RTIInputSystemClient remoteTextInputSessionWithID
```
**含义**：键盘输入系统警告  
**影响**：无 - UI 渲染警告  
**解决方案**：无需处理

### 5. UI 快照警告
```
Snapshotting a view that is not in a visible window
```
**含义**：UI 视图快照警告  
**影响**：无 - 开发时的常见警告  
**解决方案**：无需处理

## 🎯 真正的 Supabase 连接问题

真正的 Supabase 连接问题会显示这些错误：

### 网络连接错误
```
❌❌❌ REQUEST FAILED (FINAL) ❌❌❌
   Error: The network connection was lost.
   Error code: -1005
   Error domain: NSURLErrorDomain
```

### 认证错误
```
❌❌❌ AUTH ERROR ❌❌❌
   Status code: 400
   Error message: Invalid login credentials
```

### API 密钥错误
```
❌ Failed to authenticate: Invalid API key
```

## 🔧 Supabase 连接问题诊断

### 1. 检查网络连接
```swift
// 在 SupabaseService.swift 中检查
print("🌐 Network status: \(isOnline)")
print("🌐 Supabase URL: \(SupabaseConfig.projectURL)")
```

### 2. 检查 API 密钥
```swift
print("🔑 Anon Key (first 20 chars): \(SupabaseConfig.anonKey.prefix(20))")
```

### 3. 检查请求超时
```swift
// 当前超时设置：60 秒
request.timeoutInterval = 60.0
```

### 4. 检查 RLS 策略
- 确保 `user_profiles` 表有正确的 RLS 策略
- 确保 `user_subscriptions` 表有正确的 RLS 策略

## ✅ 解决方案

### 方案 1：增加网络错误重试
已在 `SupabaseService.swift` 中实现：
- 自动重试 3 次
- 指数退避（2s, 4s, 6s）
- 网络错误检测

### 方案 2：增加超时时间
已在 `SupabaseService.swift` 中设置：
- 请求超时：60 秒
- 资源超时：120 秒
- 等待连接：启用

### 方案 3：网络错误后备方案
已在 `SubscriptionManager.swift` 中实现：
- 网络错误时使用 StoreKit 后备
- 不阻止用户访问应用

## 📝 总结

**这些控制台错误都是无害的系统警告，可以忽略。**

真正的 Supabase 连接问题应该关注：
1. 网络连接状态
2. API 密钥配置
3. RLS 策略设置
4. 请求超时设置

如果仍然遇到 Supabase 连接问题，请检查：
- 网络连接是否正常
- Supabase Dashboard 中的 API 密钥是否正确
- RLS 策略是否正确设置
- 请求日志中的具体错误信息
