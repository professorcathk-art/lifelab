# 支付功能可见性配置

## 🎯 需求

在应用审核期间，隐藏订阅选项，只显示优惠码功能。
审核通过后，显示订阅选项。

---

## 🔧 实现方案

### 方案：使用配置标志

在代码中添加一个配置标志，控制订阅选项的显示。

---

## 📝 代码修改

### Step 1: 创建配置文件

创建 `PaymentConfig.swift`：

```swift
import Foundation

struct PaymentConfig {
    // 控制订阅功能是否显示
    // false: 只显示优惠码（审核期间）
    // true: 显示订阅选项（审核通过后）
    static let showSubscriptionOptions = false  // 审核期间设为 false
}
```

### Step 2: 修改 PaymentView

在 `PaymentView.swift` 中：

```swift
// 根据配置决定是否显示订阅选项
if PaymentConfig.showSubscriptionOptions {
    // 显示订阅方案
    VStack(spacing: 16) {
        // ... 订阅方案代码 ...
    }
    
    // 显示订阅按钮
    Button(action: {
        Task {
            await handlePurchase()
        }
    }) {
        // ... 订阅按钮代码 ...
    }
} else {
    // 审核期间：只显示优惠码提示
    Text("使用優惠碼即可解鎖完整功能")
        .font(BrandTypography.subheadline)
        .foregroundColor(BrandColors.secondaryText)
        .multilineTextAlignment(.center)
        .padding(.horizontal, BrandSpacing.xxxl)
}
```

---

## 🎯 使用流程

### 阶段 1: 审核期间

1. **设置配置**：
   ```swift
   static let showSubscriptionOptions = false
   ```

2. **提交应用**：
   - 只显示优惠码功能
   - 不显示订阅选项
   - 不包含 App 内购买项目

3. **等待审核通过**

### 阶段 2: 审核通过后

1. **创建订阅产品**：
   - 在 App Store Connect 创建三个订阅产品

2. **更新配置**：
   ```swift
   static let showSubscriptionOptions = true
   ```

3. **提交更新**：
   - 启用订阅功能
   - 提交新版本（如果需要）

---

## ✅ 优点

- ✅ **简单**：只需修改一个配置标志
- ✅ **灵活**：可以随时切换
- ✅ **安全**：不会影响现有功能
- ✅ **符合政策**：审核期间不显示支付选项

---

## 📋 检查清单

### 审核期间
- [ ] `showSubscriptionOptions = false`
- [ ] 只显示优惠码按钮
- [ ] 不显示订阅选项
- [ ] 提交应用版本

### 审核通过后
- [ ] 创建订阅产品
- [ ] `showSubscriptionOptions = true`
- [ ] 显示订阅选项
- [ ] 测试支付功能
- [ ] 提交订阅项目审核

---

## 🎉 完成！

使用这个方案，您可以：
- ✅ 审核期间只使用优惠码
- ✅ 审核通过后启用订阅功能
- ✅ 无需创建临时项目
- ✅ 代码修改最少
