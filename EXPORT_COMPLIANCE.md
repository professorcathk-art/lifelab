# App Store Connect - 加密演算法問題解決指南

## ❓ 問題

**App Store Connect 詢問**：`App 會使用哪種加密演算法？`

這是關於 **Export Compliance**（出口合規）的問題。Apple 需要知道您的應用是否使用了加密，以符合美國的出口法規。

---

## ✅ 解決方案

### 對於大多數應用（包括 LifeLab）

**答案**：選擇 **"否"** 或 **"不使用加密"**

**原因**：
- LifeLab 只使用標準的 HTTPS/TLS 加密（系統提供的）
- 沒有使用自定義加密算法
- 沒有使用需要特別聲明的加密功能

---

## 📋 在 App Store Connect 中回答

### 方法 1：直接在 App Store Connect 中回答（推薦）

1. **登錄 App Store Connect**
   - 訪問：https://appstoreconnect.apple.com
   - 進入您的應用：LifeLab

2. **找到 Export Compliance 問題**
   - 在提交審查時，會看到這個問題
   - 或在 **"App 資訊"** → **"出口合規"** 部分

3. **選擇答案**
   - **"否，此 App 不使用加密"** 或
   - **"否，此 App 僅使用標準加密"**

4. **提交**

### 方法 2：在 Info.plist 中設置（自動回答）

為了避免每次都被詢問，可以在 Info.plist 中設置：

#### 選項 A：不使用加密（最簡單）

添加以下鍵值：

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

或使用 Build Settings：

在 Xcode 項目設置中：
1. 選擇 **LifeLab** target
2. **Info** 標籤
3. 添加新的鍵值：
   - Key: `ITSAppUsesNonExemptEncryption`
   - Type: `Boolean`
   - Value: `NO`

#### 選項 B：使用標準加密（HTTPS/TLS）

如果您的應用使用 HTTPS（大多數應用都使用），可以設置：

```xml
<key>ITSAppUsesNonExemptEncryption</key>
<false/>
```

**注意**：即使使用 HTTPS，也應該選擇 `false`，因為 HTTPS 是系統提供的標準加密，不需要特別聲明。

---

## 🔍 什麼情況下選擇 "是"？

只有在以下情況下才需要選擇 "是"：

1. **使用自定義加密算法**
   - 自己實現的加密算法
   - 非標準的加密方法

2. **使用需要出口許可的加密**
   - 軍用級加密
   - 某些強加密算法

3. **使用加密庫進行非標準加密**
   - 某些第三方加密庫
   - 非 HTTPS 的加密通信

**對於 LifeLab**：
- ✅ 只使用 HTTPS（Supabase API、AI API）
- ✅ 使用系統提供的加密
- ✅ 不需要選擇 "是"

---

## 📝 在 Xcode 中設置（推薦）

### Step 1: 打開項目設置

1. **打開 Xcode**
   - 打開項目：`LifeLab/LifeLab.xcodeproj`

2. **選擇 Target**
   - 在項目導航器中，選擇 **LifeLab** target
   - 點擊 **Info** 標籤

### Step 2: 添加鍵值

1. **添加新鍵值**
   - 點擊 **"+"** 按鈕
   - 輸入鍵名：`ITSAppUsesNonExemptEncryption`
   - 選擇類型：`Boolean`
   - 設置值：`NO`

2. **或者使用 Build Settings**
   - 選擇 **Build Settings** 標籤
   - 搜索：`ITSAppUsesNonExemptEncryption`
   - 設置為：`NO`

### Step 3: 驗證

1. **檢查設置**
   - 確認 `ITSAppUsesNonExemptEncryption` = `NO`

2. **重新構建**
   - `Product` → `Clean Build Folder`（⇧⌘K）
   - `Product` → `Archive`

---

## 🎯 快速答案

### 在 App Store Connect 中：

**問題**：`App 會使用哪種加密演算法？`

**答案**：**"否，此 App 不使用加密"** 或 **"否，此 App 僅使用標準加密"**

**原因**：
- LifeLab 只使用 HTTPS（系統提供的標準加密）
- 沒有使用自定義加密算法
- 符合大多數應用的情況

---

## ⚠️ 常見問題

### 問題 1: 我使用 HTTPS，應該選擇什麼？

**答案**：選擇 **"否"**

**原因**：HTTPS 是系統提供的標準加密，不需要特別聲明。只有在使用自定義加密或需要出口許可的加密時才需要選擇 "是"。

### 問題 2: 我使用 Supabase，需要選擇 "是" 嗎？

**答案**：選擇 **"否"**

**原因**：Supabase 使用標準的 HTTPS/TLS 加密，這是系統提供的，不需要特別聲明。

### 問題 3: 我使用 AI API，需要選擇 "是" 嗎？

**答案**：選擇 **"否"**

**原因**：API 通信使用標準的 HTTPS，不需要特別聲明。

---

## ✅ 檢查清單

- [ ] 確認應用只使用標準 HTTPS/TLS
- [ ] 在 Info.plist 中設置 `ITSAppUsesNonExemptEncryption` = `NO`（可選）
- [ ] 在 App Store Connect 中選擇 "否"
- [ ] 重新構建 Archive（如果修改了 Info.plist）
- [ ] 上傳並驗證

---

## 📚 參考資料

- **Apple 官方文檔**：https://developer.apple.com/documentation/security/preparing_your_app_to_work_with_encryption
- **Export Compliance FAQ**：https://developer.apple.com/support/export-compliance/

---

## ✅ 完成！

對於 LifeLab，選擇 **"否"** 即可！

**原因總結**：
- ✅ 只使用標準 HTTPS（系統提供）
- ✅ 沒有自定義加密算法
- ✅ 符合大多數應用的情況
- ✅ 不需要出口許可
