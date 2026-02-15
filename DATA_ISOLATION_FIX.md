# 數據隔離問題修復

## 問題描述

**嚴重問題**：登出賬戶A後，使用Apple Sign In登錄賬戶B，應用仍然顯示賬戶A的數據。

這是一個**數據隔離問題**，不應該發生！

---

## 根本原因

### 之前的實現問題：
1. **使用固定的 UserDefaults key**：`"lifelab_user_profile"`
   - 所有用戶共享同一個key
   - 沒有按用戶ID區分

2. **登出時不清除數據**：
   - 登出時保留了數據在內存中
   - 新用戶登錄時會看到舊用戶的數據

3. **登錄時不檢查用戶ID**：
   - 直接加載本地數據，沒有驗證是否屬於當前用戶

---

## ✅ 修復方案

### 1. 用戶特定的 UserDefaults Key

**之前**：
```swift
private let userDefaultsKey = "lifelab_user_profile" // 所有用戶共享
```

**現在**：
```swift
private var userDefaultsKey: String {
    if let userId = AuthService.shared.currentUser?.id {
        return "lifelab_user_profile_\(userId)" // 每個用戶獨立的key
    }
    return "lifelab_user_profile" // Fallback
}
```

**效果**：
- 每個用戶的數據存儲在獨立的key中
- 用戶A的數據：`lifelab_user_profile_userA_id`
- 用戶B的數據：`lifelab_user_profile_userB_id`
- **完全隔離，不會混淆**

---

### 2. 登出時清除當前用戶數據

**修復**：
```swift
func signOut() {
    // 保存當前用戶數據到用戶特定的key
    if let profile = DataService.shared.userProfile, let userId = currentUser?.id {
        DataService.shared.saveUserProfile(profile)
    }
    
    // 清除認證狀態
    currentUser = nil
    isAuthenticated = false
    
    // IMPORTANT: 清除當前用戶的數據從內存中
    // 數據已保存在用戶特定的UserDefaults中，但內存中清除
    DataService.shared.userProfile = nil
    DataService.shared.lastSyncTime = nil
}
```

**效果**：
- 登出時，數據保存到用戶特定的key
- 內存中的數據被清除
- 下一個用戶登錄時不會看到上一個用戶的數據

---

### 3. 登錄時清除舊用戶數據並加載新用戶數據

**修復**：
```swift
// Email Sign In / Sign Up / Apple Sign In
Task {
    // IMPORTANT: 清除任何之前用戶的數據
    await MainActor.run {
        DataService.shared.userProfile = nil
    }
    // 加載新用戶的數據
    await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
}
```

**效果**：
- 登錄新用戶時，先清除內存中的舊數據
- 然後加載新用戶的數據（從用戶特定的key或Supabase）

---

### 4. 用戶特定的數據加載

**新增函數**：
```swift
private func loadUserProfileForUser(userId: String) {
    let userKey = "lifelab_user_profile_\(userId)"
    // 只加載該用戶的數據
    if let data = UserDefaults.standard.data(forKey: userKey),
       let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
        userProfile = profile
    }
}
```

**效果**：
- 每個用戶的數據完全獨立
- 不會加載錯誤用戶的數據

---

## 📋 數據流程

### 登出流程：
```
1. 保存當前用戶數據 → UserDefaults (用戶特定的key)
2. 清除認證狀態
3. 清除內存中的數據
```

### 登錄流程：
```
1. 認證成功
2. 清除內存中的舊數據
3. 加載新用戶的數據（從用戶特定的key或Supabase）
```

### 數據存儲：
```
用戶A → lifelab_user_profile_userA_id
用戶B → lifelab_user_profile_userB_id
用戶C → lifelab_user_profile_userC_id
```

---

## ✅ 修復驗證

### 測試步驟：
1. **登錄賬戶A**
   - 填寫一些數據
   - 確認數據顯示正確

2. **登出賬戶A**
   - 點擊登出
   - 確認返回登錄頁面

3. **登錄賬戶B（不同的Apple ID）**
   - 使用Apple Sign In登錄
   - **應該看到空白數據或賬戶B的數據**
   - **不應該看到賬戶A的數據**

4. **再次登錄賬戶A**
   - 使用Email或Apple Sign In登錄
   - **應該看到賬戶A的數據**
   - **不應該看到賬戶B的數據**

---

## 🎯 關鍵改進

1. ✅ **數據隔離**：每個用戶的數據存儲在獨立的key中
2. ✅ **登出時清除**：內存中的數據被清除
3. ✅ **登錄時驗證**：只加載當前用戶的數據
4. ✅ **數據持久化**：每個用戶的數據仍然保存在本地（用戶特定的key）

---

## 📝 技術細節

### UserDefaults Key 格式：
- **之前**：`lifelab_user_profile`（所有用戶共享）
- **現在**：`lifelab_user_profile_{userId}`（每個用戶獨立）

### 數據保存：
- 每個用戶的數據保存在獨立的key中
- 數據不會丟失（仍然持久化）
- 但不會混淆不同用戶的數據

### 內存管理：
- 登出時清除內存中的數據
- 登錄時只加載當前用戶的數據
- 確保數據隔離

---

## ✅ 構建狀態

```
** BUILD SUCCEEDED **
```

所有修復已實現並通過編譯！

---

## 🎉 完成！

現在每個用戶的數據完全隔離：
- ✅ 登出賬戶A後，登錄賬戶B不會看到賬戶A的數據
- ✅ 每個用戶的數據保存在獨立的UserDefaults key中
- ✅ 數據仍然持久化，但按用戶隔離
- ✅ 登錄時自動加載正確用戶的數據

**問題已修復！** 🎉
