# 支付集成设置指南 - StoreKit 2

## ✅ StoreKit 2 是官方、流行且可靠的方法吗？

### 🎯 **是的！StoreKit 2 是最佳选择**

#### 1. **官方支持**
- ✅ **Apple 官方框架**：由 Apple 直接开发和维护
- ✅ **iOS 15+ 内置**：无需第三方依赖
- ✅ **官方文档**：完整的 Apple Developer 文档支持

#### 2. **流行程度**
- ✅ **行业标准**：所有 iOS 应用内购买的标准方法
- ✅ **广泛采用**：99% 的 iOS 应用使用 StoreKit
- ✅ **持续更新**：Apple 持续改进和更新

#### 3. **可靠性**
- ✅ **安全性最高**：Apple 处理所有支付流程
- ✅ **自动验证**：收据验证自动处理
- ✅ **订阅管理**：自动处理续订、取消等
- ✅ **退款处理**：Apple 自动处理退款

#### 4. **优势对比**

| 特性 | StoreKit 2 | RevenueCat | Stripe |
|------|------------|------------|--------|
| 官方支持 | ✅ Apple | ❌ 第三方 | ❌ 第三方 |
| 设置复杂度 | ⭐⭐ 简单 | ⭐⭐⭐ 中等 | ⭐⭐⭐⭐ 复杂 |
| 费用 | ✅ 免费 | ❌ 付费 | ❌ 付费 |
| 安全性 | ✅ 最高 | ⚠️ 高 | ⚠️ 高 |
| 订阅管理 | ✅ 自动 | ✅ 自动 | ❌ 手动 |
| 收据验证 | ✅ 自动 | ✅ 自动 | ❌ 手动 |

**结论**：StoreKit 2 是**官方、流行且最可靠**的方法！

---

## 📋 设置步骤

### Step 1: App Store Connect 配置

#### 1.1 登录 App Store Connect
1. 访问：https://appstoreconnect.apple.com
2. 使用您的 Apple Developer 账号登录

#### 1.2 选择您的应用
1. 点击 **"我的 App"**
2. 选择 **LifeLab** 应用（或创建新应用）

#### 1.3 创建订阅产品

**路径**：`功能` → `App 内购买项目` → `+` → `自动续期订阅`

**创建三个订阅产品**：

##### 产品 1: 年付订阅
- **产品 ID**: `com.resonance.lifelab.yearly`
- **类型**: 自动续期订阅
- **参考名称**: LifeLab 年付订阅
- **订阅组**: 创建新组 "LifeLab Premium"
- **订阅时长**: 1 年
- **价格**: 设置价格（例如：$94.99/年）
- **本地化**: 添加中文描述

##### 产品 2: 季付订阅
- **产品 ID**: `com.resonance.lifelab.quarterly`
- **类型**: 自动续期订阅
- **参考名称**: LifeLab 季付订阅
- **订阅组**: 使用相同的 "LifeLab Premium" 组
- **订阅时长**: 3 个月
- **价格**: 设置价格（例如：$29.99/季）

##### 产品 3: 月付订阅
- **产品 ID**: `com.resonance.lifelab.monthly`
- **类型**: 自动续期订阅
- **参考名称**: LifeLab 月付订阅
- **订阅组**: 使用相同的 "LifeLab Premium" 组
- **订阅时长**: 1 个月
- **价格**: 设置价格（例如：$18.99/月）

**重要**：
- ✅ 所有订阅必须在**同一个订阅组**中
- ✅ 产品 ID 必须**完全匹配**代码中的 ID
- ✅ 价格设置后需要**提交审核**才能生效

---

### Step 2: 配置 Sandbox 测试账户

#### 2.1 创建 Sandbox Tester
1. 在 App Store Connect 中，进入 **"用户和访问"**
2. 点击 **"Sandbox 测试员"**
3. 点击 **"+"** 添加测试员
4. 填写：
   - **名字**: 测试
   - **姓氏**: 账户
   - **电子邮件**: 使用**真实邮箱**（用于接收测试收据）
   - **密码**: 设置密码
   - **国家/地区**: 选择测试地区

#### 2.2 测试账户注意事项
- ⚠️ **不能使用真实 Apple ID**
- ⚠️ **必须使用真实邮箱**（用于接收测试收据）
- ⚠️ **每个邮箱只能创建一个 Sandbox 账户**
- ✅ **可以创建多个测试账户**（不同邮箱）

---

### Step 3: Xcode 项目配置

#### 3.1 检查 Bundle ID
确保 Bundle ID 与 App Store Connect 中的应用一致：
- **Bundle ID**: `com.resonance.lifelab`

#### 3.2 启用 In-App Purchase Capability
1. 在 Xcode 中选择项目
2. 选择 **"Signing & Capabilities"** 标签
3. 点击 **"+ Capability"**
4. 添加 **"In-App Purchase"**

**注意**：StoreKit 2 不需要额外配置，但添加此 Capability 可以确保兼容性。

---

### Step 4: 代码配置（已完成 ✅）

代码已经配置完成：
- ✅ `PaymentService.swift` - 支付服务
- ✅ `PaymentView.swift` - 支付界面
- ✅ Product IDs 已设置

**Product IDs**（已在代码中）：
```swift
private let productIDs: [String] = [
    "com.resonance.lifelab.yearly",
    "com.resonance.lifelab.quarterly",
    "com.resonance.lifelab.monthly"
]
```

---

### Step 5: 测试流程

#### 5.1 在真实设备上测试

**重要**：StoreKit 2 必须在**真实设备**上测试，模拟器不支持！

1. **连接 iPhone 到 Mac**
2. **在设备上登出 App Store**：
   - 设置 → App Store → 退出登录
3. **运行应用**：
   - 在 Xcode 中选择您的 iPhone
   - 点击运行
4. **测试购买**：
   - 进入支付页面
   - 选择订阅方案
   - 点击"订阅并解锁"
   - **会弹出 Sandbox 登录提示**
   - 使用 Sandbox 测试账户登录
   - 完成购买

#### 5.2 Sandbox 环境特点

- ✅ **快速过期**：订阅会快速过期（用于测试）
- ✅ **免费测试**：不会产生真实费用
- ✅ **真实流程**：完全模拟真实购买流程
- ✅ **收据验证**：会收到测试收据邮件

#### 5.3 测试检查清单

- [ ] 产品成功加载（显示真实价格）
- [ ] 购买流程正常
- [ ] Sandbox 登录正常
- [ ] 购买成功后解锁功能
- [ ] 恢复购买功能正常
- [ ] 订阅状态正确显示

---

## 🔍 常见问题

### Q1: 为什么选择 StoreKit 2 而不是 RevenueCat？

**A**: 
- ✅ **免费**：StoreKit 2 完全免费
- ✅ **官方支持**：Apple 官方维护
- ✅ **简单**：设置更简单，代码更少
- ✅ **安全性**：Apple 处理所有支付流程

**RevenueCat 适合**：
- 需要跨平台（iOS + Android）
- 需要复杂的订阅分析
- 需要 A/B 测试

**对于您的应用**：StoreKit 2 已经足够！

---

### Q2: 产品 ID 不匹配怎么办？

**A**: 
- 检查 App Store Connect 中的产品 ID
- 确保与代码中的 ID **完全一致**（大小写敏感）
- 重新运行应用

---

### Q3: Sandbox 测试账户无法登录？

**A**: 
- 确保在设备上**已登出 App Store**
- 使用**真实邮箱**创建 Sandbox 账户
- 确保邮箱未用于其他 Sandbox 账户

---

### Q4: 产品加载失败？

**A**: 
- 检查网络连接
- 确保产品已在 App Store Connect 中**创建并保存**
- 等待几分钟（产品创建后可能需要时间同步）
- 检查产品 ID 是否正确

---

### Q5: 如何测试订阅续订？

**A**: 
- Sandbox 环境中，订阅会快速过期
- 可以在 App Store Connect 中手动延长订阅
- 或等待自动续订（Sandbox 环境会加速）

---

## 📊 StoreKit 2 的优势总结

### ✅ 官方支持
- Apple 官方框架
- 持续更新和维护
- 完整的文档支持

### ✅ 简单易用
- 无需第三方 SDK
- 代码简洁
- 设置步骤少

### ✅ 安全可靠
- Apple 处理支付流程
- 自动收据验证
- 自动订阅管理

### ✅ 免费
- 无额外费用
- 无订阅费用
- 只需支付 Apple 的 30% 佣金（标准）

---

## 🎯 下一步行动

### 立即执行：
1. ✅ **登录 App Store Connect**
2. ✅ **创建三个订阅产品**
3. ✅ **创建 Sandbox 测试账户**
4. ✅ **在真实设备上测试**

### 测试完成后：
1. ✅ **提交应用审核**
2. ✅ **等待产品审核通过**
3. ✅ **发布应用**

---

## 📚 参考资源

### Apple 官方文档
- [StoreKit 2 文档](https://developer.apple.com/documentation/storekit)
- [App 内购买项目指南](https://developer.apple.com/in-app-purchase/)
- [App Store Connect 帮助](https://help.apple.com/app-store-connect/)

### 代码参考
- `PaymentService.swift` - 支付服务实现
- `PaymentView.swift` - 支付界面实现

---

## ✅ 总结

**StoreKit 2 是官方、流行且最可靠的方法！**

- ✅ **官方**：Apple 官方框架
- ✅ **流行**：99% iOS 应用使用
- ✅ **可靠**：Apple 处理所有支付流程
- ✅ **免费**：无额外费用
- ✅ **简单**：设置步骤少

**按照本指南设置，您的支付功能将完全可靠！** 🎉
