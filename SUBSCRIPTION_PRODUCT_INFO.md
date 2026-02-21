# 訂閱產品信息

## 📦 Product IDs 和價格

### 年付訂閱 (Annual)
- **Product ID**: `com.resonance.lifelab.annually`
- **Apple ID**: `6759484823`
- **價格**: USD 89.99/年
- **訂閱群組 ID**: `21943118`

### 季付訂閱 (Quarterly)
- **Product ID**: `com.resonance.lifelab.quarterly`
- **Apple ID**: `6759485069`
- **價格**: USD 29.99/季（90天週期）
- **訂閱群組 ID**: `21943118`

### 月付訂閱 (Monthly)
- **Product ID**: `com.resonance.lifelab.monthly`
- **Apple ID**: `6759485410`
- **價格**: USD 17.99/月
- **訂閱群組 ID**: `21943118`

## 🔧 代碼配置

### PaymentService.swift
```swift
private let productIDs: [String] = [
    "com.resonance.lifelab.annually",    // Annual subscription (USD 89.99/year)
    "com.resonance.lifelab.quarterly",   // Quarterly subscription (USD 29.99/quarter)
    "com.resonance.lifelab.monthly"       // Monthly subscription (USD 17.99/month)
]
```

### PaymentView.swift
後備價格（實際價格從 StoreKit 獲取）：
- 年付：USD 89.99
- 季付：USD 29.99
- 月付：USD 17.99

## ✅ 驗證清單

- [x] Product IDs 與 App Store Connect 一致
- [x] 價格信息已更新
- [x] 訂閱群組 ID 正確
- [x] 代碼中已配置所有三個訂閱選項
- [x] 支付頁面顯示所有訂閱選項
- [x] 訂閱到期管理已集成

---

**最後更新**: 2024年
