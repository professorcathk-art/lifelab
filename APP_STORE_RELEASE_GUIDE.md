# App Store 發布完整指南

**當前版本**：1.3.2  
**當前構建號**：5  
**建議新版本**：1.3.3  
**建議新構建號**：6

---

## 📋 發布前檢查清單

### ✅ 已完成
- [x] 代碼健康檢查通過
- [x] 無編譯錯誤
- [x] 無 Linter 警告
- [x] 所有功能測試通過
- [x] Supabase SDK 遷移完成

### 📝 需要完成
- [ ] 更新版本號和構建號
- [ ] 創建 Archive
- [ ] 驗證 Archive
- [ ] 上傳到 App Store Connect
- [ ] 配置 App Store Connect
- [ ] 提交審核

---

## 🔢 步驟 1：更新版本號和構建號

### 方法 1：在 Xcode 中更新（推薦）

1. **打開 Xcode**
   ```bash
   open LifeLab/LifeLab.xcodeproj
   ```

2. **選擇項目**
   - 在左側導航欄點擊項目名稱 "LifeLab"
   - 選擇 "LifeLab" target
   - 點擊 "General" 標籤

3. **更新版本號**
   - **Marketing Version**：`1.3.2` → `1.3.3`
   - **Current Project Version (Build)**：`5` → `6`

4. **或者直接編輯 project.pbxproj**
   ```bash
   # 備份文件
   cp LifeLab/LifeLab.xcodeproj/project.pbxproj LifeLab/LifeLab.xcodeproj/project.pbxproj.backup
   
   # 更新版本號（1.3.2 → 1.3.3）
   sed -i '' 's/MARKETING_VERSION = 1.3.2;/MARKETING_VERSION = 1.3.3;/g' LifeLab/LifeLab.xcodeproj/project.pbxproj
   
   # 更新構建號（5 → 6）
   sed -i '' 's/CURRENT_PROJECT_VERSION = 5;/CURRENT_PROJECT_VERSION = 6;/g' LifeLab/LifeLab.xcodeproj/project.pbxproj
   ```

### 方法 2：使用命令行（快速）

```bash
cd /Users/mickeylau/lifelab

# 備份
cp LifeLab/LifeLab.xcodeproj/project.pbxproj LifeLab/LifeLab.xcodeproj/project.pbxproj.backup

# 更新版本號：1.3.2 → 1.3.3
sed -i '' 's/MARKETING_VERSION = 1.3.2;/MARKETING_VERSION = 1.3.3;/g' LifeLab/LifeLab.xcodeproj/project.pbxproj

# 更新構建號：5 → 6
sed -i '' 's/CURRENT_PROJECT_VERSION = 5;/CURRENT_PROJECT_VERSION = 6;/g' LifeLab/LifeLab.xcodeproj/project.pbxproj

# 驗證更改
grep -E "MARKETING_VERSION|CURRENT_PROJECT_VERSION" LifeLab/LifeLab.xcodeproj/project.pbxproj | head -4
```

**預期輸出**：
```
MARKETING_VERSION = 1.3.3;
CURRENT_PROJECT_VERSION = 6;
MARKETING_VERSION = 1.3.3;
CURRENT_PROJECT_VERSION = 6;
```

---

## 📦 步驟 2：創建 Archive

### 在 Xcode 中創建

1. **選擇設備**
   - 在 Xcode 頂部選擇 "Any iOS Device (arm64)"

2. **創建 Archive**
   - 菜單：`Product` → `Archive`
   - 或按快捷鍵：`Cmd + B` 然後 `Product` → `Archive`

3. **等待構建完成**
   - 構建時間：約 2-5 分鐘
   - 成功後會自動打開 Organizer 窗口

### 使用命令行創建

```bash
cd /Users/mickeylau/lifelab

# 清理之前的構建
xcodebuild clean -project LifeLab/LifeLab.xcodeproj -scheme LifeLab

# 創建 Archive
xcodebuild archive \
  -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -configuration Release \
  -archivePath ./build/LifeLab.xcarchive \
  -allowProvisioningUpdates

# Archive 將保存在：./build/LifeLab.xcarchive
```

---

## ✅ 步驟 3：驗證 Archive

### 在 Xcode 中驗證

1. **打開 Organizer**
   - `Window` → `Organizer`
   - 或 Archive 完成後自動打開

2. **選擇 Archive**
   - 選擇最新的 Archive（版本 1.3.3，構建號 6）

3. **驗證**
   - 點擊 "Validate App"
   - 選擇 "Automatically manage signing"
   - 點擊 "Validate"
   - 等待驗證完成（約 1-2 分鐘）

### 使用命令行驗證

```bash
# 驗證 Archive
xcodebuild -validateArchive \
  -archivePath ./build/LifeLab.xcarchive

# 檢查 Archive 內容
xcodebuild -showBuildSettings \
  -archivePath ./build/LifeLab.xcarchive
```

---

## 📤 步驟 4：上傳到 App Store Connect

### 在 Xcode 中上傳

1. **選擇 Archive**
   - 在 Organizer 中選擇最新的 Archive

2. **分發 App**
   - 點擊 "Distribute App"
   - 選擇 "App Store Connect"
   - 點擊 "Next"

3. **選擇分發選項**
   - 選擇 "Upload"
   - 點擊 "Next"

4. **選擇選項**
   - ✅ "Upload your app's symbols"
   - ✅ "Manage Version and Build Number"（如果需要）
   - 點擊 "Next"

5. **自動簽名**
   - 選擇 "Automatically manage signing"
   - 點擊 "Next"

6. **審查並上傳**
   - 檢查摘要信息
   - 點擊 "Upload"
   - 等待上傳完成（約 5-10 分鐘）

### 使用命令行上傳

```bash
# 使用 altool（需要 App Store Connect API Key）
xcrun altool --upload-app \
  --type ios \
  --file "./build/LifeLab.ipa" \
  --apiKey YOUR_API_KEY \
  --apiIssuer YOUR_ISSUER_ID

# 或使用 Transporter（推薦）
# 1. 導出 IPA
xcodebuild -exportArchive \
  -archivePath ./build/LifeLab.xcarchive \
  -exportPath ./build \
  -exportOptionsPlist ExportOptions.plist

# 2. 使用 Transporter 上傳
open -a Transporter ./build/LifeLab.ipa
```

---

## 🌐 步驟 5：配置 App Store Connect

### 1. 登錄 App Store Connect
- 訪問：https://appstoreconnect.apple.com
- 使用 Apple Developer 帳號登錄

### 2. 選擇應用
- 點擊 "我的 App"
- 選擇 "LifeLab"

### 3. 創建新版本
- 點擊 "+ 版本或平台"
- 輸入版本號：`1.3.3`
- 點擊 "創建"

### 4. 選擇構建
- 在 "構建" 部分點擊 "+"
- 選擇構建號 `6`（對應版本 1.3.3）
- 點擊 "完成"

### 5. 填寫版本信息

#### 版本發布說明
```
🎉 新版本更新：

✨ 新功能：
- 遷移到官方 Supabase Swift SDK 2.5.1，提升穩定性和性能
- 優化數據同步機制，確保數據安全備份
- 改進本地優先策略，提供更流暢的用戶體驗

🐛 修復：
- 修復數據同步問題
- 改進認證流程
- 優化錯誤處理

🔧 技術改進：
- 使用官方 Supabase SDK，自動管理認證令牌
- 簡化 JSONB 數據處理
- 改進網絡錯誤處理和重試機制
```

#### 關鍵詞
```
健康,生活規劃,個人成長,目標設定,任務管理,價值觀,天賦,興趣,AI分析
```

#### 宣傳文本（可選）
```
LifeLab 幫助你發現真正的自己，制定個人化的生命藍圖，並通過 AI 驅動的分析和建議，實現你的理想生活。
```

### 6. 上傳截圖（如果需要更新）
- 添加應用截圖
- iPhone 6.7" 顯示屏（1290 x 2796）
- iPhone 6.5" 顯示屏（1284 x 2778）
- iPad Pro（2048 x 2732）

### 7. 審查信息
- **聯繫人信息**：已填寫
- **演示帳號**：如果需要，提供測試帳號
- **備註**：說明主要變更

---

## 📝 步驟 6：提交審核

### 1. 檢查清單
- [ ] 版本號正確（1.3.3）
- [ ] 構建號正確（6）
- [ ] 版本發布說明已填寫
- [ ] 截圖已上傳（如果需要）
- [ ] 審查信息完整

### 2. 提交審核
- 點擊 "提交以供審核"
- 確認所有必填項已填寫
- 點擊 "提交"

### 3. 等待審核
- **審核時間**：通常 24-48 小時
- **狀態**：可在 App Store Connect 查看
- **通知**：審核結果會發送到註冊郵箱

---

## 🔄 版本號規則

### 版本號格式：`主版本.次版本.修補版本`
- **主版本**：重大更新（如 2.0.0）
- **次版本**：新功能（如 1.4.0）
- **修補版本**：Bug 修復和小改進（如 1.3.3）

### 構建號規則
- **每次上傳必須遞增**
- **即使版本號相同，構建號也要增加**
- **建議**：每次提交 +1

### 本次更新建議
- **當前**：1.3.2 (Build 5)
- **建議**：1.3.3 (Build 6)
- **原因**：Supabase SDK 遷移是重要改進，但屬於技術優化，使用修補版本

---

## 📚 參考資源

- [App Store Connect 幫助](https://help.apple.com/app-store-connect/)
- [App Store 審核指南](https://developer.apple.com/app-store/review/guidelines/)
- [Xcode Archive 文檔](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

---

## ✅ 完成檢查清單

發布前確認：
- [ ] 版本號已更新（1.3.3）
- [ ] 構建號已更新（6）
- [ ] Archive 已創建
- [ ] Archive 已驗證
- [ ] 已上傳到 App Store Connect
- [ ] App Store Connect 配置完成
- [ ] 已提交審核

**準備就緒！可以開始發布流程了！** 🚀
