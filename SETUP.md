# Xcode 專案設置指南

## 方法 1：在 Xcode 中手動創建專案（推薦）

### 步驟 1：創建新專案
1. 打開 Xcode
2. 選擇 **File** → **New** → **Project**
3. 選擇 **iOS** → **App**
4. 點擊 **Next**

### 步驟 2：配置專案
- **Product Name**: `LifeLab`
- **Team**: 選擇您的開發團隊（或 None）
- **Organization Identifier**: `com.yourname`（例如：`com.lifelab`）
- **Interface**: **SwiftUI**
- **Language**: **Swift**
- **Storage**: 選擇 **None**（我們使用 UserDefaults）
- **取消勾選** "Include Tests"（可選）
- 點擊 **Next**

### 步驟 3：選擇保存位置
- 選擇 `/Users/mickeylau/lifelab` 作為專案位置
- **重要**：取消勾選 "Create Git repository"（避免與其他專案混亂）
- 點擊 **Create**

### 步驟 4：刪除默認文件
在 Xcode 專案導航器中，刪除以下默認文件：
- `ContentView.swift`（我們有自己的版本）
- `LifeLabApp.swift`（如果存在，我們會替換它）

### 步驟 5：添加現有文件
1. 在 Xcode 中，右鍵點擊專案名稱
2. 選擇 **Add Files to "LifeLab"...**
3. 選擇以下資料夾和文件：
   - `Models/` 資料夾
   - `ViewModels/` 資料夾
   - `Views/` 資料夾
   - `Services/` 資料夾
   - `Utilities/` 資料夾
   - `LifeLabApp.swift` 文件
4. 確保勾選 **"Copy items if needed"**
5. 確保 **"Create groups"** 被選中
6. 點擊 **Add**

### 步驟 6：設置 App 入口點
1. 在專案設置中，選擇 **LifeLab** target
2. 進入 **Info** 標籤
3. 確保 **Main Interface** 為空（SwiftUI 不需要）
4. 確認 `LifeLabApp.swift` 中的 `@main` 標記正確

### 步驟 7：設置最低部署版本
1. 選擇 **LifeLab** target
2. 進入 **General** 標籤
3. 將 **Minimum Deployments** 設為 **iOS 16.0**

### 步驟 8：運行專案
1. 選擇一個模擬器（例如：iPhone 15 Pro）
2. 點擊 **Run** 按鈕（⌘R）或按 **Play** 按鈕

## 方法 2：使用命令行創建（進階）

如果您熟悉命令行，可以使用以下腳本：

```bash
# 在 lifelab 目錄下運行
cd /Users/mickeylau/lifelab

# 創建 Xcode 專案（需要手動配置）
# 或者使用 xcodegen（如果已安裝）
```

## 常見問題

### 問題 1：找不到文件
- 確保所有文件都已添加到 Xcode 專案中
- 檢查文件是否在正確的資料夾中

### 問題 2：編譯錯誤
- 確保最低部署版本設為 iOS 16.0
- 清理構建文件夾：**Product** → **Clean Build Folder** (⇧⌘K)

### 問題 3：預覽不工作
- 確保使用 Xcode 14+ 版本
- 嘗試在模擬器中運行而不是預覽

### 問題 4：導航問題
- 確保所有 View 文件都正確導入
- 檢查 `ContentView.swift` 中的導航邏輯

## 驗證設置

運行專案後，您應該看到：
1. 初始掃描界面（興趣選擇）
2. 可以點擊關鍵詞進行選擇
3. 60 秒計時器開始計時
4. 完成後可以進入下一步

## 下一步

設置完成後，您可以：
1. 開始測試各個功能
2. 自定義 UI 設計
3. 整合實際的 AI API
4. 添加更多功能
