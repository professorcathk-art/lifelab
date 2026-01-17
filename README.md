# Lifelab - 天職探索應用

一個基於 SwiftUI 的 iOS 應用，幫助用戶通過漸進式自我探索和 AI 分析找到符合個人定位的人生方向。

## 核心價值主張

天職 = 熱情（喜歡） × 價值（價值觀） × 天賦（優勢）

## 專案結構

```
lifelab/
├── Models/              # 資料模型
│   ├── UserProfile.swift
│   └── AppState.swift
├── ViewModels/          # 業務邏輯
│   └── InitialScanViewModel.swift
├── Views/               # UI 視圖
│   ├── ContentView.swift
│   ├── DashboardView.swift
│   ├── DeepeningExplorationView.swift
│   ├── TaskManagementView.swift
│   ├── ProfileView.swift
│   └── InitialScan/
│       ├── InitialScanView.swift
│       ├── InterestsSelectionView.swift
│       ├── StrengthsQuestionnaireView.swift
│       ├── ValuesRankingView.swift
│       ├── AISummaryView.swift
│       ├── PaymentView.swift
│       └── LifeBlueprintView.swift
├── Services/            # 服務層
│   ├── DataService.swift
│   └── AIService.swift
├── Utilities/           # 工具類
│   ├── InterestDictionary.swift
│   ├── StrengthsQuestions.swift
│   └── ReflectionQuestions.swift
└── LifeLabApp.swift     # App 入口點
```

## 用戶旅程

### 第 1 階段：初步掃描（5-10 分鐘）
1. **興趣選擇**：互動式關鍵詞選擇（60秒計時）
2. **天賦問卷**：5個結構化問題，選擇相關關鍵詞
3. **價值觀排序**：拖曳排列10個核心價值觀的重要性
4. **AI 總結**：生成關鍵特質總結
5. **支付解鎖**：解鎖初版生命藍圖
6. **生命藍圖**：顯示3-5個天職方向建議

### 第 2 階段：深化探索（進行式）
- 心流日記（3天記錄）
- 價值觀問題（表1和表2）
- 資源盤點
- 後天強項分析
- 可行性評估

### 第 3 階段：AI 生成完整計劃
- 天職定義
- 個人檔案
- 行動計劃（短期/中期/長期）

### 第 4 階段：用戶審核 + 手動編輯
- 確認或調整計劃
- 標記執行狀態

### 第 5 階段：任務管理
- 每日任務提醒
- 目標追蹤
- 進度管理

## 技術架構

- **框架**：SwiftUI
- **架構模式**：MVVM
- **最低 iOS 版本**：iOS 16.0+
- **導航**：NavigationStack
- **數據持久化**：UserDefaults（可擴展至 Core Data）

## 設置說明

1. 在 Xcode 中創建新的 iOS App 專案
2. 選擇 SwiftUI 作為界面框架
3. 將所有文件複製到對應的資料夾
4. 確保 `LifeLabApp.swift` 設為 App 入口點
5. 最低部署目標設為 iOS 16.0

## 測試（無需打開 Xcode GUI）

不想打開 Xcode？可以使用命令行工具進行測試：

### 快速開始

**使用腳本（推薦）**：
```bash
chmod +x test_without_xcode.sh
./test_without_xcode.sh run    # 構建並運行
./test_without_xcode.sh test   # 運行測試
./test_without_xcode.sh build  # 僅構建
```

**使用 Makefile**：
```bash
make run    # 構建並運行
make test   # 運行測試
make build  # 僅構建
make clean  # 清理構建文件
```

### 詳細說明

查看 [TESTING.md](TESTING.md) 了解完整的測試選項，包括：
- 命令行工具 (`xcodebuild`, `xcrun simctl`)
- Fastlane 自動化
- GitHub Actions CI/CD
- Swift Package Manager 測試

### 優勢

✅ **更快**：無 GUI 開銷  
✅ **可腳本化**：自動化工作流程  
✅ **CI/CD 就緒**：易於集成  
✅ **資源友好**：更低內存使用  
✅ **可重現**：每次使用相同命令

## 功能特點

- ✅ 互動式興趣關鍵詞選擇
- ✅ 結構化天賦問卷
- ✅ 價值觀拖曳排序
- ✅ AI 驅動的分析和建議
- ✅ 個人化生命藍圖生成
- ✅ 任務管理和追蹤
- ✅ 進度視覺化

## 待實現功能

- [ ] 深化探索各步驟的完整實現
- [ ] AI 服務的實際 API 整合
- [ ] 支付系統整合
- [ ] 數據同步和備份
- [ ] 推送通知（每日激勵）
- [ ] 計劃導出和分享功能

## 注意事項

- 當前 AI 服務為模擬實現，需要整合實際的 AI API
- 支付功能目前為測試模式，無需實際支付
- 數據存儲使用 UserDefaults，生產環境建議使用 Core Data 或 CloudKit
