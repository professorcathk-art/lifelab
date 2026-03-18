# LifeLab – 上傳至 App Store Connect 指南

## 健康檢查結果 ✅

- **Build**: Release 建置成功
- **Bundle ID**: `com.resonance.lifelab`
- **Version**: 1.3.3 (Build 7)
- **Linter**: 無錯誤

---

## 上傳前準備

### 1. Apple Developer 帳號

- 需為 [Apple Developer Program](https://developer.apple.com/programs/) 付費會員
- 年費約 $99 USD

### 2. App Store Connect 中的 App

1. 前往 [App Store Connect](https://appstoreconnect.apple.com)
2. 登入 Apple Developer 帳號
3. 點 **我的 App** → **+** → **新 App**
4. 填寫：
   - **平台**: iOS
   - **名稱**: LifeLab
   - **主要語言**: 繁體中文（或英文）
   - **套裝 ID**: `com.resonance.lifelab`（需與 Xcode 一致）
   - **SKU**: 例如 `lifelab-001`

---

## 方法一：使用 Xcode 上傳（建議）

### Step 1：設定簽章

1. 在 Xcode 開啟 `LifeLab.xcodeproj`
2. 選擇專案 **LifeLab** → **Signing & Capabilities**
3. 勾選 **Automatically manage signing**
4. **Team** 選擇你的 Apple Developer 團隊
5. **Bundle Identifier** 確認為 `com.resonance.lifelab`

### Step 2：建立 Archive

1. 選單 **Product** → **Destination** → **Any iOS Device (arm64)**
2. 選單 **Product** → **Archive**
3. 等待建置完成（約 1–3 分鐘）

### Step 3：上傳至 App Store Connect

1. Archive 完成後會開啟 **Organizer**
2. 選擇剛產生的 Archive
3. 點 **Distribute App**
4. 選擇 **App Store Connect** → **Next**
5. 選擇 **Upload** → **Next**
6. 勾選：
   - ✅ Upload your app's symbols
   - ✅ Manage Version and Build Number
7. 選擇 **Automatically manage signing** → **Next**
8. 檢查摘要 → **Upload**
9. 等待上傳完成

### Step 4：在 App Store Connect 提交審核

1. 回到 [App Store Connect](https://appstoreconnect.apple.com)
2. 進入 **LifeLab** → **App Store** 分頁
3. 等待 Build 處理完成（約 5–30 分鐘）
4. 在 **建置版本** 中選擇剛上傳的 Build
5. 填寫審核資訊：
   - 出口合規
   - 廣告識別碼（若有）
   - 內容版權
   - 年齡分級
6. 點 **提交以供審核**

---

## 方法二：使用 Transporter App

若 Xcode 上傳失敗，可用 Transporter：

1. 從 Mac App Store 安裝 [Transporter](https://apps.apple.com/app/transporter/id1450874784)
2. 在 Xcode 建立 Archive（同上 Step 2）
3. 在 Organizer 中選擇 Archive → **Distribute App** → **App Store Connect** → **Export**（不要選 Upload）
4. 儲存 IPA 檔
5. 開啟 Transporter，拖入 IPA 檔
6. 點 **交付** 上傳

---

## 常見問題

### 「No accounts with App Store Connect access」

- 確認 Apple ID 已加入 Developer Program
- Xcode → **Settings** → **Accounts** 檢查登入狀態

### 「Provisioning profile doesn't include signing certificate」

- 在 [Apple Developer](https://developer.apple.com/account) 建立 **Distribution** 憑證
- 或勾選 **Automatically manage signing** 讓 Xcode 處理

### 「Bundle ID 已被使用」

- 該 Bundle ID 已註冊，需使用正確的 Team 與 Provisioning Profile

### 「Invalid Swift Support」

- 通常為 Xcode 版本過舊，建議更新至最新版

---

## 版本與建置號碼規則

- **Version (MARKETING_VERSION)**: 使用者看到的版本，如 `1.3.3`
- **Build (CURRENT_PROJECT_VERSION)**: 每次上傳需遞增，如 `7` → `8`

每次提交新版本到 App Store Connect 前，請遞增 Build 號碼。
