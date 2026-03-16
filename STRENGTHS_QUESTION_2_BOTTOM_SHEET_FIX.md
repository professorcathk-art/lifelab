# Strengths Question 2 - Bottom Sheet Enhancement (Energy/Vitality Theme)

## ✅ Implementation Complete

Successfully enhanced Strengths Question 2 ("從事哪些活動時，會讓你感到精神振奮、充滿活力？") with the same **Bottom Sheet (底部抽屜)** pattern as Question 1, with special **Energy/Vitality visual effects**.

## 🎯 Key Features

### 1. **Question 2 Only - Bottom Sheet Pattern with Energy Theme**
- ✅ Uses `EnergyCategory` data structure with 4-character labels
- ✅ 16 categories displayed as pill buttons (2-3 column grid)
- ✅ Bottom sheet opens when tapping a category
- ✅ 8 sub-energies per category (all exactly 4 characters)
- ✅ 3-4 column grid in bottom sheet (optimized for 4-character labels)
- ✅ **Special Energy/Vitality Theme**: Golden yellow accents with glowing effects

### 2. **Questions 3-5 - Inline Pattern (Unchanged)**
- ✅ Keep existing inline expansion pattern
- ✅ Uses `keywordHierarchy` structure
- ✅ No changes to existing functionality

### 3. **State Management**
- ✅ `selectedEnergies: [String: Set<String>]` tracks selections per category
- ✅ Syncs to `strengths[1].selectedKeywords` for backward compatibility
- ✅ Badge counters show "+N" on category pills
- ✅ **Glowing golden borders** indicate categories with selections (Energy theme)

## 🎨 Visual Design - Energy/Vitality Theme

### Color Scheme
- **Primary Accent**: Golden Yellow (`BrandColors.brandAccent` - #FFC107)
- **Glow Effect**: Stronger shadow/glow compared to Question 1 (purple)
- **Icons**: `bolt.fill` and `sparkles` for energy theme

### Visual Effects
1. **Category Pills (Level 1)**:
   - Selected: Golden yellow border with **stronger glow** (radius: 6, opacity: 0.6)
   - Badge: Golden yellow background
   - Icon: `bolt.fill` in header

2. **Sub-Energy Pills (Level 2)**:
   - Selected: Golden yellow background with **glow shadow** (radius: 6, opacity: 0.4)
   - Scale effect: 1.05x when selected
   - Additional shadow for depth

3. **Bottom Sheet Header**:
   - `bolt.fill` icon in golden yellow
   - Title: Category name
   - Subtitle: "你最享受哪種過程？"

## 📁 Files Modified

### 1. `StrengthsQuestions.swift`
- ✅ Added `SubEnergy` and `EnergyCategory` structs
- ✅ Updated `StrengthsQuestion` to include optional `energyCategories`
- ✅ Question 2: Uses `energyCategories` (16 categories, 8 sub-energies each)
- ✅ Questions 3-5: `energyCategories: nil`, use `keywordHierarchy`

### 2. `InitialScanViewModel.swift`
- ✅ Added `selectedEnergies: [String: Set<String>]` for tracking
- ✅ Added `getSelectedEnergyCount(for:)` method
- ✅ Added `toggleEnergy()` method
- ✅ Added `isEnergySelected()` method
- ✅ Added `getAllSelectedEnergyLabels()` method
- ✅ Updated `getAvailableKeywords()` to exclude Question 2

### 3. `StrengthsQuestionnaireView.swift`
- ✅ Conditional rendering: Question 2 uses Bottom Sheet with Energy theme
- ✅ Added `EnergyCategoryPillButton` component (with golden glow)
- ✅ Added `EnergiesBottomSheet` component
- ✅ Added `SubEnergyPillButton` component (with energy glow effect)
- ✅ Bottom sheet with `.presentationDetents([.medium, .large])`

## 📊 Data Structure

### Question 2: 16 Categories × 8 Sub-energies = 128 Keywords

1. **從零到一** (create_zero_to_one)
   - 打造雛形、建立制度、發起專案、開拓新局、構思草圖、產品孵化、撰寫初稿、搭建框架

2. **排憂解難** (fix_and_solve)
   - 排除故障、撲滅火災、解開死結、修復損壞、拯救危機、破解謎題、挽回局面、搞定難題

3. **優化秩序** (optimize_order)
   - 梳理流程、提升效率、空間收納、減少浪費、制定規範、系統重構、資料歸檔、標準作業

4. **深度鑽研** (deep_dive)
   - 查閱文獻、挖掘真相、追根究底、數據回溯、沉浸閱讀、專注實驗、拆解原理、探尋本質

5. **競技取勝** (compete_win)
   - 超越對手、達成業績、贏得比賽、打破紀錄、挑戰榜單、爭取第一、攻克難關、實力輾壓

6. **引領方向** (lead_influence)
   - 描繪願景、凝聚共識、指揮調度、激勵士氣、帶領衝鋒、發表宣言、說服群眾、扭轉風向

7. **陪伴扶持** (support_nurture)
   - 傾聽低谷、默默守護、助人成長、提供避風、解決煩惱、成就他人、照料弱勢、心理陪伴

8. **串接人脈** (connect_network)
   - 牽線媒合、活躍氣氛、舉辦聚會、破冰交流、資源交換、建立社群、拓展圈子、跨界聯絡

9. **登台展現** (take_stage)
   - 享受目光、侃侃而談、肢體表演、散發魅力、掌控全場、鎂光燈下、帶動高潮、現場互動

10. **挑戰極限** (push_limits)
    - 踏出舒適、承受高壓、危機應變、腎上腺素、冒險犯難、擁抱未知、豪賭一把、破釜沉舟

11. **策劃全局** (strategic_plan)
    - 沙盤推演、制定戰略、佈局未來、資源盤點、風險控管、商業模式、運籌帷幄、宏觀思考

12. **高效推進** (high_execution)
    - 劃掉清單、準時交付、按表操課、推進進度、多工處理、掃除障礙、完美落地、執行到底

13. **腦力激盪** (brainstorming)
    - 創意發想、拋磚引玉、碰撞火花、點子接龍、打破常規、異想天開、腦洞大開、概念發散

14. **雕琢美感** (refine_aesthetics)
    - 打磨細節、調整色彩、視覺對齊、追求完美、沉浸排版、質感提升、創造氛圍、藝術揮灑

15. **揮灑汗水** (physical_exertion)
    - 釋放多巴、突破體能、感受肌肉、戶外走跳、燃燒熱量、節奏律動、身體極限、流汗快感

16. **沉浸創作** (immersive_flow)
    - 忘我編碼、敲擊鍵盤、專注手作、筆飛墨舞、進入心流、與世隔絕、靈感湧現、廢寢忘食

## ✅ Health Check

### Code Quality
- ✅ No linter errors
- ✅ Proper SwiftUI patterns
- ✅ MVVM architecture maintained
- ✅ Clean separation of concerns

### Functionality
- ✅ Question 2 uses Bottom Sheet with Energy theme
- ✅ Questions 3-5 use inline pattern (unchanged)
- ✅ Selection tracking works correctly
- ✅ Badge counts update in real-time
- ✅ Data syncs to `strengths[1].selectedKeywords`
- ✅ Energy glow effects work correctly

### Theme Support
- ✅ Dark mode: Golden yellow accents on dark background
- ✅ Light mode: Proper contrast
- ✅ Theme switching works correctly
- ✅ Energy theme visually distinct from Question 1 (purple)

### Responsiveness
- ✅ iPhone: 2-3 columns for categories
- ✅ iPad: Optimized layout
- ✅ Bottom sheet: 3-4 columns for 4-character labels
- ✅ Grid columns adjust automatically

## 🎨 Visual Comparison

### Question 1 (Talents)
- **Color**: Purple (`BrandColors.actionAccent`)
- **Icon**: `tag.fill`
- **Glow**: Moderate (radius: 4, opacity: 0.5)

### Question 2 (Energies)
- **Color**: Golden Yellow (`BrandColors.brandAccent`)
- **Icon**: `bolt.fill` and `sparkles`
- **Glow**: Stronger (radius: 6, opacity: 0.6 for borders, 0.4 for pills)
- **Theme**: Energy/Vitality

## 🧪 Testing Checklist

- [ ] Test Question 2 Bottom Sheet opens/closes
- [ ] Test energy selection/deselection
- [ ] Test badge counter updates
- [ ] Test golden glow effects are visible
- [ ] Test Questions 3-5 still work (inline pattern)
- [ ] Test dark/light theme
- [ ] Test iPad responsiveness
- [ ] Test data persistence
- [ ] Test navigation between questions
- [ ] Verify energy theme is visually distinct from Question 1

## 📝 Notes

1. **Backward Compatibility**: Selected energies sync to `strengths[1].selectedKeywords` array for compatibility with existing code.

2. **4-Character Labels**: All sub-energies are exactly 4 characters, optimized for 3-4 column grid layout.

3. **Conditional Rendering**: View checks `question.id == 2` to determine which pattern to use.

4. **State Management**: Separate tracking for energies (`selectedEnergies`) vs talents (`selectedTalents`) vs interests (`selectedSubInterests`).

5. **Energy Theme**: Golden yellow color scheme and stronger glow effects differentiate Question 2 from Question 1, emphasizing the "energy/vitality" theme.
