# LifeLab 測試指南

## 已完成的功能

### ✅ 1. 生成生命藍圖按鈕顯示預計時間
- 在 `PaymentView` 中，生成生命藍圖按鈕現在顯示 "預計需要 2-3 分鐘"
- 位置：付款頁面的 "跳過付款並生成生命藍圖" 按鈕

### ✅ 2. 基礎用戶信息頁面
- 新增 `BasicInfoView` 作為問卷的第一步
- 收集信息：
  - 居住地區（必填）
  - 年齡（必填）
  - 稱呼（必填）
  - 職業（必填）
  - 年薪（USD，可選）
  - 家庭狀況（必填）
  - 學歷（必填）
- 這些信息會傳遞給 AI 用於生成更精準的建議

### ✅ 3. AI Prompt 優化
- 更新了 `AIService.generateLifeBlueprint` 的 prompt：
  - 要求 AI 考慮用戶的現實狀況（年齡、職業、學歷、家庭狀況、居住地區）
  - 禁止過度樂觀或不切實際的建議
  - 要求使用 USD 美元為單位並明確標註 currency
  - 要求提供當地真實市場數據和例子
  - 只生成 3 個方向（不是 5 個）

### ✅ 4. 編輯生命藍圖頁面改進
- 新增頂部 Save 按鈕
- 新版本生成時，方向會增量添加到現有方向（不替換）
- 每次生成新版本只生成 3 個方向
- 可以查看和編輯所有版本的方向

### ✅ 5. 今日任務左滑刪除
- 在 `TodayTasksSection` 中，每個任務支持左滑刪除
- 使用 SwiftUI 的 `swipeActions` modifier

### ✅ 6. 登錄系統（基礎版本）
- 創建了 `AuthService` 和 `LoginView`
- 支持 Email 登錄/註冊（目前為模擬實現）
- 支持 Apple Sign In
- 登錄狀態會保存到 UserDefaults

## 如何測試

### 在 iPhone 15 Pro 上測試

#### 方法 1: 使用 Xcode（推薦）

1. **連接設備**：
   - 使用 USB 線連接 iPhone 15 Pro 到 Mac
   - 在 iPhone 上信任電腦（如果首次連接）
   - 在 Xcode 中選擇您的 iPhone 15 Pro 作為目標設備

2. **配置 Signing**：
   - 在 Xcode 中選擇項目
   - 進入 "Signing & Capabilities"
   - 選擇您的 Team
   - 添加 "Sign in with Apple" capability（如果需要測試 Apple Sign In）

3. **運行應用**：
   - 點擊 Run 按鈕（或按 Cmd+R）
   - 應用會編譯並安裝到您的設備上
   - 首次運行時，需要在 iPhone 上信任開發者證書：
     - 設置 > 通用 > VPN與設備管理
     - 選擇您的開發者證書
     - 點擊 "信任"

#### 方法 2: 使用命令行

```bash
# 1. 列出可用設備
xcrun xctrace list devices

# 2. 找到您的 iPhone 15 Pro 的 UDID

# 3. 編譯並安裝到設備
xcodebuild -project LifeLab/LifeLab.xcodeproj \
  -scheme LifeLab \
  -sdk iphoneos \
  -destination 'platform=iOS,id=YOUR_DEVICE_UDID' \
  build

# 4. 或使用 xcodebuild install（需要配置）
```

### 測試流程

#### 1. 測試登錄
- **Email 登錄**：
  - 輸入任何 email（例如：test@example.com）
  - 輸入任何 password（例如：123456）
  - 點擊 "登錄"
  - ✅ 應該成功登錄並進入應用

- **Apple Sign In**：
  - 點擊 "Sign in with Apple" 按鈕
  - 使用真實的 Apple ID 登錄
  - ✅ 應該成功登錄並進入應用

#### 2. 測試基礎信息頁面
- 第一個頁面是基礎信息頁面
- 填寫：
  - 居住地區：選擇一個地區（例如：香港）
  - 年齡：輸入數字（例如：28）
  - 稱呼：輸入名字（例如：小明）
  - 職業：輸入職業（例如：軟體工程師）
  - 年薪（可選）：輸入數字（例如：50000）
  - 家庭狀況：選擇一個選項
  - 學歷：選擇一個選項
- 點擊 "繼續"
- ✅ 應該進入興趣選擇頁面

#### 3. 測試生命藍圖生成
- 完成所有問卷步驟（興趣、優勢、價值觀）
- 在付款頁面，查看 "跳過付款並生成生命藍圖" 按鈕
- ✅ 應該看到 "預計需要 2-3 分鐘" 的提示文字
- 點擊按鈕開始生成
- ✅ 應該看到加載動畫，等待 2-3 分鐘

#### 4. 測試編輯生命藍圖
- 在首頁點擊編輯按鈕（鉛筆圖標）
- ✅ 應該看到頂部的 "保存" 按鈕
- ✅ 應該看到所有方向，可以編輯、排序、設為最愛

#### 5. 測試新版本生成
- 完成深化探索的所有步驟
- 點擊 "生成更新版生命藍圖"
- ✅ 應該只生成 3 個新方向
- ✅ 生成後自動導航到編輯頁面
- ✅ 新方向應該增量添加到現有方向（不替換）

#### 6. 測試今日任務左滑刪除
- 進入任務管理頁面
- 切換到 "今日任務" 標籤
- 如果有任務，左滑任何任務
- ✅ 應該看到紅色的 "刪除" 按鈕
- 點擊刪除
- ✅ 任務應該被刪除

## 注意事項

### 登錄系統
- **Email 登錄**：目前是模擬實現，任何 email/password 都可以登錄
- **Apple Sign In**：需要真實的 Apple ID，並且需要在 Xcode 中配置 Signing & Capabilities
- **數據保存**：登錄後，用戶數據會保存到 UserDefaults（本地存儲）

### 測試建議
1. **首次測試**：建議先清除應用數據，從頭開始測試完整流程
2. **數據持久化**：登錄後，數據會保存到本地，下次打開應用會自動登錄
3. **登出**：目前沒有登出按鈕，可以在設定頁面添加（需要實現）

## 後續改進建議

1. **真實的 Email 認證**：
   - 集成 Firebase Auth 或其他認證服務
   - 實現密碼重置功能

2. **數據同步**：
   - 將用戶數據同步到雲端（Firebase、AWS 等）
   - 實現多設備同步

3. **登出功能**：
   - 在設定頁面添加登出按鈕
   - 清除本地數據

4. **Apple Sign In 配置**：
   - 在 Xcode 中配置 Signing & Capabilities
   - 添加 Sign in with Apple capability
   - 配置 App ID 和 Provisioning Profile

## 編譯和運行

```bash
# 編譯項目
cd /Users/mickeylau/lifelab
xcodebuild -project LifeLab/LifeLab.xcodeproj -scheme LifeLab -sdk iphonesimulator -destination 'platform=iOS Simulator,name=iPhone 17 Pro Max' build

# 或在 Xcode 中直接運行
```

## 問題排查

如果遇到問題：
1. 檢查 Xcode 控制台的日誌
2. 確認所有依賴都已正確導入
3. 確認 Signing & Capabilities 配置正確（對於 Apple Sign In）
4. 檢查設備是否已信任開發者證書
