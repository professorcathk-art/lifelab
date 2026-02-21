# Supabase 數據保存問題診斷

## ❌ 問題

**症狀**：Supabase 表都是空的，數據沒有被保存

---

## 🔍 可能原因

### 1. RLS (Row Level Security) 策略阻止寫入

**最可能的原因**：Supabase 的 RLS 策略可能阻止了數據寫入

**檢查方法**：
1. 登錄 Supabase Dashboard
2. 進入 **Authentication** → **Policies**
3. 檢查 `user_profiles` 表的 RLS 策略
4. 確認是否有 INSERT 和 UPDATE 策略

**需要的策略**：
```sql
-- 允許用戶插入自己的數據
CREATE POLICY "Users can insert their own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid() = id);

-- 允許用戶更新自己的數據
CREATE POLICY "Users can update their own profile"
ON user_profiles FOR UPDATE
USING (auth.uid() = id);

-- 允許用戶讀取自己的數據
CREATE POLICY "Users can read their own profile"
ON user_profiles FOR SELECT
USING (auth.uid() = id);
```

### 2. API 請求失敗但沒有錯誤提示

**可能原因**：
- 網絡錯誤
- 認證錯誤
- 數據格式錯誤

**檢查方法**：
- 查看 Xcode 控制台日誌
- 應該看到詳細的請求/響應日誌

### 3. Supabase 配置錯誤

**可能原因**：
- URL 錯誤
- API Key 錯誤
- 表結構不匹配

**檢查方法**：
- 查看 `SupabaseConfig.swift`
- 確認 URL 和 Key 正確

---

## ✅ 已添加的調試日誌

### 請求日誌：
```
🌐 Making POST request to: [URL]
📤 Request body: [JSON]
   Headers: Authorization=Bearer [token], apikey=[anonKey]
```

### 響應日誌：
```
📥 Response status: [status code]
📥 Response body: [JSON]
```

### 錯誤日誌：
```
❌ API error ([status code]): [error message]
```

---

## 🔧 診斷步驟

### Step 1: 檢查 RLS 策略

1. **登錄 Supabase Dashboard**
2. **進入 Table Editor** → `user_profiles`
3. **點擊 "Policies" 標籤**
4. **檢查是否有以下策略**：
   - INSERT policy
   - UPDATE policy
   - SELECT policy

**如果沒有策略**：
- 需要創建策略（見下方 SQL）

### Step 2: 運行應用並查看日誌

1. **運行應用**
2. **登錄**
3. **填寫數據**
4. **查看 Xcode 控制台**

**應該看到**：
```
💾 saveUserProfile called for user: [user-id]
🌐 Making POST request to: [URL]
📤 Request body: [JSON]
📥 Response status: 201
✅ Profile created in Supabase successfully
```

**如果看到錯誤**：
- 檢查錯誤訊息
- 檢查 RLS 策略
- 檢查 Supabase 配置

### Step 3: 檢查 Supabase Dashboard

1. **登錄 Supabase Dashboard**
2. **進入 Table Editor** → `user_profiles`
3. **檢查是否有數據**

**如果沒有數據**：
- 檢查 RLS 策略
- 檢查 API 日誌
- 檢查錯誤訊息

---

## 🔧 修復 RLS 策略

### 如果 RLS 策略缺失或錯誤：

1. **登錄 Supabase Dashboard**
2. **進入 SQL Editor**
3. **運行以下 SQL**：

```sql
-- 啟用 RLS
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;

-- 刪除現有策略（如果有）
DROP POLICY IF EXISTS "Users can insert their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can update their own profile" ON user_profiles;
DROP POLICY IF EXISTS "Users can read their own profile" ON user_profiles;

-- 創建 INSERT 策略
CREATE POLICY "Users can insert their own profile"
ON user_profiles FOR INSERT
WITH CHECK (auth.uid()::text = id::text);

-- 創建 UPDATE 策略
CREATE POLICY "Users can update their own profile"
ON user_profiles FOR UPDATE
USING (auth.uid()::text = id::text);

-- 創建 SELECT 策略
CREATE POLICY "Users can read their own profile"
ON user_profiles FOR SELECT
USING (auth.uid()::text = id::text);
```

**注意**：
- `auth.uid()` 返回 UUID
- `id` 字段也是 UUID
- 需要轉換為 text 進行比較

---

## 🔍 檢查 Supabase 配置

### 檢查 SupabaseConfig.swift：

```swift
struct SupabaseConfig {
    static var projectURL: String {
        // 應該類似：https://xxxxx.supabase.co
        return UserDefaults.standard.string(forKey: "supabase_url") ?? ""
    }
    
    static var anonKey: String {
        // 應該是您的 Supabase anon key
        return UserDefaults.standard.string(forKey: "supabase_anon_key") ?? ""
    }
}
```

### 檢查配置是否正確：

1. **登錄 Supabase Dashboard**
2. **進入 Settings** → **API**
3. **確認**：
   - Project URL
   - anon/public key

---

## 📋 測試流程

### 測試 1: 檢查 RLS 策略

1. **登錄 Supabase Dashboard**
2. **檢查 RLS 策略**
3. **如果缺失，創建策略**

### 測試 2: 運行應用

1. **運行應用**
2. **登錄**
3. **填寫數據**
4. **查看控制台日誌**

### 測試 3: 驗證數據

1. **檢查 Supabase Dashboard**
2. **確認數據存在**

---

## 🎯 最可能的問題

**RLS 策略缺失或錯誤** - 這是導致數據無法保存的最常見原因。

**解決方案**：
1. 檢查 RLS 策略
2. 如果缺失，創建策略（見上方 SQL）
3. 重新測試

---

## ✅ 下一步

1. **檢查 RLS 策略**（最重要！）
2. **運行應用並查看日誌**
3. **確認數據保存**
4. **如果仍有問題，檢查錯誤訊息**
