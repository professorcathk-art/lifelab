# 數據同步診斷報告

## 🔍 同步流程分析

### 同步觸發點

1. **`DataService.saveUserProfile()`** (第 56 行)
   - 條件：`isAuthenticated && isOnline`
   - 動作：調用 `syncToSupabase(profile: profile)`

2. **`DataService.syncToSupabase()`** (第 173 行)
   - 檢查 1：`isOnline` ✅
   - 檢查 2：`isAuthenticated` (通過 `currentUser?.id`) ✅
   - **檢查 3：`hasSupabaseSession`** (通過 `supabase_access_token`) ⚠️ **關鍵問題**
   - 如果沒有 session → **跳過同步**

---

## ❌ 發現的問題

### 問題 1: Apple Sign In Fallback

**症狀**：
- Apple Sign In 失敗後使用本地會話
- 沒有 `supabase_access_token`
- `hasSupabaseSession` 返回 `false`
- **同步被跳過**

**日誌**：
```
⚠️ No Supabase session found, skipping sync
   User is using local session (e.g., Apple Sign In fallback)
   Data saved locally but will NOT sync to Supabase
```

**解決方案**：
- 配置 Apple OAuth 在 Supabase Dashboard
- 見 `APPLE_OAUTH_SUPABASE_FIX.md`

---

### 問題 2: Email 登錄可能沒有保存 Token

**檢查點**：
- `SupabaseService.signIn()` 是否正確保存 `access_token`？
- `makeAuthRequest()` 是否正確處理響應？

**需要驗證**：
- Email 登錄後，`supabase_access_token` 是否存在？
- 如果不存在，為什麼？

---

## 🔍 診斷步驟

### Step 1: 檢查 Email 登錄

1. **運行應用**
2. **使用 Email 登錄**
3. **查看日誌**，應該看到：
   ```
   ✅ Email sign in successful: [email]
   📥 Loading user profile from Supabase...
   ```

4. **檢查 UserDefaults**：
   ```swift
   // 在 Xcode 控制台運行：
   print(UserDefaults.standard.string(forKey: "supabase_access_token") ?? "NO TOKEN")
   ```
   - 如果有 token → 應該可以同步
   - 如果沒有 token → **問題所在**

### Step 2: 檢查同步觸發

1. **填寫數據**（基本資料、興趣等）
2. **查看日誌**，應該看到：
   ```
   💾 Syncing profile to Supabase for user: [user-id]
   ```

3. **如果看到**：
   ```
   ⚠️ No Supabase session found, skipping sync
   ```
   → **問題確認**：沒有 Supabase session

### Step 3: 檢查同步條件

**所有條件必須滿足**：
- ✅ `isOnline` = true
- ✅ `isAuthenticated` = true
- ✅ `hasSupabaseSession` = true ⚠️ **可能失敗**
- ✅ `profileToSave` != nil

---

## 🔧 可能的修復

### 修復 1: 確保 Email 登錄保存 Token

**檢查 `makeAuthRequest()`**：
- 確認 `access_token` 被正確保存
- 確認 `supabase_user_data` 被正確保存

### 修復 2: 添加調試日誌

**在 `syncToSupabase()` 開始處添加**：
```swift
print("🔍 Sync check:")
print("   isOnline: \(isOnline)")
print("   isAuthenticated: \(AuthService.shared.isAuthenticated)")
print("   currentUser: \(AuthService.shared.currentUser?.id ?? "nil")")
print("   hasSupabaseSession: \(hasSupabaseSession)")
```

### 修復 3: 強制同步（測試用）

**臨時添加**：
```swift
// 強制同步，即使沒有 session（僅用於測試）
if !hasSupabaseSession {
    print("⚠️ No Supabase session, but forcing sync for testing...")
    // 繼續執行同步（僅用於診斷）
}
```

---

## 📋 檢查清單

### Email 登錄：
- [ ] Token 是否保存？
- [ ] Session 是否正確？
- [ ] 同步是否觸發？

### Apple Sign In：
- [ ] OAuth 是否配置？
- [ ] Service ID 是否正確？
- [ ] Session 是否創建？

### 數據同步：
- [ ] `saveUserProfile` 是否被調用？
- [ ] `syncToSupabase` 是否被調用？
- [ ] 所有條件是否滿足？

---

## 🎯 下一步

1. **運行應用並登錄（Email）**
2. **查看日誌確認 token 是否保存**
3. **填寫數據並查看同步日誌**
4. **根據日誌診斷問題**

---

## ✅ 預期行為

### Email 登錄後：
```
✅ Email sign in successful
✅ Token saved: [token]
💾 Syncing profile to Supabase...
✅ Successfully synced profile to Supabase
```

### Apple Sign In（未配置 OAuth）：
```
⚠️ Apple Sign In Supabase error
⚠️ Using local session
⚠️ No Supabase session found, skipping sync
```

### Apple Sign In（已配置 OAuth）：
```
✅ Apple Sign In with Supabase successful
✅ Token saved: [token]
💾 Syncing profile to Supabase...
✅ Successfully synced profile to Supabase
```
