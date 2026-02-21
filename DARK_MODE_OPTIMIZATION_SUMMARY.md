# 夜間模式設計優化總結

## ✅ 已完成的工作

### 1. 設計系統更新 (`DesignSystem.swift`)
- ✅ 更新為專屬深色模式設計
- ✅ 背景色：純黑 (#000000)
- ✅ 卡片/表面色：深炭灰 (#1C1C1E)
- ✅ 主要文字：純白 (#FFFFFF)
- ✅ 品牌色：金黃色 (#FFC107)
- ✅ 操作色：霓虹紫 (#8B5CF6)
- ✅ 使用 Apple 原生 SF Pro 字體
- ✅ 創建可重用組件：`PrimaryButton`, `SelectionCard`, `HighlightedText`, `PageIndicator`, `LinearProgressBar`

### 2. 全局深色模式強制
- ✅ `LifeLabApp.swift` - 全局強制深色模式
- ✅ `ContentView.swift` - 強制深色模式
- ✅ `MainTabView` - 強制深色模式

### 3. 已更新的視圖
- ✅ `LoginView.swift` - 完全更新為夜間模式設計
- ✅ `ModernTextField` - 更新為深色模式樣式
- ✅ `ModernSecureField` - 更新為深色模式樣式

---

## 📋 需要更新的視圖（批量更新策略）

### 核心更新模式：

#### 1. 背景色更新
```swift
// 舊代碼：
LinearGradient(colors: [...], ...)
// 或
Color.white

// 新代碼：
BrandColors.background // 純黑 #000000
```

#### 2. 卡片/表面色更新
```swift
// 舊代碼：
BrandColors.secondaryBackground // 會自動映射到 surface

// 新代碼：
BrandColors.surface // #1C1C1E
```

#### 3. 按鈕更新
```swift
// 舊代碼：
Button(...) {
    Text("繼續")
        .foregroundColor(.white)
        .background(BrandColors.primaryGradient)
        .cornerRadius(16)
}

// 新代碼：
Button(...) {
    Text("繼續")
        .font(BrandTypography.headline)
        .fontWeight(.bold)
        .foregroundColor(BrandColors.invertedText) // 黑色
        .frame(maxWidth: .infinity)
        .padding(.vertical, BrandSpacing.md)
        .background(BrandColors.primaryText) // 白色
        .clipShape(Capsule()) // 藥丸形狀
}
.padding(.horizontal, BrandSpacing.xl)
```

#### 4. 選擇卡片更新
```swift
// 舊代碼：
Button(...) {
    Text(title)
        .background(isSelected ? gradient : color)
}

// 新代碼：
SelectionCard(
    title: title,
    isSelected: isSelected,
    action: { ... }
)
```

#### 5. 進度條更新
```swift
// 舊代碼：
RoundedRectangle(...)
    .fill(BrandColors.primaryGradient)

// 新代碼：
LinearProgressBar(progress: progress)
// 或
GeometryReader { geometry in
    ZStack(alignment: .leading) {
        RoundedRectangle(cornerRadius: BrandRadius.small)
            .fill(BrandColors.surface) // 軌道
        RoundedRectangle(cornerRadius: BrandRadius.small)
            .fill(BrandColors.actionAccent) // 填滿色 #8B5CF6
            .frame(width: geometry.size.width * CGFloat(progress), height: 4)
    }
}
```

#### 6. 文字強調更新
```swift
// 單個詞語（紫色）：
HighlightedText(text: "關鍵詞", highlightColor: .purple)

// 整段片語（黃色背景）：
HighlightedText(text: "重要提示", highlightColor: .yellow)
```

---

## 📝 需要更新的文件列表

### 初始掃描視圖
- [ ] `BasicInfoView.swift` - 更新背景、按鈕、表單字段
- [ ] `InterestsSelectionView.swift` - 更新背景、按鈕、關鍵詞按鈕
- [ ] `StrengthsQuestionnaireView.swift` - 更新背景、按鈕、進度條
- [ ] `ValuesRankingView.swift` - 更新背景、卡片、按鈕
- [ ] `AISummaryView.swift` - 更新背景、卡片
- [ ] `PaymentView.swift` - 更新背景、按鈕
- [ ] `LifeBlueprintView.swift` - 更新背景、卡片
- [ ] `PlanGenerationLoadingView.swift` - 更新背景、進度條

### 主要視圖
- [ ] `DashboardView.swift` - 更新背景、卡片、進度條（移除深色模式切換按鈕）
- [ ] `ProfileView.swift` - 更新背景、卡片
- [ ] `LifeBlueprintEditView.swift` - 更新背景、卡片、選擇卡片
- [ ] `DeepeningExplorationView.swift` - 更新背景、按鈕、進度條
- [ ] `TaskManagementView.swift` - 更新背景、卡片、按鈕
- [ ] `SettingsView.swift` - 更新背景、卡片、按鈕

### 深化探索視圖
- [ ] `AcquiredStrengthsView.swift`
- [ ] `FlowDiaryView.swift`
- [ ] `FeasibilityAssessmentView.swift`
- [ ] `ResourceInventoryView.swift`
- [ ] `ValuesQuestionsView.swift`

### 其他視圖
- [ ] `ReviewInitialScanView.swift`
- [ ] `ActionPlanReviewView.swift`
- [ ] `VennDiagramView.swift`

---

## 🎨 設計規範檢查清單

### 背景
- [ ] 所有視圖使用 `BrandColors.background` (#000000)
- [ ] 移除所有漸變背景（除非特殊需求）
- [ ] 添加 `.preferredColorScheme(.dark)` 到所有視圖

### 文字
- [ ] 標題使用 `BrandTypography.largeTitle` 或 `BrandTypography.title` + `.bold()`
- [ ] 內文使用 `BrandTypography.body`
- [ ] 所有文字顏色為 `BrandColors.primaryText` (#FFFFFF)
- [ ] 次要文字使用 `BrandColors.secondaryText`
- [ ] 所有標題和選項靠左對齊

### 按鈕
- [ ] 主要按鈕：白色背景、黑色文字、藥丸形狀（Capsule）
- [ ] 次要按鈕：深炭灰背景、白色文字、圓角矩形
- [ ] 使用 `PrimaryButton` 組件或 `PrimaryButtonStyle`

### 卡片
- [ ] 未選取：`BrandColors.surface` (#1C1C1E) 背景
- [ ] 已選取：`BrandColors.actionAccent` (#8B5CF6) 背景 + 白色勾選圖示
- [ ] 使用 `SelectionCard` 組件進行選擇

### 進度指示器
- [ ] 導覽頁面：使用 `PageIndicator`（小圓點）
- [ ] 載入/生成：使用 `LinearProgressBar`（線型進度條）
- [ ] 軌道：`BrandColors.surface` (#1C1C1E)
- [ ] 填滿：`BrandColors.actionAccent` (#8B5CF6)

### 強調標記
- [ ] 單個詞語：`HighlightedText` with `.purple` (#8B5CF6)
- [ ] 整段片語：`HighlightedText` with `.yellow` (#FFC107 背景 + 黑色文字)

### iPad 響應式
- [ ] 使用 `ResponsiveLayout.horizontalPadding()` 設置水平邊距
- [ ] 使用 `ResponsiveLayout.maxContentWidth()` 限制最大寬度
- [ ] 檢查所有視圖在 iPad 上的顯示效果

---

## 🔧 批量更新腳本建議

由於文件較多，建議按以下順序更新：

1. **第一階段**：核心視圖（已完成 LoginView）
   - BasicInfoView
   - InterestsSelectionView
   - StrengthsQuestionnaireView
   - DashboardView

2. **第二階段**：其他初始掃描視圖
   - ValuesRankingView
   - AISummaryView
   - PaymentView
   - LifeBlueprintView

3. **第三階段**：主要功能視圖
   - ProfileView
   - LifeBlueprintEditView
   - DeepeningExplorationView
   - TaskManagementView
   - SettingsView

4. **第四階段**：深化探索視圖和其他視圖

---

## ✅ 完成標準

每個視圖更新完成後應滿足：
- ✅ 背景為純黑 (#000000)
- ✅ 卡片為深炭灰 (#1C1C1E)
- ✅ 文字為純白 (#FFFFFF)
- ✅ 按鈕符合設計規範
- ✅ 進度條使用正確顏色
- ✅ iPad 響應式支持
- ✅ 無編譯錯誤
- ✅ 視覺效果符合設計規範

---

## 📝 注意事項

1. **保留功能邏輯**：只更新 UI，不改變業務邏輯
2. **測試兼容性**：確保所有視圖在更新後仍能正常工作
3. **漸進式更新**：一次更新幾個視圖，測試後繼續
4. **文檔更新**：更新相關文檔以反映新的設計規範

---

## 🎯 下一步

1. 繼續更新剩餘視圖
2. 測試所有視圖在 iPhone 和 iPad 上的顯示效果
3. 確保所有交互功能正常
4. 進行最終視覺檢查
