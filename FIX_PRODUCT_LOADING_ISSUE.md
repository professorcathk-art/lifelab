# 修复产品加载问题 - Apple 审核失败

## 问题分析

Apple 审核员遇到 "無法載入產品，請稍後再試" 错误，但你在本地测试时没有这个问题。

### 可能的原因：

1. **产品还没有完全同步到沙盒环境**
   - 虽然产品状态是"準備提交"，但可能需要时间同步到沙盒
   - Apple 审核员使用的是沙盒环境，与你的测试环境可能不同

2. **产品加载时机问题**
   - 代码在 `onAppear` 时加载产品，但可能加载失败
   - 没有重试机制

3. **错误处理不够完善**
   - 当产品加载失败时，没有提供足够的调试信息
   - 没有自动重试机制

4. **产品 ID 可能不匹配**
   - 虽然不太可能，但需要确认

---

## 解决方案

### 方案 1：改进产品加载逻辑（推荐）

#### 修改 PaymentView.swift

添加更好的错误处理和重试机制：

```swift
// 在 PaymentView 中添加重试逻辑
private func loadProductsWithRetry(maxRetries: Int = 3) async {
    for attempt in 1...maxRetries {
        print("🔄 Loading products (attempt \(attempt)/\(maxRetries))...")
        await paymentService.loadProducts()
        
        if !paymentService.products.isEmpty {
            print("✅ Products loaded successfully")
            return
        }
        
        if attempt < maxRetries {
            print("⏳ Waiting before retry...")
            try? await Task.sleep(nanoseconds: 2_000_000_000) // 等待 2 秒
        }
    }
    
    // 所有重试都失败
    print("❌ Failed to load products after \(maxRetries) attempts")
    await MainActor.run {
        paymentService.errorMessage = "無法載入產品，請稍後再試"
    }
}
```

#### 修改 handlePurchase() 方法

改进错误处理和产品查找逻辑：

```swift
private func handlePurchase() async {
    isProcessing = true
    showWaitingTime = true
    
    let productID = selectedPackage.productID
    
    // 确保产品已加载，带重试机制
    if paymentService.products.isEmpty {
        print("📦 Products not loaded, loading with retry...")
        await loadProductsWithRetry()
    }
    
    // 如果还是为空，尝试再次加载
    if paymentService.products.isEmpty {
        print("⚠️ Products still empty, trying one more time...")
        await paymentService.loadProducts()
        
        // 等待一下让 StoreKit 同步
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 秒
    }
    
    // 查找产品
    guard let product = paymentService.products.first(where: { $0.id == productID }) else {
        print("❌ Product not found: \(productID)")
        print("📦 Available products: \(paymentService.products.map { $0.id })")
        print("📦 Expected product IDs:")
        print("   - com.resonance.lifelab.annually")
        print("   - com.resonance.lifelab.quarterly")
        print("   - com.resonance.lifelab.monthly")
        
        await MainActor.run {
            isProcessing = false
            showWaitingTime = false
            // 提供更详细的错误信息
            paymentService.errorMessage = "無法載入產品。請確保：\n1. 網絡連接正常\n2. App Store 服務可用\n3. 稍後再試"
            showError = true
        }
        return
    }
    
    // ... 继续购买流程
}
```

### 方案 2：添加产品加载状态显示

在 UI 中显示加载状态，让用户知道正在加载产品：

```swift
// 在 PaymentView 中添加加载指示器
if paymentService.isLoading && paymentService.products.isEmpty {
    VStack {
        ProgressView()
            .scaleEffect(1.5)
        Text("正在載入產品...")
            .font(.subheadline)
            .foregroundColor(BrandColors.secondaryText)
            .padding(.top)
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
}
```

### 方案 3：验证产品 ID 匹配

确保代码中的产品 ID 与 App Store Connect 中的完全一致：

```swift
// 在 PaymentService.swift 中验证产品 ID
private let productIDs: [String] = [
    "com.resonance.lifelab.annually",    // ✅ 必须与 App Store Connect 完全一致
    "com.resonance.lifelab.quarterly",   // ✅ 必须与 App Store Connect 完全一致
    "com.resonance.lifelab.monthly"      // ✅ 必须与 App Store Connect 完全一致
]
```

---

## 立即修复步骤

### 1. 检查产品 ID 是否匹配

在 App Store Connect 中确认：
- Features → In-App Purchases → 每个产品
- 检查 Product ID 是否与代码中的完全一致（区分大小写）

### 2. 确保产品完全准备好

在 App Store Connect 中：
- Features → In-App Purchases
- 检查每个产品的状态
- 确保所有必需信息都已填写
- 保存每个产品

### 3. 等待产品同步（重要！）

**产品创建后，需要等待 24-48 小时才能完全同步到沙盒环境。**

即使状态是"準備提交"，也可能需要时间同步。

### 4. 改进代码

应用上述代码改进，添加：
- 重试机制
- 更好的错误处理
- 加载状态显示

---

## 检查清单

在重新提交之前，确认：

- [ ] **产品 ID 完全匹配**
  - [ ] 代码中的产品 ID 与 App Store Connect 中的完全一致
  - [ ] 区分大小写
  - [ ] 没有多余的空格

- [ ] **产品完全准备好**
  - [ ] 所有产品状态是"準備提交"
  - [ ] 所有必需信息都已填写
  - [ ] 已保存所有产品

- [ ] **等待同步时间**
  - [ ] 产品创建后已等待至少 24 小时
  - [ ] 或者联系 Apple 支持确认产品已同步

- [ ] **代码改进**
  - [ ] 添加了重试机制
  - [ ] 改进了错误处理
  - [ ] 添加了加载状态显示

- [ ] **测试**
  - [ ] 在沙盒环境中测试
  - [ ] 使用沙盒测试账号
  - [ ] 验证产品可以正常加载

---

## 为什么本地测试成功但审核失败？

### 可能的原因：

1. **环境不同**
   - 你的测试：可能使用了已缓存的产品信息
   - Apple 审核：使用全新的沙盒环境，产品可能还没同步

2. **时间差**
   - 产品刚创建，还没完全同步到沙盒
   - 需要等待 24-48 小时

3. **网络环境**
   - Apple 审核员的网络环境可能不同
   - 沙盒服务器可能暂时不可用

4. **产品状态**
   - 虽然状态是"準備提交"，但可能还需要一些时间完全激活

---

## 我的建议

### 立即行动：

1. **改进代码**
   - 添加重试机制
   - 改进错误处理
   - 添加加载状态

2. **等待产品同步**
   - 如果产品刚创建，等待 24-48 小时
   - 或者联系 Apple 支持确认

3. **在 App Review Notes 中说明**
   - 说明产品已创建并准备好
   - 说明已添加重试机制
   - 请求审核员重试

4. **重新提交**
   - 上传新的 Build（包含改进的代码）
   - 在 App Review Notes 中说明改进

---

## 需要我帮你修改代码吗？

我可以帮你：
1. 添加重试机制
2. 改进错误处理
3. 添加加载状态显示
4. 验证产品 ID 匹配

告诉我你想从哪个开始！
