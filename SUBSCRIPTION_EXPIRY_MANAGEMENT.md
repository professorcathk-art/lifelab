# 訂閱到期管理指南

## 📋 概述

本指南说明如何在应用中管理订阅到期，并在订阅过期时要求用户续订。

## 🔧 实现方式

### 1. SubscriptionManager 服务

创建了 `SubscriptionManager.swift` 来管理订阅状态：

**功能**：
- ✅ 检查 StoreKit 订阅状态
- ✅ 检查 Supabase 订阅到期日期
- ✅ 定期自动检查（每 5 分钟）
- ✅ 检测订阅是否即将到期（7 天内）
- ✅ 检测订阅是否已过期

**关键方法**：
```swift
// 检查订阅状态
await subscriptionManager.checkSubscriptionStatus()

// 检查是否过期
subscriptionManager.isSubscriptionExpired

// 检查是否即将到期
subscriptionManager.isSubscriptionExpiringSoon
```

### 2. ContentView 集成

在 `ContentView.swift` 中集成了订阅检查：

**逻辑**：
1. 应用启动时检查订阅状态
2. 如果订阅过期，显示 `SubscriptionExpiredView`
3. 如果订阅有效，显示 `MainTabView`
4. 订阅状态变化时自动更新 UI

**代码位置**：
```swift
// ContentView.swift
if hasCompletedInitialScan {
    if hasValidSubscription {
        MainTabView() // 显示主应用
    } else {
        SubscriptionExpiredView() // 显示续订页面
    }
}
```

### 3. SubscriptionExpiredView

创建了专门的订阅过期视图：

**功能**：
- ✅ 显示过期提示
- ✅ 显示过期日期（如果有）
- ✅ "立即續訂" 按钮（跳转到支付页面）
- ✅ "恢復購買" 按钮（恢复之前的购买）

**UI 元素**：
- 警告图标
- 过期提示文字
- 过期日期显示
- 续订按钮
- 恢复购买按钮

## 🔄 订阅检查流程

### 启动时检查

1. **应用启动** (`ContentView.onAppear`)
   - 调用 `subscriptionManager.checkSubscriptionStatus()`

2. **检查 StoreKit**
   - 查询 `Transaction.currentEntitlements`
   - 验证交易签名
   - 更新 `hasActiveSubscription`

3. **检查 Supabase**
   - 查询 `user_subscriptions` 表
   - 获取 `end_date` 和 `status`
   - 更新 `subscriptionExpiryDate`

4. **决定访问权限**
   - 如果 StoreKit 显示有效 → 允许访问
   - 如果 StoreKit 显示无效 → 检查 Supabase
   - 如果 Supabase 显示过期 → 要求续订

### 定期检查

- **频率**：每 5 分钟自动检查一次
- **触发**：使用 `Timer.publish` 自动触发
- **目的**：确保订阅状态实时更新

### 订阅状态变化时

- **监听**：使用 `onChange(of: subscriptionManager.hasActiveSubscription)`
- **动作**：如果订阅变为无效，显示过期提示

## 🚨 订阅过期处理

### 场景 1：订阅已过期

**行为**：
1. 用户打开应用
2. 检查订阅状态 → 已过期
3. 显示 `SubscriptionExpiredView`
4. 用户无法访问主应用功能
5. 用户点击 "立即續訂" → 跳转到支付页面

### 场景 2：订阅即将到期（7 天内）

**行为**：
1. 在主应用中显示提醒横幅
2. 提示用户续订
3. 不影响当前使用

### 场景 3：订阅自动续订

**行为**：
1. Apple 自动处理续订
2. StoreKit 自动更新交易状态
3. 应用自动检测到新交易
4. 更新 Supabase 订阅记录
5. 用户无需任何操作

## 📱 用户体验流程

### 正常流程

```
用户打开应用
    ↓
检查订阅状态
    ↓
订阅有效？
    ↓ 是
显示主应用
    ↓
定期检查订阅状态
```

### 过期流程

```
用户打开应用
    ↓
检查订阅状态
    ↓
订阅有效？
    ↓ 否
显示 SubscriptionExpiredView
    ↓
用户点击 "立即續訂"
    ↓
跳转到 PaymentView
    ↓
用户完成购买
    ↓
更新订阅状态
    ↓
返回主应用
```

## 🔍 调试和测试

### 测试订阅过期

1. **在 App Store Connect 中**：
   - 创建 Sandbox 测试账号
   - 购买订阅
   - 等待订阅到期（或手动取消）

2. **在应用中**：
   - 使用 Sandbox 账号登录
   - 检查是否显示过期提示
   - 测试续订流程

### 检查日志

查看控制台日志：
```
📊 Subscription Status:
   Has Active Subscription: false
   Expiry Date: 2024-01-01 00:00:00 +0000
   Plan Type: yearly
```

### 常见问题

**Q: 订阅过期后，用户数据会丢失吗？**
A: 不会。用户数据保存在 Supabase，订阅过期只是限制访问功能。

**Q: 如何测试订阅过期？**
A: 使用 Sandbox 账号购买订阅，然后在 App Store Connect 中手动取消或等待到期。

**Q: 订阅自动续订失败怎么办？**
A: Apple 会处理续订失败，应用会检测到订阅过期并提示用户续订。

## 📝 代码位置

- **SubscriptionManager**: `LifeLab/LifeLab/Services/SubscriptionManager.swift`
- **SubscriptionExpiredView**: `LifeLab/LifeLab/Views/SubscriptionExpiredView.swift`
- **ContentView 集成**: `LifeLab/LifeLab/Views/ContentView.swift`
- **PaymentService**: `LifeLab/LifeLab/Services/PaymentService.swift`

---

**最后更新**: 2024年
**版本**: 1.0
