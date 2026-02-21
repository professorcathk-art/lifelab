# StoreKit 订阅检查逻辑详解

## 🔍 核心问题

**问题**：如果账户A在手机上订阅了（使用Apple ID A），但账户B没有订阅，如果用户用账户B登录但手机还是用Apple ID A，StoreKit会检测到订阅吗？

## 📱 StoreKit 的工作原理

### StoreKit 检查的是 Apple ID，不是应用内账户

**重要事实**：
- StoreKit 2 的订阅是**绑定到 Apple ID**的，不是绑定到应用内的用户账户
- 当用户购买订阅时，订阅记录在 Apple 的服务器上，关联到用户的 Apple ID
- StoreKit 检查订阅时，只检查**当前登录到设备的 Apple ID**是否有订阅

### 实际场景分析

**场景 1：账户A订阅，账户B未订阅，但都用同一个 Apple ID**

```
设备状态：
- Apple ID: apple@example.com (已订阅)
- 应用内账户A: user_a@example.com (已订阅)
- 应用内账户B: user_b@example.com (未订阅)

情况1：用账户A登录
- StoreKit 检查：✅ Apple ID 有订阅
- Supabase 检查：✅ 账户A有订阅记录
- 结果：✅ 跳过支付

情况2：用账户B登录（但手机还是用同一个 Apple ID）
- StoreKit 检查：✅ Apple ID 有订阅（因为手机还是用同一个 Apple ID）
- Supabase 检查：❌ 账户B没有订阅记录
- 结果：❌ 显示支付页面（因为 Supabase 没有记录）
```

**场景 2：账户A订阅，账户B未订阅，用不同的 Apple ID**

```
设备状态：
- Apple ID: apple_a@example.com (已订阅)
- 应用内账户A: user_a@example.com (已订阅)
- 应用内账户B: user_b@example.com (未订阅)

情况1：用账户A登录，手机用 Apple ID A
- StoreKit 检查：✅ Apple ID A 有订阅
- Supabase 检查：✅ 账户A有订阅记录
- 结果：✅ 跳过支付

情况2：用账户B登录，手机用 Apple ID B（未订阅）
- StoreKit 检查：❌ Apple ID B 没有订阅
- Supabase 检查：❌ 账户B没有订阅记录
- 结果：❌ 显示支付页面
```

## 🎯 为什么需要 Supabase？

### StoreKit 的局限性

1. **只检查 Apple ID**：StoreKit 不知道应用内的用户账户
2. **无法区分应用内用户**：如果多个应用内账户使用同一个 Apple ID，StoreKit 无法区分
3. **无法存储应用特定的订阅信息**：StoreKit 只存储订阅状态，不存储应用内的用户ID

### Supabase 的作用

1. **关联应用内用户和订阅**：存储 `user_id`（应用内的用户ID）和订阅信息的关联
2. **防止订阅共享**：确保只有购买订阅的应用内账户才能使用
3. **存储订阅详情**：存储订阅类型、开始日期、结束日期等详细信息

## 🔐 我们的双重检查逻辑

### 检查流程

```
用户登录应用
  ↓
检查订阅状态
  ↓
┌─────────────────────────────────────┐
│ 1. StoreKit 检查                    │
│    - 检查当前 Apple ID 是否有订阅   │
│    - 这是 Apple 的官方验证          │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 2. Supabase 检查                    │
│    - 检查应用内用户账户是否有订阅记录│
│    - 检查订阅是否过期                │
│    - 这是应用内的用户验证            │
└─────────────────────────────────────┘
  ↓
┌─────────────────────────────────────┐
│ 3. 最终判断                         │
│    - 两者都有 → ✅ 跳过支付          │
│    - 任一没有 → ❌ 显示支付页面      │
└─────────────────────────────────────┘
```

### 代码实现

```swift
// SubscriptionManager.swift
func checkSubscriptionStatus() async {
    // 1. 检查 StoreKit（Apple ID 级别）
    let hasStoreKitSubscription = paymentService.hasActiveSubscription
    
    // 2. 检查 Supabase（应用内用户级别）
    let supabaseSubscription = try await supabaseService.fetchUserSubscription(userId: userId)
    
    // 3. 两者都必须满足
    if hasStoreKitSubscription && supabaseSubscription != nil && supabaseSubscription!.endDate > Date() {
        hasActiveSubscription = true
    } else {
        hasActiveSubscription = false
    }
}
```

## ✅ 为什么这个逻辑是正确的

### 防止订阅共享

**问题**：如果只检查 StoreKit，会发生什么？

```
用户A用 Apple ID A 购买了订阅
用户B用 Apple ID B 登录应用（未购买）
但用户B知道用户A的 Apple ID 密码，用 Apple ID A 登录了手机

如果只检查 StoreKit：
- StoreKit 检查：✅ Apple ID A 有订阅
- 结果：✅ 用户B可以免费使用（错误！）

如果检查 StoreKit + Supabase：
- StoreKit 检查：✅ Apple ID A 有订阅
- Supabase 检查：❌ 用户B没有订阅记录
- 结果：❌ 用户B必须支付（正确！）
```

### 确保订阅关联到正确的用户

**问题**：如果只检查 Supabase，会发生什么？

```
用户A购买了订阅，订阅记录保存在 Supabase
用户A的 Apple ID 订阅过期了（但 Supabase 记录还在）

如果只检查 Supabase：
- Supabase 检查：✅ 用户A有订阅记录
- 结果：✅ 用户A可以继续使用（错误！）

如果检查 StoreKit + Supabase：
- StoreKit 检查：❌ Apple ID 订阅已过期
- Supabase 检查：✅ 用户A有订阅记录
- 结果：❌ 用户A必须续订（正确！）
```

## 🎯 总结

1. **StoreKit 检查 Apple ID**：确保 Apple ID 有有效的订阅
2. **Supabase 检查应用内用户**：确保应用内的用户账户有订阅记录
3. **两者都必须满足**：防止订阅共享和过期订阅继续使用
4. **这是正确的逻辑**：既验证了 Apple 的订阅，又验证了应用内的用户关联

## 📝 实际使用场景

### 场景：家庭共享

```
家庭成员A：Apple ID A，应用内账户 user_a@example.com
家庭成员B：Apple ID B，应用内账户 user_b@example.com

情况1：家庭成员A购买订阅
- StoreKit：Apple ID A 有订阅
- Supabase：user_a@example.com 有订阅记录
- 结果：家庭成员A可以使用 ✅

情况2：家庭成员B尝试使用
- StoreKit：Apple ID B 没有订阅（家庭共享不适用于应用内订阅）
- Supabase：user_b@example.com 没有订阅记录
- 结果：家庭成员B必须支付 ✅

情况3：家庭成员B用 Apple ID A 登录手机（但应用内还是用账户B）
- StoreKit：Apple ID A 有订阅
- Supabase：user_b@example.com 没有订阅记录
- 结果：家庭成员B必须支付 ✅（防止订阅共享）
```

## 🔧 代码位置

- `SubscriptionManager.swift`：双重检查逻辑
- `PaymentService.swift`：StoreKit 检查
- `SupabaseService.swift`：Supabase 订阅记录查询
