# 快速修復數據同步問題

## 🔍 問題診斷

用戶已登錄但數據沒有同步到 Supabase。檢查 `DataService.swift` 中的同步邏輯：

**關鍵檢查點：**
1. `AuthService.shared.isAuthenticated` 是否為 `true`？
2. `UserDefaults.standard.string(forKey: "supabase_access_token")` 是否存在？
3. 同步是否被跳過？

## 🚨 當前問題

在 `DataService.syncToSupabase()` 中，有這段代碼：

```swift
var hasSupabaseSession = UserDefaults.standard.string(forKey: "supabase_access_token") != nil
if !hasSupabaseSession {
    print("⚠️ No Supabase session found, skipping sync")
    return  // ❌ 這裡直接返回，不進行同步！
}
```

**問題**：如果 token 沒有保存到 UserDefaults，同步會被跳過！

## ✅ 立即修復方案

### 方案 1: 修復 Token 保存邏輯

確保在登錄時正確保存 token。檢查 `AuthService` 或 `SupabaseService` 中的登錄邏輯。

### 方案 2: 使用官方 SDK（推薦）

使用官方的 `supabase-swift` SDK，它會自動管理 token，不需要手動保存到 UserDefaults。

### 方案 3: 強制同步（臨時解決方案）

在 `DataService.syncToSupabase()` 中，即使沒有 token 也嘗試同步：

```swift
// 移除這個檢查，直接嘗試同步
// var hasSupabaseSession = UserDefaults.standard.string(forKey: "supabase_access_token") != nil
// if !hasSupabaseSession { return }
```

## 📝 檢查清單

在修復前，請檢查：

1. **用戶是否真的登錄了？**
   ```swift
   print("Auth Status: \(AuthService.shared.isAuthenticated)")
   print("User ID: \(AuthService.shared.currentUser?.id ?? "nil")")
   ```

2. **Token 是否存在？**
   ```swift
   let token = UserDefaults.standard.string(forKey: "supabase_access_token")
   print("Token exists: \(token != nil)")
   ```

3. **同步是否被調用？**
   - 檢查控制台日誌中是否有 `💾💾💾 STARTING SYNC TO SUPABASE 💾💾💾`
   - 如果沒有，說明同步沒有被觸發

4. **同步是否失敗？**
   - 檢查是否有 `❌❌❌ FAILED TO SYNC` 錯誤
   - 查看具體錯誤信息

## 🎯 推薦解決方案

**使用官方 Supabase Swift SDK** - 這是最可靠的解決方案：

1. 添加 SDK 依賴（見 `MIGRATE_TO_SUPABASE_SWIFT_SDK.md`）
2. 使用 `SupabaseServiceV2.swift`（已創建）
3. 更新 `DataService` 使用新服務
4. 測試數據同步

官方 SDK 的優勢：
- ✅ 自動管理認證 token
- ✅ 更好的錯誤處理
- ✅ 經過測試和維護
- ✅ 更好的性能
