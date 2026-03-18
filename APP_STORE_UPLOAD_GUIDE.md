# App Store Connect 上傳指南（更新版本）

**當前版本**：1.3.3  
**當前構建號**：6  
**本次更新**：修復生命藍圖重新生成 Bug

---

## 📋 上傳前檢查清單

### ✅ 已完成
- [x] 版本號已更新（1.3.3）
- [x] 構建號已更新（6）
- [x] 所有 Bug 已修復
- [x] 健康檢查通過
- [x] 代碼已同步到 GitHub

### 📝 需要完成
- [ ] 在 Xcode 中創建 Archive
- [ ] 驗證 Archive
- [ ] 上傳到 App Store Connect
- [ ] 配置 App Store Connect（如果版本已存在，選擇新構建）
- [ ] 提交審核

---

## 🔢 步驟 1：確認版本號和構建號

### 檢查當前版本

```bash
cd /Users/mickeylau/lifelab
grep -E "MARKETING_VERSION|CURRENT_PROJECT_VERSION" LifeLab/LifeLab.xcodeproj/project.pbxproj | head -4
```

**預期輸出**：
```
MARKETING_VERSION = 1.3.3;
CURRENT_PROJECT_VERSION = 6;
MARKETING_VERSION = 1.3.3;
CURRENT_PROJECT_VERSION = 6;
```

**如果版本號不正確**，更新：
```bash
# 更新版本號（如果需要）
sed -i '' 's/MARKETING_VERSION = 1.3.2;/MARKETING_VERSION = 1.3.3;/g' LifeLab/LifeLab.xcodeproj/project.pbxproj

# 更新構建號（如果需要）
sed -i '' 's/CURRENT_PROJECT_VERSION = 5;/CURRENT_PROJECT_VERSION = 6;/g' LifeLab/LifeLab.xcodeproj/project.pbxproj
```

---

## 📦 步驟 2：在 Xcode 中創建 Archive

### 2.1 打開項目

```bash
open LifeLab/LifeLab.xcodeproj
```

### 2.2 選擇設備

1. 在 Xcode 頂部工具欄
2. 選擇 **"Any iOS Device (arm64)"**
   - ⚠️ **不要選擇 Simulator**
   - ⚠️ **必須選擇 "Any iOS Device"**

### 2.3 清理構建（可選但推薦）

1. 菜單：`Product` → `Clean Build Folder`
2. 或快捷鍵：`Shift + Cmd + K`

### 2.4 創建 Archive

1. 菜單：`Product` → `Archive`
2. 或快捷鍵：`Cmd + B` 然後 `Product` → `Archive`
3. 等待構建完成（約 2-5 分鐘）

**成功後**：
- Xcode 會自動打開 **Organizer** 窗口
- 顯示最新的 Archive（版本 1.3.3，構建號 6）

---

## ✅ 步驟 3：驗證 Archive

### 3.1 在 Organizer 中驗證

1. **打開 Organizer**（如果沒有自動打開）
   - `Window` → `Organizer`
   - 或快捷鍵：`Cmd + Shift + 9`

2. **選擇 Archive**
   - 選擇最新的 Archive（版本 1.3.3，構建號 6）
   - 確認信息正確

3. **驗證 App**
   - 點擊 **"Validate App"** 按鈕
   - 選擇 **"Automatically manage signing"**
   - 點擊 **"Validate"**
   - 等待驗證完成（約 1-2 分鐘）

**驗證成功**：
- ✅ 顯示 "Validation successful"
- ✅ 可以繼續上傳

**驗證失敗**：
- ❌ 查看錯誤信息
- ❌ 修復問題後重新 Archive

---

## 📤 步驟 4：上傳到 App Store Connect

### 4.1 分發 App

1. **在 Organizer 中選擇 Archive**
2. **點擊 "Distribute App"** 按鈕
3. **選擇分發方式**：
   - 選擇 **"App Store Connect"**
   - 點擊 **"Next"**

### 4.2 選擇分發選項

1. **選擇 "Upload"**
   - ✅ 選擇 "Upload"
   - ❌ 不要選擇 "Export"（那是用於 Ad Hoc 或 Enterprise）
   - 點擊 **"Next"**

### 4.3 選擇選項

1. **勾選選項**：
   - ✅ **"Upload your app's symbols"**（推薦）
   - ✅ **"Manage Version and Build Number"**（如果需要）
   - 點擊 **"Next"**

### 4.4 自動簽名

1. **選擇 "Automatically manage signing"**
2. 點擊 **"Next"**

### 4.5 審查並上傳

1. **檢查摘要信息**：
   - 版本號：1.3.3
   - 構建號：6
   - Bundle ID：com.resonance.lifelab

2. **點擊 "Upload"**
3. **等待上傳完成**（約 5-10 分鐘）

**上傳成功**：
- ✅ 顯示 "Upload successful"
- ✅ Archive 旁邊顯示 "Uploaded"

---

## 🌐 步驟 5：在 App Store Connect 中配置

### 5.1 登錄 App Store Connect

1. 訪問：https://appstoreconnect.apple.com
2. 使用 Apple Developer 帳號登錄
3. 點擊 **"我的 App"**
4. 選擇 **"LifeLab"**

### 5.2 選擇版本或創建新版本

#### 情況 A：版本 1.3.3 已存在

1. **進入版本 1.3.3**
2. **在 "構建" 部分**：
   - 點擊 **"+"** 按鈕
   - 選擇構建號 **6**
   - 點擊 **"完成"**

#### 情況 B：版本 1.3.3 不存在

1. **點擊 "+ 版本或平台"**
2. **輸入版本號**：`1.3.3`
3. **點擊 "創建"**
4. **在 "構建" 部分**：
   - 點擊 **"+"** 按鈕
   - 選擇構建號 **6**
   - 點擊 **"完成"**

### 5.3 更新版本發布說明

**此版本的新增功能**：
```
🎉 數據同步優化與穩定性提升

✨ 新功能與改進：
- 🔄 更穩定的數據同步：優化了數據備份機制，確保您的資料安全保存到雲端
- ⚡ 更流暢的使用體驗：改進本地數據處理，應用響應速度更快
- 🔐 更可靠的登錄系統：優化認證流程，登錄更穩定順暢
- 📱 離線使用支持：即使沒有網絡，也能正常使用應用並保存數據

🐛 問題修復：
- 修復生命藍圖重新生成問題，確保您的計劃不會丟失
- 修復數據同步問題，確保資料不會丟失
- 改進錯誤處理機制，應用運行更穩定
- 優化網絡連接處理，減少連接錯誤

🔧 技術優化：
- 升級後端服務架構，提升整體性能
- 改進數據處理效率，減少載入時間

感謝您使用 LifeLab！我們持續改進應用，為您提供更好的體驗。
```

### 5.4 檢查其他信息

- [ ] 截圖已上傳（如果需要更新）
- [ ] 應用描述正確
- [ ] 關鍵詞正確
- [ ] 支持 URL 正確
- [ ] 年齡分級正確
- [ ] 版權信息正確

---

## 📝 步驟 6：提交審核

### 6.1 檢查清單

發布前確認：
- [ ] 版本號正確（1.3.3）
- [ ] 構建號正確（6）
- [ ] 版本發布說明已填寫
- [ ] 構建已選擇
- [ ] 所有必填項已填寫

### 6.2 提交審核

1. **滾動到頁面底部**
2. **點擊 "提交以供審核"**
3. **確認所有信息**
4. **點擊 "提交"**

### 6.3 等待審核

- **審核時間**：通常 24-48 小時
- **狀態**：可在 App Store Connect 查看
- **通知**：審核結果會發送到註冊郵箱

---

## 🔄 如果版本 1.3.3 已存在

### 選項 1：使用現有版本（推薦）

1. **進入版本 1.3.3**
2. **移除舊構建**（如果有的話）
3. **添加新構建 6**
4. **更新版本發布說明**（添加本次修復內容）
5. **提交審核**

### 選項 2：創建新版本 1.3.4

如果不想修改現有版本：

1. **更新版本號**：1.3.3 → 1.3.4
2. **更新構建號**：6 → 7
3. **重新 Archive**
4. **上傳新版本**

---

## 📊 上傳狀態檢查

### 在 App Store Connect 中檢查

1. **進入應用**
2. **點擊 "TestFlight" 標籤**
3. **查看 "構建" 部分**
4. **應該看到構建號 6**：
   - 狀態：Processing（處理中）或 Ready to Submit（準備提交）

**處理時間**：
- 通常 5-15 分鐘
- 處理完成後狀態變為 "Ready to Submit"

---

## ⚠️ 常見問題

### Q1: Archive 失敗

**A**: 
- 檢查是否選擇了 "Any iOS Device"
- 清理構建文件夾（Product → Clean Build Folder）
- 檢查證書和配置文件

### Q2: 驗證失敗

**A**:
- 查看錯誤信息
- 檢查 Bundle ID 是否正確
- 檢查證書是否有效

### Q3: 上傳失敗

**A**:
- 檢查網絡連接
- 檢查 Apple Developer 帳號狀態
- 嘗試重新上傳

### Q4: 構建號已存在

**A**:
- 更新構建號（6 → 7）
- 重新 Archive 和上傳

---

## ✅ 完成檢查清單

- [ ] 版本號確認（1.3.3）
- [ ] 構建號確認（6）
- [ ] Archive 已創建
- [ ] Archive 已驗證
- [ ] 已上傳到 App Store Connect
- [ ] 構建處理完成
- [ ] 已選擇構建號 6
- [ ] 版本發布說明已更新
- [ ] 已提交審核

---

## 📚 參考資源

- [App Store Connect 幫助](https://help.apple.com/app-store-connect/)
- [Xcode Archive 文檔](https://developer.apple.com/documentation/xcode/distributing-your-app-for-beta-testing-and-releases)

---

**準備就緒！可以開始上傳流程了！** 🚀
