# Theme Fix for Profile and Deepening Exploration Pages

## Issues Fixed

### Problem
When users toggle between light/dark mode on the "個人檔案" (Profile) and "深化探索" (Deepening Exploration) pages, some UI elements were not updating their appearance, causing text visibility issues (same color as background).

**Specific Issues:**
1. **Profile Page**:
   - "興趣" (Interests) tags had white background with dark text in dark mode
   - "天賦" (Talents) tags had white background with dark text in dark mode
   - "核心價值觀" (Core Values) cards had white background with dark text in dark mode

2. **Deepening Exploration Page**:
   - Exercise step cards had white background with dark text in dark mode

### Root Cause
The components (`ProfileSection` and `ExplorationStepCard`) were using `BrandColors` properties (which are theme-aware), but they were **not observing ThemeManager changes**. This meant:
- `BrandColors.surface` would return the correct color based on `ThemeManager.shared.isDarkMode`
- However, when the theme changed, these components didn't re-render because they weren't observing the ThemeManager
- Result: Components stayed with their initial theme colors

### Solution
Added `@StateObject private var themeManager = ThemeManager.shared` to both components so they properly observe theme changes and re-render when the theme toggles.

## Files Modified

### 1. `/LifeLab/LifeLab/Views/ProfileView.swift`
**Component**: `ProfileSection`
- Added `@StateObject private var themeManager = ThemeManager.shared`
- Added comments explaining theme-aware colors
- Now properly updates when theme changes

**Before**:
```swift
struct ProfileSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        // ... uses BrandColors.surface, BrandColors.primaryText
    }
}
```

**After**:
```swift
struct ProfileSection: View {
    let title: String
    let items: [String]
    // CRITICAL: Observe theme changes to ensure proper updates
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        // ... uses BrandColors.surface, BrandColors.primaryText
        // Now properly updates when theme changes
    }
}
```

### 2. `/LifeLab/LifeLab/Views/DeepeningExplorationView.swift`
**Component**: `ExplorationStepCard`
- Added `@StateObject private var themeManager = ThemeManager.shared`
- Added comments explaining theme-aware colors
- Now properly updates when theme changes

**Before**:
```swift
struct ExplorationStepCard: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isUnlocked: Bool

    var body: some View {
        // ... uses BrandColors.surface, BrandColors.primaryText
    }
}
```

**After**:
```swift
struct ExplorationStepCard: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isUnlocked: Bool
    // CRITICAL: Observe theme changes to ensure proper updates
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        // ... uses BrandColors.surface, BrandColors.primaryText
        // Now properly updates when theme changes
    }
}
```

## Theme-Aware Colors Used

Both components use the following theme-aware colors:

1. **Background**: `BrandColors.surface`
   - Dark mode: `#1C1C1E` (dark charcoal)
   - Light mode: `#FFFFFF` (white)

2. **Text**: `BrandColors.primaryText`
   - Dark mode: `#FFFFFF` (white)
   - Light mode: `#2C2C2E` (dark charcoal)

3. **Secondary Text**: `BrandColors.secondaryText`
   - Dark mode: `#D1D5DB` (light gray)
   - Light mode: `#8E8E93` (soft gray)

4. **Border**: `BrandColors.borderColor`
   - Dark mode: `#2C2C2E` (border gray)
   - Light mode: `#E5E5EA` (very light gray)

## Testing Recommendations

1. **Profile Page**:
   - Toggle theme on profile page
   - Verify "興趣" tags update background and text colors
   - Verify "天賦" tags update background and text colors
   - Verify "核心價值觀" cards update background and text colors
   - Check text visibility in both modes

2. **Deepening Exploration Page**:
   - Toggle theme on deepening exploration page
   - Verify exercise step cards update background and text colors
   - Check text visibility in both modes

3. **Cross-Page Consistency**:
   - Toggle theme on one page
   - Navigate to another page
   - Verify theme persists and all elements are correctly styled

## Build Status
✅ **BUILD SUCCEEDED** - All changes compile successfully

## Notes
- `BrandColors` properties are already theme-aware (they check `ThemeManager.shared.isDarkMode` internally)
- The issue was that components weren't observing ThemeManager, so they didn't re-render on theme changes
- Adding `@StateObject private var themeManager = ThemeManager.shared` ensures components observe and react to theme changes
- This is the same pattern used in other components like `VocationDirectionCard`, `ProgressCard`, and `DataChip` that were fixed earlier
