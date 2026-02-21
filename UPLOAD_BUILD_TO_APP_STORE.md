# 上傳構建版本到 App Store Connect 指南

## ❌ 錯誤說明

**錯誤訊息**：`無法新增以供審查 - 必須選擇建置版本`

**原因**：在提交審查之前，您需要先上傳一個構建版本（Build）到 App Store Connect。

---

## 📋 解決步驟

### Step 1: 在 Xcode 中創建 Archive（歸檔）

#### 1.1 準備工作

1. **打開 Xcode**
   - 打開項目：`LifeLab/LifeLab.xcodeproj`

2. **選擇目標設備**
   - 在 Xcode 頂部工具欄
   - 選擇 **"Any iOS Device"** 或 **"Generic iOS Device"**
   - ⚠️ **不要選擇模擬器**（Simulator）

3. **檢查簽名設置**
   - 選擇 **LifeLab** target
   - 進入 **Signing & Capabilities** 標籤
   - 確認：
     - ✅ **Team** 已選擇（您的 Apple Developer Team）
     - ✅ **Bundle Identifier** 正確：`com.resonance.lifelab`
     - ✅ **Automatically manage signing** 已勾選

#### 1.2 創建 Archive

**方法 1：使用 Xcode 菜單（推薦）**

1. **選擇菜單**：
   - `Product` → `Archive`
   - 或按快捷鍵：`⌘ + B`（先構建），然後 `Product` → `Archive`

2. **等待構建完成**
   - Xcode 會自動構建項目
   - 構建完成後，**Organizer** 窗口會自動打開
   - 如果沒有自動打開：`Window` → `Organizer`

3. **驗證 Archive**
   - 在 Organizer 中，您應該看到：
     - Archive 名稱：`LifeLab`
     - 日期和時間
     - 版本號和構建號

**方法 2：使用命令行**

```bash
cd /Users/mickeylau/lifelab

# 清理構建
xcodebuild clean \
  -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab

# 創建 Archive
xcodebuild archive \
  -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -configuration Release \
  -archivePath ./build/LifeLab.xcarchive \
  -allowProvisioningUpdates
```

---

### Step 2: 上傳到 App Store Connect

#### 方法 1：使用 Xcode Organizer（推薦）

1. **打開 Organizer**
   - 在 Xcode 中：`Window` → `Organizer`
   - 或點擊 Archive 完成後的窗口

2. **選擇 Archive**
   - 在左側選擇最新的 Archive
   - 點擊 **"Distribute App"** 按鈕

3. **選擇分發方式**
   - 選擇 **"App Store Connect"**
   - 點擊 **"Next"**

4. **選擇上傳選項**
   - 選擇 **"Upload"**
   - 點擊 **"Next"**

5. **選擇選項**
   - ✅ **Upload your app's symbols**（推薦）
   - ✅ **Manage Version and Build Number**（如果需要）
   - 點擊 **"Next"**

6. **選擇簽名**
   - 選擇 **"Automatically manage signing"**（推薦）
   - 或選擇現有的 Provisioning Profile
   - 點擊 **"Next"**

7. **審查並上傳**
   - 檢查所有設置
   - 點擊 **"Upload"**
   - 等待上傳完成（可能需要幾分鐘）

8. **上傳成功**
   - 您會看到 "Upload Successful" 訊息
   - 點擊 **"Done"**

#### 方法 2：使用 Transporter App

1. **下載 Transporter**
   - 從 Mac App Store 下載 **Transporter**（免費）

2. **導出 IPA**
   - 在 Xcode Organizer 中
   - 選擇 Archive → **"Distribute App"**
   - 選擇 **"App Store Connect"** → **"Export"**
   - 保存 IPA 文件

3. **使用 Transporter 上傳**
   - 打開 Transporter
   - 拖拽 IPA 文件到 Transporter
   - 點擊 **"Deliver"**
   - 等待上傳完成

#### 方法 3：使用命令行（高級）

```bash
# 使用 altool（需要先安裝命令行工具）
xcrun altool --upload-app \
  --type ios \
  --file "path/to/your/app.ipa" \
  --username "your-apple-id@email.com" \
  --password "app-specific-password"
```

---

### Step 3: 在 App Store Connect 中選擇構建版本

#### 3.1 等待處理完成

1. **登錄 App Store Connect**
   - 訪問：https://appstoreconnect.apple.com
   - 登錄您的 Apple Developer 帳號

2. **進入應用**
   - 選擇您的應用：**LifeLab**

3. **檢查構建版本**
   - 進入 **"TestFlight"** 標籤
   - 或進入 **"App Store"** → **"版本"**
   - 查看 **"構建版本"** 部分

4. **等待處理**
   - 上傳後，Apple 需要處理構建版本
   - 通常需要 **10-30 分鐘**
   - 狀態會從 "Processing" 變為 "Ready to Submit"

#### 3.2 選擇構建版本

1. **進入版本頁面**
   - 在 App Store Connect 中
   - 選擇 **"App Store"** → **"版本"**
   - 或點擊 **"+ 版本"** 創建新版本

2. **選擇構建版本**
   - 在 **"構建版本"** 部分
   - 點擊 **"+ 構建版本"** 或 **"選擇構建版本"**
   - 選擇您剛上傳的構建版本
   - 點擊 **"完成"**

3. **填寫其他信息**
   - 確保所有必需欄位已填寫：
     - ✅ 應用描述
     - ✅ 關鍵字
     - ✅ 支援 URL
     - ✅ 隱私政策 URL
     - ✅ 應用圖標和截圖
     - ✅ 測試帳號（如果需要）

4. **提交審查**
   - 點擊 **"提交以供審查"**
   - 確認所有信息正確
   - 點擊 **"提交"**

---

## ⚠️ 常見問題

### 問題 1：找不到 "Archive" 選項

**原因**：選擇了模擬器而不是真實設備

**解決**：
- 在 Xcode 頂部工具欄
- 選擇 **"Any iOS Device"** 或 **"Generic iOS Device"**
- 然後再嘗試 `Product` → `Archive`

### 問題 2：簽名錯誤

**錯誤**：`Code signing is required`

**解決**：
1. 選擇 **LifeLab** target
2. **Signing & Capabilities** 標籤
3. 確認 **Team** 已選擇
4. 確認 **Bundle Identifier** 正確
5. 勾選 **"Automatically manage signing"**

### 問題 3：構建版本未出現在 App Store Connect

**原因**：Apple 還在處理構建版本

**解決**：
- 等待 **10-30 分鐘**
- 刷新 App Store Connect 頁面
- 檢查 **TestFlight** 標籤中的構建版本

### 問題 4：上傳失敗

**錯誤**：`Invalid Bundle` 或 `Missing Compliance`

**解決**：
1. 檢查 **Info.plist** 中的設置
2. 確認 **Export Compliance** 設置正確
3. 在 Xcode 中：**LifeLab** target → **Info** 標籤
4. 添加 **"ITSAppUsesNonExemptEncryption"** = **"NO"**（如果應用不使用加密）

---

## 📋 檢查清單

### 上傳前檢查

- [ ] Bundle Identifier 正確：`com.resonance.lifelab`
- [ ] 版本號已更新（如果需要）
- [ ] 構建號已更新（如果需要）
- [ ] 簽名設置正確
- [ ] Team 已選擇
- [ ] 選擇了 "Any iOS Device" 或 "Generic iOS Device"

### 上傳後檢查

- [ ] Archive 創建成功
- [ ] 上傳到 App Store Connect 成功
- [ ] 構建版本出現在 App Store Connect（等待處理）
- [ ] 構建版本狀態為 "Ready to Submit"
- [ ] 在版本頁面中選擇了構建版本
- [ ] 所有必需欄位已填寫
- [ ] 提交審查成功

---

## 🎯 快速步驟總結

1. **在 Xcode 中**：
   - 選擇 "Any iOS Device"
   - `Product` → `Archive`
   - 等待構建完成

2. **在 Organizer 中**：
   - 選擇 Archive
   - 點擊 "Distribute App"
   - 選擇 "App Store Connect" → "Upload"
   - 等待上傳完成

3. **在 App Store Connect 中**：
   - 等待構建版本處理完成（10-30 分鐘）
   - 進入版本頁面
   - 選擇構建版本
   - 提交審查

---

## ✅ 完成！

上傳構建版本後，您就可以在 App Store Connect 中選擇它並提交審查了！

**預計時間**：
- Archive 創建：5-10 分鐘
- 上傳：5-15 分鐘
- Apple 處理：10-30 分鐘
- **總計：約 20-55 分鐘**
