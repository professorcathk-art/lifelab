# Sandbox vs Production 环境说明

## 🎯 简短回答

**Sandbox 和 Production 环境是由 Apple 自动控制的，不是我们在代码中指定的。**

当应用审核通过并在 App Store 上线后，**会自动切换到 Production 环境**，无需修改任何代码。

---

## 📋 详细说明

### StoreKit 2 自动环境选择

StoreKit 2 会根据以下条件**自动选择**使用 Sandbox 还是 Production 环境：

#### 使用 Sandbox 环境的情况：
1. ✅ **设备上登录了 Sandbox 测试账号**
   - 这是您当前测试时的情况
   - 系统会自动检测并使用 Sandbox 环境

2. ✅ **从 Xcode 直接安装的应用**
   - 开发阶段安装的应用
   - 如果登录了 Sandbox 账号，会使用 Sandbox

3. ✅ **从 TestFlight 安装的应用**
   - 如果登录了 Sandbox 账号，会使用 Sandbox
   - 如果登录了真实 Apple ID，会使用 Production

#### 使用 Production 环境的情况：
1. ✅ **从 App Store 下载的应用**
   - 应用审核通过并上线后
   - 用户从 App Store 下载
   - **自动使用 Production 环境**

2. ✅ **设备上登录了真实 Apple ID**
   - 没有 Sandbox 账号时
   - 系统会自动使用 Production

3. ✅ **应用已发布到 App Store**
   - 即使从 TestFlight 安装
   - 如果使用真实 Apple ID，会使用 Production

---

## 🔍 我们的代码

### 检查结果

**我们的代码中没有硬编码任何 Sandbox 或 Production 相关的逻辑。**

```swift
// PaymentService.swift
let products = try await Product.products(for: productIDs)
let result = try await product.purchase()
```

这些 StoreKit 2 API 调用**会自动**根据环境选择：
- Sandbox 环境 → 连接到 Sandbox 服务器
- Production 环境 → 连接到 Production 服务器

**我们不需要（也不应该）在代码中指定使用哪个环境。**

---

## ✅ 审核通过后的行为

### 自动切换

当您的应用审核通过并在 App Store 上线后：

1. **用户从 App Store 下载应用**
   - 系统自动使用 Production 环境 ✅

2. **用户使用真实 Apple ID 购买**
   - 系统自动使用 Production 环境 ✅
   - 真实的购买交易 ✅
   - 真实的费用扣除 ✅

3. **无需修改代码**
   - StoreKit 2 自动处理环境切换 ✅
   - 我们的代码保持不变 ✅

---

## 🧪 测试环境 vs 生产环境

### 开发/测试阶段

- **环境**: Sandbox
- **账号**: Sandbox 测试账号
- **费用**: 免费（测试用）
- **目的**: 测试购买流程

### 生产阶段（App Store 上线后）

- **环境**: Production（自动）
- **账号**: 真实 Apple ID
- **费用**: 真实费用
- **目的**: 真实用户购买

---

## 📊 环境检测

### 如何知道当前使用的环境？

在购买时，系统会显示：
- **Sandbox 环境**: 显示 "Sandbox" 标识
- **Production 环境**: 不显示任何标识（正常购买流程）

### 代码中如何检测（如果需要）？

虽然我们不需要检测，但如果需要，可以这样做：

```swift
// 检查交易是否来自 Sandbox（仅用于调试）
if let transaction = try? checkVerified(verification) {
    // StoreKit 2 会自动处理，我们不需要手动检测
    // 但可以通过 transaction 的某些属性判断（如果需要）
}
```

**注意**: 我们当前的代码**不需要**检测环境，StoreKit 2 会自动处理。

---

## ⚠️ 重要提醒

### 1. 不要硬编码环境

❌ **错误做法**:
```swift
// 不要这样做！
#if DEBUG
    // Use sandbox
#else
    // Use production
#endif
```

✅ **正确做法**:
```swift
// StoreKit 2 自动处理，我们不需要指定
let products = try await Product.products(for: productIDs)
```

### 2. 测试时使用 Sandbox

- 开发阶段：使用 Sandbox 测试账号
- 测试购买流程：使用 Sandbox 环境
- **不会产生真实费用**

### 3. 上线后自动切换

- App Store 上线后：自动使用 Production
- 用户购买：真实交易
- **无需修改代码**

---

## 🎯 总结

| 问题 | 答案 |
|------|------|
| **Sandbox 是故意的吗？** | 不是，是 Apple 自动检测的 |
| **代码中指定了环境吗？** | 没有，StoreKit 2 自动处理 |
| **审核通过后会切换吗？** | 是的，自动切换到 Production |
| **需要修改代码吗？** | 不需要，完全自动 |
| **如何知道当前环境？** | Sandbox 会显示 "Sandbox" 标识 |

---

## ✅ 结论

**您不需要担心环境切换问题。**

- ✅ 开发/测试时：使用 Sandbox（自动）
- ✅ App Store 上线后：使用 Production（自动）
- ✅ 代码保持不变：StoreKit 2 自动处理
- ✅ 无需任何配置：Apple 完全控制环境选择

**您的代码已经准备好了，审核通过后会自动使用 Production 环境！** 🚀
