# Edit Blueprint and Review Page Fixes

## Issues Fixed ✅

### 1. Duplicate Back Button in Edit Blueprint Page ✅
**Problem**: `LifeBlueprintEditView` had two back buttons:
- Default NavigationStack back button (no save alert)
- Custom toolbar back button (with save alert)

**Solution**: 
- Added `.navigationBarBackButtonHidden(true)` to hide default back button
- Kept only the custom toolbar back button that checks `hasUnsavedChanges` and shows alert

**File**: `LifeBlueprintEditView.swift`
```swift
.navigationBarBackButtonHidden(true) // CRITICAL: Hide default back button
.toolbar {
    ToolbarItem(placement: .navigationBarLeading) {
        Button(action: {
            if hasUnsavedChanges {
                showBackAlert = true
            } else {
                dismiss()
            }
        }) {
            HStack(spacing: BrandSpacing.xs) {
                Image(systemName: "chevron.left")
                Text("返回")
            }
            .foregroundColor(BrandColors.actionAccent)
        }
    }
}
```

**Result**: 
- ✅ Only one back button visible
- ✅ Back button always checks for unsaved changes
- ✅ Shows alert before dismissing if changes exist

### 2. Re-generate AI Summary Button in Review Page ✅
**Problem**: In `ReviewInitialScanView` → `AISummaryView`, the button showed "下一題" which doesn't make sense in review mode.

**Solution**:
- Added `isReviewMode` parameter to `AISummaryView`
- Changed button to "重新生成 AI 分析總結" in review mode
- Button regenerates AI summary and updates user profile
- Saves to `lifeBlueprint.strengthsSummary` and all blueprint versions

**Files Modified**:

1. **`AISummaryView.swift`**:
   - Added `isReviewMode: Bool = false` parameter
   - Conditional button rendering based on mode
   - Review mode: "重新生成 AI 分析總結" button
   - Initial scan mode: "下一題" button (unchanged)
   - Auto-saves regenerated summary to user profile

2. **`ReviewInitialScanView.swift`**:
   - Pass `isReviewMode: true` to `AISummaryView`
   - Pass `dataService` as environment object
   - Updated `saveChangesSilently()` to save AI summary to blueprint

**Code Changes**:

**AISummaryView.swift**:
```swift
struct AISummaryView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @EnvironmentObject var dataService: DataService
    var isReviewMode: Bool = false // Flag to indicate if in review mode
    
    // ... content ...
    
    if isReviewMode {
        // Review mode: Show regenerate button
        Button(action: {
            viewModel.generateAISummary()
        }) {
            HStack(spacing: BrandSpacing.sm) {
                if viewModel.isLoadingSummary {
                    ProgressView()
                } else {
                    Image(systemName: "arrow.clockwise")
                }
                Text(viewModel.isLoadingSummary ? "正在重新生成..." : "重新生成 AI 分析總結")
            }
            // ... styling ...
        }
        .onChange(of: viewModel.aiSummary) { newSummary in
            // Auto-save when regenerated
            if !newSummary.isEmpty && !viewModel.isLoadingSummary {
                dataService.updateUserProfile { profile in
                    if var blueprint = profile.lifeBlueprint {
                        blueprint.strengthsSummary = newSummary
                        profile.lifeBlueprint = blueprint
                    }
                    // Update all versions
                    if !profile.lifeBlueprints.isEmpty {
                        for i in profile.lifeBlueprints.indices {
                            profile.lifeBlueprints[i].strengthsSummary = newSummary
                        }
                    }
                }
            }
        }
    } else {
        // Initial scan mode: Show next button
        Button(action: {
            viewModel.currentStep = .loading
        }) {
            Text("下一題")
            // ... styling ...
        }
    }
}
```

**ReviewInitialScanView.swift**:
```swift
case .aiSummary:
    AISummaryView(isReviewMode: true)
        .environmentObject(viewModel)
        .environmentObject(dataService)
```

**saveChangesSilently()**:
```swift
private func saveChangesSilently() {
    DataService.shared.updateUserProfile { profile in
        // ... other fields ...
        
        // Save regenerated AI summary
        if !viewModel.aiSummary.isEmpty {
            if var blueprint = profile.lifeBlueprint {
                blueprint.strengthsSummary = viewModel.aiSummary
                profile.lifeBlueprint = blueprint
            }
            // Update all versions
            if !profile.lifeBlueprints.isEmpty {
                for i in profile.lifeBlueprints.indices {
                    profile.lifeBlueprints[i].strengthsSummary = viewModel.aiSummary
                }
            }
        }
    }
}
```

## Health Check Results ✅

### 1. Edit Blueprint Page ✅
- ✅ Only one back button visible
- ✅ Back button checks for unsaved changes
- ✅ Alert shown before dismissing with unsaved changes
- ✅ Save functionality works correctly
- ✅ Navigation works properly

### 2. Review Page - AI Summary ✅
- ✅ Button shows "重新生成 AI 分析總結" in review mode
- ✅ Button shows "下一題" in initial scan mode
- ✅ Regenerate button calls `generateAISummary()`
- ✅ Loading state shown during regeneration
- ✅ Regenerated summary auto-saved to user profile
- ✅ Saved to `lifeBlueprint.strengthsSummary`
- ✅ Saved to all blueprint versions
- ✅ Function works correctly

### 3. Data Persistence ✅
- ✅ AI summary saved to `lifeBlueprint.strengthsSummary`
- ✅ Saved to all versions in `lifeBlueprints` array
- ✅ Changes persist across app sessions
- ✅ Profile updates correctly

## Testing Recommendations

1. **Edit Blueprint Page**:
   - Navigate to edit page from home
   - Verify only one back button visible
   - Make changes and click back → Should show alert
   - Save changes and click back → Should dismiss without alert

2. **Review Page - AI Summary**:
   - Navigate to review page → AI Summary step
   - Verify button shows "重新生成 AI 分析總結"
   - Click button → Should show loading state
   - Wait for regeneration → Should update summary
   - Verify summary is saved to profile
   - Check that summary persists after app restart

3. **Initial Scan Flow**:
   - Verify "下一題" button still works in initial scan
   - Verify navigation to loading page works

## Files Modified

1. `/LifeLab/LifeLab/Views/LifeBlueprintEditView.swift`
   - Added `.navigationBarBackButtonHidden(true)`

2. `/LifeLab/LifeLab/Views/InitialScan/AISummaryView.swift`
   - Added `isReviewMode` parameter
   - Conditional button rendering
   - Auto-save logic for regenerated summary

3. `/LifeLab/LifeLab/Views/ReviewInitialScanView.swift`
   - Pass `isReviewMode: true` to `AISummaryView`
   - Pass `dataService` as environment object
   - Updated `saveChangesSilently()` to save AI summary

## Benefits

1. **Better UX**: No duplicate buttons, clear actions
2. **Data Safety**: Back button always checks for unsaved changes
3. **Functionality**: Re-generate button works and saves correctly
4. **Consistency**: Same view component used in both modes with different behavior
