# Apple Sign In Supabase OAuth 修復指南

## ❌ 問題

**錯誤訊息**：
```
OAuth error: {"error":"invalid request","error_description":"Unacceptable audience in id_token: [com.resonance.lifelab]"}
```

**原因**：
- Supabase 期望的 `audience` 是 **Service ID**，但收到的是 **Bundle ID**
- Apple ID token 中的 `audience` 字段是 Bundle ID (`com.resonance.lifelab`)
- Supabase 需要配置 Service ID 才能驗證 Apple ID token

---

## 🔧 解決方案

### Step 1: 在 Apple Developer Portal 創建 Service ID

1. **登錄 Apple Developer Portal**
   - https://developer.apple.com/account
   - 選擇您的 Team

2. **創建 Service ID**
   - 進入 **Certificates, Identifiers & Profiles**
   - 點擊 **Identifiers** → **+**
   - 選擇 **Services IDs** → **Continue**
   - **Description**: `LifeLab Supabase Service`
   - **Identifier**: `com.resonance.lifelab.service` (或類似格式)
   - **Continue** → **Register**

3. **配置 Service ID**
   - 選擇剛創建的 Service ID
   - 勾選 **Sign In with Apple**
   - **Configure**
   - **Primary App ID**: 選擇您的 App ID (`com.resonance.lifelab`)
   - **Website URLs**:
     - **Domains and Subdomains**: `inlzhosqbccyynofbmjt.supabase.co`
     - **Return URLs**: `https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
   - **Save** → **Continue** → **Save**

### Step 2: 在 Supabase Dashboard 配置 Apple OAuth

1. **登錄 Supabase Dashboard**
   - https://supabase.com/dashboard
   - 選擇項目：`inlzhosqbccyynofbmjt`

2. **配置 Apple Provider**
   - 進入 **Authentication** → **Providers**
   - 找到 **Apple** → **Enable**
   - **Client ID (Service ID)**: 輸入您的 Service ID（例如：`com.resonance.lifelab.service`）
   - **Secret Key**: 輸入您的 Apple Private Key（JWT Secret）
   - **Save**

3. **驗證配置**
   - 確認 Service ID 與 Apple Developer Portal 中的一致
   - 確認 Return URL 正確

---

## 🔍 當前實現狀態

### Apple Sign In 流程：

1. **用戶點擊 Apple Sign In**
   - iOS 顯示 Apple 登錄界面
   - 用戶授權

2. **獲取 Apple ID Token**
   - Token 包含 `audience` 字段（Bundle ID）
   - Token 發送到 Supabase

3. **Supabase 驗證 Token**
   - Supabase 檢查 `audience` 是否匹配配置的 Service ID
   - 如果不匹配 → 錯誤：`Unacceptable audience`

4. **Fallback 機制**
   - 如果 Supabase OAuth 失敗
   - 應用使用本地會話
   - 數據保存到本地，但**不會同步到 Supabase**

---

## ⚠️ 當前限制

### 使用本地會話時：

- ✅ 應用可以正常使用
- ✅ 數據保存到本地（UserDefaults）
- ❌ **數據不會同步到 Supabase**
- ❌ 重新安裝應用後數據會丟失（除非配置 OAuth）

### 修復後（配置 OAuth 後）：

- ✅ 應用可以正常使用
- ✅ 數據保存到本地
- ✅ **數據同步到 Supabase**
- ✅ 重新安裝應用後數據可以恢復

---

## 📋 檢查清單

### Apple Developer Portal：
- [ ] Service ID 已創建
- [ ] Service ID 已啟用 "Sign In with Apple"
- [ ] Return URL 配置正確：`https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`
- [ ] Primary App ID 選擇正確：`com.resonance.lifelab`

### Supabase Dashboard：
- [ ] Apple Provider 已啟用
- [ ] Client ID (Service ID) 已配置
- [ ] Secret Key (JWT Secret) 已配置
- [ ] Return URL 匹配：`https://inlzhosqbccyynofbmjt.supabase.co/auth/v1/callback`

---

## 🔧 已實施的修復

### 1. 網絡重試機制
- ✅ 添加了自動重試（最多 3 次）
- ✅ 指數退避策略（2s, 4s, 6s）
- ✅ 更長的超時時間（30s request, 60s resource）

### 2. 改進的錯誤處理
- ✅ 檢測網絡錯誤並重試
- ✅ 區分網絡錯誤和其他錯誤
- ✅ 更詳細的錯誤訊息

### 3. 會話檢查
- ✅ 檢查是否有 Supabase session
- ✅ 如果沒有 session，跳過同步並提示用戶

### 4. 改進的日誌
- ✅ 詳細的錯誤訊息
- ✅ 配置指導
- ✅ 狀態提示

---

## 🎯 下一步

1. **配置 Apple OAuth**（見上方步驟）
2. **測試 Apple Sign In**
3. **確認數據同步到 Supabase**
4. **驗證數據恢復**

---

## 📝 注意事項

### 關於 Service ID：

- **格式**：通常是 `com.yourcompany.appname.service`
- **必須與 Supabase 配置一致**
- **必須在 Apple Developer Portal 中啟用 "Sign In with Apple"**

### 關於數據同步：

- **配置 OAuth 前**：數據只保存在本地
- **配置 OAuth 後**：數據同步到 Supabase
- **建議**：盡快配置 OAuth 以啟用數據同步

---

## ✅ 完成！

修復已完成，包括：
- ✅ 網絡重試機制
- ✅ 改進的錯誤處理
- ✅ 會話檢查
- ✅ 詳細的配置指導

**下一步**：配置 Apple OAuth 以啟用 Supabase 同步！
