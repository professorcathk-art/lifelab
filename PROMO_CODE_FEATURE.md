# 優惠碼功能說明

## ✅ 功能已實現

已將「跳過付款」按鈕替換為**優惠碼功能**。

---

## 🎯 功能特點

### 1. 優惠碼入口
- 在支付頁面顯示「使用優惠碼」按鈕
- 點擊後彈出優惠碼輸入界面

### 2. 優惠碼驗證
- 輸入優惠碼後點擊「驗證優惠碼」
- 驗證成功後自動跳過付款，直接生成生命藍圖
- 驗證失敗顯示錯誤提示

### 3. 安全設計
- 優惠碼不區分大小寫（自動轉換為大寫）
- 自動去除空格
- 錯誤提示清晰

---

## 🔑 默認優惠碼

**當前設置的優惠碼**：`LIFELAB2024`

### 如何修改優惠碼？

在 `PaymentView.swift` 中修改：

```swift
// Secret promo code (change this to your desired code)
private let secretPromoCode = "LIFELAB2024"  // 改為您想要的優惠碼
```

**建議**：
- 使用容易記住的代碼
- 可以包含年份或版本號
- 避免使用過於簡單的代碼（如 "1234"）

---

## 📱 使用流程

### 用戶流程：
1. 進入支付頁面
2. 點擊「使用優惠碼」按鈕
3. 輸入優惠碼（例如：`LIFELAB2024`）
4. 點擊「驗證優惠碼」
5. 驗證成功後自動生成生命藍圖

### 測試流程：
1. 運行應用
2. 完成問卷後進入支付頁面
3. 點擊「使用優惠碼」
4. 輸入 `LIFELAB2024`
5. 點擊「驗證優惠碼」
6. 應該看到「優惠碼驗證成功」提示
7. 點擊「確定」後開始生成生命藍圖

---

## 🎨 UI 設計

### 優惠碼輸入界面
- **標題**：輸入優惠碼
- **圖標**：票券圖標
- **輸入框**：自動聚焦，自動轉大寫
- **驗證按鈕**：漸變背景，帶陰影效果
- **錯誤提示**：紅色文字，帶警告圖標

### 支付頁面
- **優惠碼按鈕**：藍色半透明背景
- **位置**：在訂閱方案下方，訂閱按鈕上方

---

## 🔒 安全性

### 當前實現
- 優惠碼存儲在代碼中（客戶端驗證）
- 簡單的字符串比較

### 未來改進建議
如果需要更高的安全性，可以：
1. **服務器驗證**：將優惠碼驗證移到 Supabase 服務器
2. **使用次數限制**：每個優惠碼只能使用一次
3. **過期時間**：設置優惠碼有效期
4. **用戶綁定**：優惠碼與用戶 ID 綁定

**當前實現適合測試和內部使用**。

---

## 📋 代碼位置

### 主要文件
- `LifeLab/LifeLab/Views/InitialScan/PaymentView.swift`
  - `PaymentView` - 主支付視圖
  - `PromoCodeSheet` - 優惠碼輸入界面
  - `verifyPromoCode()` - 驗證邏輯

### 關鍵代碼

```swift
// 優惠碼定義
private let secretPromoCode = "LIFELAB2024"

// 驗證邏輯
private func verifyPromoCode() {
    let enteredCode = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
    
    if enteredCode.isEmpty {
        promoCodeError = "請輸入優惠碼"
        return
    }
    
    if enteredCode == secretPromoCode {
        promoCodeError = ""
        promoCodeVerified = true
    } else {
        promoCodeError = "優惠碼無效，請重新輸入"
    }
}
```

---

## ✅ 測試檢查清單

- [ ] 優惠碼按鈕顯示正常
- [ ] 點擊按鈕彈出輸入界面
- [ ] 輸入正確優惠碼後驗證成功
- [ ] 輸入錯誤優惠碼後顯示錯誤提示
- [ ] 驗證成功後自動生成生命藍圖
- [ ] 優惠碼不區分大小寫
- [ ] 自動去除空格

---

## 🎉 完成！

優惠碼功能已完全實現並通過編譯！

**當前優惠碼**：`LIFELAB2024`

可以開始測試了！🚀
