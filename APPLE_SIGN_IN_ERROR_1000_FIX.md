# Apple Sign In 錯誤 1000 修復指南

## 錯誤說明

`ASAuthenticationServicesAuthorizationError code 1000` 通常表示 Apple Sign In 配置問題。

## 已實現的修復

### 1. 增強錯誤處理
- ✅ 在 `AuthService.signInWithApple` 中添加了詳細的錯誤檢查
- ✅ 在 `LoginView.handleAppleSignIn` 中添加了用戶友好的錯誤消息
- ✅ 針對錯誤 1000 提供了具體的檢查清單

### 2. 錯誤消息
當遇到錯誤 1000 時，應用會顯示：
```
Apple Sign In 配置錯誤。

请检查：
1. Bundle ID 必须与 Apple Developer 中的 App ID 完全一致 (com.resonance.lifelab)
2. 在 Xcode 的 Signing & Capabilities 中必须启用 'Sign In with Apple'
3. 确保使用有效的开发证书
4. 在真实设备上测试（模拟器可能不支持）
```

## 檢查清單

### ✅ Step 1: 檢查 Bundle ID
1. 打開 Xcode
2. 選擇項目 → **LifeLab** target
3. **General** 標籤 → 確認 **Bundle Identifier** 為 `com.resonance.lifelab`
4. 在 Apple Developer 中確認 App ID 也是 `com.resonance.lifelab`

### ✅ Step 2: 啟用 Sign In with Apple
1. 在 Xcode 中選擇 **LifeLab** target
2. **Signing & Capabilities** 標籤
3. 點擊 **+ Capability**
4. 搜索並添加 **Sign In with Apple**
5. 確認沒有錯誤提示

### ✅ Step 3: 檢查開發證書
1. Xcode → **Settings** (⌘,)
2. **Accounts** 標籤
3. 選擇您的 Apple ID
4. 確認 **Team** 顯示正確（YUNUL5V5R6）
5. 在項目設置中確認 **Team** 已選擇

### ✅ Step 4: 在真實設備上測試
- ❌ **模擬器不支持** Apple Sign In 的某些功能
- ✅ **必須在真實 iPhone/iPad 上測試**

## 常見問題

### Q: 為什麼會出現錯誤 1000？
A: 通常是以下原因之一：
- Bundle ID 不匹配
- 未啟用 Sign In with Apple 功能
- 開發證書配置錯誤
- 在模擬器上測試（某些功能不支持）

### Q: 如何確認配置正確？
A: 檢查以下項目：
1. ✅ Bundle ID 一致
2. ✅ Sign In with Apple 已添加
3. ✅ 開發證書有效
4. ✅ 在真實設備上測試

### Q: 錯誤消息顯示了，但不知道如何修復？
A: 按照錯誤消息中的檢查清單逐一檢查。最常見的問題是：
- Bundle ID 不匹配（最常見）
- 未啟用 Sign In with Apple 功能

## 測試步驟

1. **確認配置**：
   - Bundle ID: `com.resonance.lifelab`
   - Sign In with Apple 已啟用
   - 開發證書有效

2. **連接真實設備**：
   - 使用 USB 連接 iPhone
   - 在 Xcode 中選擇設備

3. **運行應用**：
   - 點擊 Run (▶️)
   - 嘗試 Apple Sign In

4. **查看錯誤消息**：
   - 如果出現錯誤，應用會顯示詳細的檢查清單
   - 按照清單逐一檢查

## 技術細節

### 錯誤代碼
- `1000`: 授權失敗（配置問題）
- `1001`: 用戶取消
- `1002`: 請求失敗
- `1003`: 響應無效
- `1004`: 無響應
- `1005`: 內部錯誤

### 實現位置
- `AuthService.swift`: `signInWithApple` 方法
- `LoginView.swift`: `handleAppleSignIn` 方法

## 下一步

如果按照檢查清單操作後仍然出現錯誤：
1. 檢查 Xcode 控制台的詳細錯誤日誌
2. 確認 Apple Developer 中的配置
3. 嘗試重新生成開發證書
4. 確認設備已信任開發者證書

---

**注意**: Apple Sign In 在模擬器上可能無法正常工作。請務必在真實設備上測試。
