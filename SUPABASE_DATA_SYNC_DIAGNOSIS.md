# Supabase 數據同步診斷與修復指南

## 🔍 問題分析

### 當前狀況
- ✅ **表結構正確**：`user_profiles` 表使用 JSONB 列存儲所有 UserProfile 數據
- ✅ **同步邏輯存在**：DataService 有 `syncToSupabase()` 方法
- ❌ **表是空的**：說明數據沒有成功同步到 Supabase
- ⚠️ **風險**：用戶升級或卸載重裝時會丟失數據

### 為什麼表是空的？

**可能原因：**

1. **用戶未登錄** ⚠️ **最常見**
   - 數據同步需要用戶已登錄（`AuthService.shared.isAuthenticated == true`）
   - 如果用戶使用本地會話（未登錄），數據只保存在 UserDefaults，不會同步到 Supabase

2. **同步失敗但沒有錯誤提示**
   - 網絡錯誤
   - 認證 token 過期
   - RLS (Row Level Security) 策略問題
   - 表結構不匹配

3. **同步被跳過**
   - 用戶沒有 Supabase session（使用 Apple Sign In fallback）
   - 離線狀態下數據只保存本地

---

## ✅ 解決方案

### 方案 1: 確保用戶登錄後數據同步（推薦）

**問題**：如果用戶沒有登錄，數據不會同步到 Supabase。

**解決方案**：強制要求用戶登錄才能使用 App。

**檢查點：**
1. 確認 `AuthService.shared.isAuthenticated == true`
2. 確認 `AuthService.shared.currentUser?.id` 不為 nil
3. 確認 `UserDefaults.standard.string(forKey: "supabase_access_token")` 存在

### 方案 2: 修復現有數據同步邏輯

**當前代碼已經有同步邏輯**，但需要確保：

1. **在關鍵時刻強制同步**：
   - 用戶完成基本資料填寫後
   - 用戶完成興趣選擇後
   - 用戶完成天賦問卷後
   - 用戶完成價值觀排序後
   - 用戶生成生命藍圖後

2. **添加同步狀態指示器**：
   - 顯示同步狀態（同步中/已同步/同步失敗）
   - 讓用戶知道數據是否已保存到雲端

### 方案 3: 添加數據遷移功能

**為現有用戶遷移數據**：
- 檢測本地有數據但 Supabase 沒有
- 強制同步一次
- 顯示遷移進度

---

## 🔧 立即修復步驟

### 步驟 1: 檢查用戶是否已登錄

在 App 中添加診斷功能：

```swift
// 在 ProfileView 或 SettingsView 中添加
func checkSyncStatus() {
    let isAuthenticated = AuthService.shared.isAuthenticated
    let hasToken = UserDefaults.standard.string(forKey: "supabase_access_token") != nil
    let userId = AuthService.shared.currentUser?.id
    
    print("📊 Sync Status:")
    print("   Authenticated: \(isAuthenticated)")
    print("   Has Token: \(hasToken)")
    print("   User ID: \(userId ?? "nil")")
    
    if let profile = DataService.shared.userProfile {
        print("   Local Profile: ✅ (\(profile.interests.count) interests)")
    } else {
        print("   Local Profile: ❌")
    }
}
```

### 步驟 2: 添加強制同步按鈕

在 ProfileView 中添加"同步數據"按鈕：

```swift
Button("同步數據到雲端") {
    Task {
        if let profile = DataService.shared.userProfile {
            await DataService.shared.syncToSupabase(profile: profile)
        }
    }
}
```

### 步驟 3: 在關鍵時刻自動同步

確保在以下位置調用同步：

**在 InitialScanViewModel 中：**
```swift
func moveToNextStep() {
    // ... existing code ...
    
    // 強制同步到 Supabase
    if AuthService.shared.isAuthenticated {
        Task {
            await DataService.shared.syncToSupabase()
        }
    }
}
```

**在生成生命藍圖後：**
```swift
func generateLifeBlueprint() {
    // ... existing code ...
    
    // 強制同步
    if AuthService.shared.isAuthenticated {
        Task {
            await DataService.shared.syncToSupabase()
        }
    }
}
```

### 步驟 4: 驗證 Supabase 表結構

運行以下 SQL 檢查表結構：

```sql
-- 檢查表是否存在
SELECT table_name 
FROM information_schema.tables 
WHERE table_schema = 'public' 
AND table_name = 'user_profiles';

-- 檢查列結構
SELECT column_name, data_type 
FROM information_schema.columns 
WHERE table_name = 'user_profiles'
ORDER BY ordinal_position;

-- 檢查是否有數據
SELECT COUNT(*) FROM user_profiles;

-- 檢查 RLS 策略
SELECT * FROM pg_policies WHERE tablename = 'user_profiles';
```

### 步驟 5: 測試數據同步

1. **登錄用戶**
2. **填寫基本資料**
3. **檢查控制台日誌**：
   - 查找 `💾💾💾 STARTING SYNC TO SUPABASE 💾💾💾`
   - 查找 `✅✅✅ SYNC SUCCESSFUL ✅✅✅`
4. **在 Supabase Dashboard 中檢查**：
   - Table Editor → user_profiles
   - 應該看到一行數據

---

## 📊 數據結構確認

### UserProfile 包含的所有數據：

✅ **基本資料** (`basicInfo`):
- 居住地區、年齡、稱呼、職業、工作年資、年薪、家庭狀況、學歷

✅ **興趣** (`interests`):
- 用戶選擇的興趣關鍵詞列表

✅ **天賦** (`strengths`):
- 5 個問題的回答和選擇的關鍵詞（包含第一級和第二級）

✅ **價值觀** (`values`):
- 10 個核心價值觀的排序

✅ **心流日記** (`flowDiaryEntries`):
- 3 天的心流事件記錄

✅ **價值觀問題** (`valuesQuestions`):
- 深化探索的價值觀問題回答

✅ **資源盤點** (`resourceInventory`):
- 時間、金錢、物品、人脈資源

✅ **後天強項** (`acquiredStrengths`):
- 經驗、知識、技能、成就

✅ **可行性評估** (`feasibilityAssessment`):
- 6 個路徑的評估

✅ **生命藍圖** (`lifeBlueprint`):
- AI 生成的職業方向建議

✅ **行動計劃** (`actionPlan`):
- 短期、中期、長期行動計劃

### Supabase 表結構：

`user_profiles` 表使用 **JSONB** 列存儲所有這些數據：

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id),
  basic_info JSONB,              -- ✅ 存儲 BasicUserInfo
  interests JSONB,               -- ✅ 存儲 [String]
  strengths JSONB,               -- ✅ 存儲 [StrengthResponse]
  values JSONB,                  -- ✅ 存儲 [ValueRanking]
  flow_diary_entries JSONB,      -- ✅ 存儲 [FlowDiaryEntry]
  values_questions JSONB,        -- ✅ 存儲 ValuesQuestions
  resource_inventory JSONB,       -- ✅ 存儲 ResourceInventory
  acquired_strengths JSONB,      -- ✅ 存儲 AcquiredStrengths
  feasibility_assessment JSONB,  -- ✅ 存儲 FeasibilityAssessment
  life_blueprint JSONB,          -- ✅ 存儲 LifeBlueprint
  life_blueprints JSONB,         -- ✅ 存儲 [LifeBlueprint]
  action_plan JSONB,             -- ✅ 存儲 ActionPlan
  last_blueprint_generation_time TIMESTAMPTZ
);
```

**結論**：✅ **表結構完全支持所有用戶數據！**

---

## 🚨 緊急修復：為現有用戶遷移數據

### 創建數據遷移功能

在 App 啟動時檢查並遷移：

```swift
// 在 LifeLabApp.swift 或 ContentView.swift 中
func migrateLocalDataToSupabase() {
    guard AuthService.shared.isAuthenticated else {
        print("⚠️ Cannot migrate: User not authenticated")
        return
    }
    
    guard let localProfile = DataService.shared.userProfile else {
        print("📭 No local data to migrate")
        return
    }
    
    // 檢查 Supabase 是否有數據
    Task {
        if let userId = AuthService.shared.currentUser?.id {
            let remoteProfile = try? await SupabaseService.shared.fetchUserProfile(userId: userId)
            
            if remoteProfile == nil {
                // Supabase 沒有數據，遷移本地數據
                print("🔄 Migrating local data to Supabase...")
                do {
                    try await SupabaseService.shared.saveUserProfile(localProfile)
                    print("✅ Migration successful!")
                } catch {
                    print("❌ Migration failed: \(error.localizedDescription)")
                }
            } else {
                // Supabase 有數據，合併策略
                print("📊 Both local and remote data exist, merging...")
                // 使用較新的數據
                let localUpdated = localProfile.updatedAt
                let remoteUpdated = remoteProfile!.updatedAt
                
                if localUpdated > remoteUpdated {
                    // 本地更新，上傳本地
                    try? await SupabaseService.shared.saveUserProfile(localProfile)
                } else {
                    // 遠程更新，下載遠程
                    DataService.shared.userProfile = remoteProfile
                }
            }
        }
    }
}
```

---

## ✅ 驗證清單

發布前確認：

- [ ] 用戶必須登錄才能使用 App
- [ ] 數據在關鍵時刻自動同步到 Supabase
- [ ] 添加了同步狀態指示器
- [ ] 測試了數據同步功能
- [ ] 在 Supabase Dashboard 中驗證數據存在
- [ ] 測試了卸載重裝後數據恢復
- [ ] 測試了多設備數據同步

---

## 📝 總結

### 問題根源：
1. **用戶可能沒有登錄** → 數據只保存在本地
2. **同步可能失敗但沒有提示** → 需要添加錯誤處理和用戶提示
3. **沒有強制同步機制** → 需要在關鍵時刻強制同步

### 解決方案：
1. ✅ **表結構正確** - 可以存儲所有數據
2. ✅ **同步邏輯存在** - 需要確保被調用
3. ⚠️ **需要修復** - 添加強制同步和狀態提示

### 下一步：
1. 添加強制同步功能
2. 添加同步狀態指示器
3. 測試數據同步
4. 為現有用戶遷移數據

---

**重要提醒**：在修復之前，**所有用戶數據都只保存在本地 UserDefaults**。如果用戶卸載 App 或升級時清除數據，數據會丟失。**請盡快修復！**
