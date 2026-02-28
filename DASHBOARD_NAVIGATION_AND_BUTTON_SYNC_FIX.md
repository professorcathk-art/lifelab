# Dashboard Navigation & Button Sync Fix

## Issues Fixed

### 1. ✅ Disabled Navigation from Dashboard Progress Cards
**Issue**: Clicking "深化探索" and "行動計劃" progress cards in the dashboard redirected users to those pages.

**Solution**: Removed `NavigationLink` wrappers from progress cards, keeping them as display-only elements.

**Files Modified**:
- `/LifeLab/LifeLab/Views/DashboardView.swift`
  - Removed `NavigationLink(destination: DeepeningExplorationView())` wrapper
  - Removed `NavigationLink(destination: TaskManagementView())` wrappers
  - Progress cards now display only, no navigation

**Before**:
```swift
NavigationLink(destination: DeepeningExplorationView()) {
    ProgressCard(title: "深化探索", ...)
}
.buttonStyle(.plain)
```

**After**:
```swift
// Disabled navigation - just show progress card without link
ProgressCard(title: "深化探索", ...)
```

### 2. ✅ Synchronized Action Plan Button State Across Pages
**Issue**: When user clicked "生成行動計劃" button in "深化探索" page, the button in "任務" page remained visible, allowing duplicate generation.

**Root Cause**: Each view had its own `@State private var isGeneratingActionPlan`, so they didn't sync. When one view started generation, the other view didn't know.

**Solution**: 
1. Added shared state `@Published var isGeneratingActionPlan: Bool` to `DataService`
2. Both views now use `dataService.isGeneratingActionPlan` instead of local state
3. Button visibility checks both `dataService.userProfile?.actionPlan == nil` and `!dataService.isGeneratingActionPlan`

**Files Modified**:
- `/LifeLab/LifeLab/Services/DataService.swift`
  - Added `@Published var isGeneratingActionPlan: Bool = false` for shared state

- `/LifeLab/LifeLab/Views/DeepeningExplorationView.swift`
  - Removed `@State private var isGeneratingActionPlan`
  - Added computed property: `private var isGeneratingActionPlan: Bool { dataService.isGeneratingActionPlan }`
  - Updated all references to use `dataService.isGeneratingActionPlan`
  - Removed `actionPlanGenerated` state variable (replaced with `dataService.userProfile?.actionPlan != nil`)

- `/LifeLab/LifeLab/Views/TaskManagementView.swift`
  - Removed `@State private var isGeneratingActionPlan`
  - Added computed property: `private var isGeneratingActionPlan: Bool { dataService.isGeneratingActionPlan }`
  - Updated all references to use `dataService.isGeneratingActionPlan`
  - Added check: `dataService.userProfile?.actionPlan == nil && !isGeneratingActionPlan` in button visibility condition

**Before**:
```swift
// DeepeningExplorationView.swift
@State private var isGeneratingActionPlan = false
@State private var actionPlanGenerated = false

if latestVersionNumber >= 2 && dataService.userProfile?.actionPlan == nil && !actionPlanGenerated {
    // Show button
}

// TaskManagementView.swift
@State private var isGeneratingActionPlan = false

if dataService.userProfile?.actionPlan == nil {
    // Show button (doesn't check if other page is generating)
}
```

**After**:
```swift
// DataService.swift
@Published var isGeneratingActionPlan: Bool = false

// DeepeningExplorationView.swift
private var isGeneratingActionPlan: Bool {
    dataService.isGeneratingActionPlan
}

if latestVersionNumber >= 2 && dataService.userProfile?.actionPlan == nil && !isGeneratingActionPlan {
    // Show button
}

// TaskManagementView.swift
private var isGeneratingActionPlan: Bool {
    dataService.isGeneratingActionPlan
}

if dataService.userProfile?.actionPlan == nil && !isGeneratingActionPlan {
    // Show button (checks shared state)
}
```

## How It Works

1. **Shared State**: `DataService.isGeneratingActionPlan` is a `@Published` property, so both views observe it automatically.

2. **Button Visibility**: Both views check:
   - `dataService.userProfile?.actionPlan == nil` (no action plan exists)
   - `!dataService.isGeneratingActionPlan` (not currently generating)

3. **Generation Start**: When user clicks button in either page:
   - `dataService.isGeneratingActionPlan = true` is set immediately
   - Both views observe this change and hide their buttons instantly

4. **Generation Complete**: When generation finishes:
   - Action plan is saved to `dataService.userProfile?.actionPlan`
   - `dataService.isGeneratingActionPlan = false` is set
   - Both views observe these changes and buttons remain hidden

## Testing Recommendations

1. **Navigation Disabled**:
   - Go to dashboard
   - Click "深化探索" progress card → Should NOT navigate
   - Click "行動計劃" progress card → Should NOT navigate

2. **Button Synchronization**:
   - Go to "深化探索" page → Verify button shows if conditions met
   - Click "生成行動計劃" → Button should disappear immediately
   - Navigate to "任務" page → Button should also be hidden
   - Wait for generation to complete → Verify action plan appears
   - Both pages should show no button after completion

3. **Reverse Flow**:
   - Go to "任務" page → Verify button shows if conditions met
   - Click "生成行動計劃" → Button should disappear immediately
   - Navigate to "深化探索" page → Button should also be hidden
   - Wait for generation to complete → Verify action plan appears

4. **Error Handling**:
   - Simulate network error during generation
   - Verify `isGeneratingActionPlan` is set to false on error
   - Verify buttons reappear if generation fails

## Build Status
✅ **BUILD SUCCEEDED** - All changes compile successfully

## Notes
- Users can still navigate to "深化探索" and "任務" pages via bottom tab bar
- Progress cards on dashboard are now display-only (no navigation)
- Button state is synchronized across all views using shared `DataService` state
- Prevents duplicate action plan generation
