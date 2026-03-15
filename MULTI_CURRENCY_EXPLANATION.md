# 多货币支持说明 - Multi-Currency Support

## ✅ 是的，美国用户会顺利看到 USD！

### StoreKit 自动货币转换机制

**StoreKit 根据用户的 App Store 账户地区（不是设备地区）自动返回正确的货币和价格。**

### 工作原理

1. **`product.displayPrice`**：
   - StoreKit 自动根据用户的 App Store 账户地区返回格式化价格
   - 美国用户 → USD（例如："$89.99"）
   - 香港用户 → HKD（例如："HK$ 699.00"）
   - 英国用户 → GBP（例如："£69.99"）
   - 日本用户 → JPY（例如："¥6,480"）

2. **`product.priceFormatStyle`**：
   - 包含与 `displayPrice` 相同的货币信息
   - 确保月度等效价格使用相同的货币

### 代码实现

```swift
// 账单金额 - 使用 StoreKit 的 displayPrice（自动货币转换）
func billedAmount(from products: [Product]) -> String {
    if let product = products.first(where: { $0.id == productID }) {
        return product.displayPrice  // ✅ 自动使用用户地区的货币
    }
    return fallbackPrice  // 仅在 StoreKit 产品无法加载时使用
}

// 月度等效价格 - 使用相同的 priceFormatStyle（确保货币一致）
func monthlyEquivalent(from products: [Product]) -> String? {
    let priceFormatStyle = product.priceFormatStyle  // ✅ 使用相同的货币格式
    let formattedMonthlyPrice = monthlyPriceDecimal.formatted(priceFormatStyle)
    return "約 \(formattedMonthlyPrice)/月"
}
```

## 不同地区用户看到的示例

### 🇺🇸 美国用户（App Store 账户在美国）
```
年付  節省 58%
$89.99 /年  ← USD
約 $7.50/月  ← USD（月度等效）
```

### 🇭🇰 香港用户（App Store 账户在香港）
```
年付  節省 58%
HK$ 699.00 /年  ← HKD
約 HK$ 58.25/月  ← HKD（月度等效）
```

### 🇬🇧 英国用户（App Store 账户在英国）
```
年付  節省 58%
£69.99 /年  ← GBP
約 £5.83/月  ← GBP（月度等效）
```

### 🇯🇵 日本用户（App Store 账户在日本）
```
年付  節省 58%
¥6,480 /年  ← JPY
約 ¥540/月  ← JPY（月度等效）
```

## 重要说明

### ✅ 自动处理
- **无需手动配置**：StoreKit 自动处理所有货币转换
- **价格由 App Store Connect 管理**：你在 App Store Connect 设置的价格会自动转换
- **货币符号自动显示**：StoreKit 自动使用正确的货币符号

### ⚠️ Fallback 价格（仅在产品无法加载时）
```swift
var fallbackPrice: String {
    // 仅在 StoreKit 产品无法加载时使用
    // 这是硬编码的 USD，但只在网络错误或产品未配置时显示
    case .yearly: return "89.99 USD"
}
```

**何时使用 Fallback：**
- StoreKit 产品加载失败（网络错误）
- 产品在 App Store Connect 中未配置
- Sandbox 环境产品未同步

**正常情况：**
- ✅ 99% 的情况下，StoreKit 会成功加载产品
- ✅ 用户会看到他们地区的正确货币
- ✅ Fallback 只在极端情况下使用

## 测试建议

### 测试不同货币的方法

1. **使用 Sandbox 测试账户**：
   - 创建不同地区的 Sandbox 测试账户
   - 美国账户 → 应该看到 USD
   - 香港账户 → 应该看到 HKD
   - 英国账户 → 应该看到 GBP

2. **更改 App Store 账户地区**（不推荐用于测试）：
   - Settings > App Store > Apple ID
   - 更改账户地区
   - ⚠️ 注意：这会更改你的实际账户设置

3. **使用 TestFlight**：
   - 邀请不同地区的测试用户
   - 他们会在自己的地区看到正确的货币

## 代码检查清单

✅ **已实现的功能：**
- [x] 使用 `product.displayPrice` 显示账单金额（自动货币）
- [x] 使用 `product.priceFormatStyle` 格式化月度等效价格（确保货币一致）
- [x] Fallback 价格仅在产品无法加载时使用
- [x] 无硬编码货币（除了 fallback）

✅ **符合 Apple 指南：**
- [x] 账单金额最突出（Guideline 3.1.2(c)）
- [x] 月度等效价格次要显示
- [x] 使用 StoreKit 实际价格
- [x] 多货币支持

## 总结

**✅ 是的，美国用户会顺利看到 USD！**

- StoreKit 根据用户的 App Store 账户地区自动返回正确的货币
- 代码使用 `product.displayPrice` 和 `product.priceFormatStyle`，确保货币一致
- 无需任何额外配置，StoreKit 自动处理所有货币转换
- 只有在极端情况下（产品无法加载）才会显示 fallback USD 价格

**你的代码已经正确实现了多货币支持！** 🎉
