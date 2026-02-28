# Action Plan Generation Fixes Summary

## Issues Fixed

### 1. ✅ Background Execution Support
**Problem**: Action plan generation stopped when users switched to different pages.

**Solution**: 
- Added `UIApplication.shared.beginBackgroundTask` in both `DeepeningExplorationView` and `TaskManagementView`
- Generation now continues even when app goes to background or user navigates away
- Background task is properly ended after completion or error

**Files Modified**:
- `/LifeLab/LifeLab/Views/DeepeningExplorationView.swift` - Added background task support in `generateActionPlan()`
- `/LifeLab/LifeLab/Views/TaskManagementView.swift` - Added background task support in `generateActionPlan()`

### 2. ✅ Button State Synchronization
**Problem**: Both "深化探索" and "任務" pages showed "生成行動計劃" button, and clicking one didn't hide the other.

**Solution**:
- Changed button visibility check to use `dataService.userProfile?.actionPlan == nil` directly
- Removed dependency on local `actionPlanGenerated` state variable
- Both pages now check the same source of truth (`dataService.userProfile?.actionPlan`)
- When action plan is generated, button disappears from both pages immediately

**Files Modified**:
- `/LifeLab/LifeLab/Views/DeepeningExplorationView.swift`:
  - Changed condition from `!actionPlanGenerated` to `dataService.userProfile?.actionPlan == nil`
  - Changed disabled state to check `dataService.userProfile?.actionPlan != nil`
- `/LifeLab/LifeLab/Views/TaskManagementView.swift`:
  - Already checks `dataService.userProfile?.actionPlan == nil` (no changes needed)

### 3. ✅ JSON Parsing Error Fix (max_tokens truncation)
**Problem**: 
- AI response was truncated due to `max_tokens` limit (2000)
- JSON parsing failed with "Unterminated string" error
- Action plan generation failed completely

**Solution**:
1. **Increased max_tokens**: Changed from 2000 to 3000 for action plan generation (more complex JSON structure)
2. **Improved JSON parsing**: Added robust error handling similar to `generateLifeBlueprint()`:
   - Extract partial JSON when response is truncated
   - Handle "Unterminated string" errors gracefully
   - Use `extractPartialJSON()` helper function to recover partial data
   - Fallback to `generateActionPlanFallback()` if parsing completely fails
3. **Better error logging**: Added detailed logging for JSON parsing failures

**Files Modified**:
- `/LifeLab/LifeLab/Services/AIService.swift`:
  - Modified `makeAPIRequest()` to accept optional `maxTokens` parameter (default 2000)
  - Updated `generateActionPlan()` to use `maxTokens: 3000`
  - Added comprehensive JSON parsing with truncation handling
  - Added error recovery using `extractPartialJSON()` helper

## Technical Details

### Background Task Implementation
```swift
var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "GenerateActionPlan") {
    if backgroundTaskID != .invalid {
        UIApplication.shared.endBackgroundTask(backgroundTaskID)
        backgroundTaskID = .invalid
    }
}

// ... generation code ...

// End background task after completion
if backgroundTaskID != .invalid {
    UIApplication.shared.endBackgroundTask(backgroundTaskID)
    backgroundTaskID = .invalid
}
```

### Button State Check
**Before**:
```swift
if latestVersionNumber >= 2 && dataService.userProfile?.actionPlan == nil && !actionPlanGenerated {
    // Show button
}
.disabled(isGeneratingActionPlan || actionPlanGenerated)
```

**After**:
```swift
if latestVersionNumber >= 2 && dataService.userProfile?.actionPlan == nil && !isGeneratingActionPlan {
    // Show button
}
.disabled(isGeneratingActionPlan || dataService.userProfile?.actionPlan != nil)
```

### JSON Parsing with Truncation Handling
```swift
do {
    guard let parsedJson = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
        return try await generateActionPlanFallback()
    }
    json = parsedJson
} catch let parseError as NSError {
    if parseError.localizedDescription.contains("Unterminated string") {
        // Try to extract partial JSON
        if let partialJsonString = extractPartialJSON(from: jsonString) {
            // Use partial JSON
        } else {
            return try await generateActionPlanFallback()
        }
    } else {
        return try await generateActionPlanFallback()
    }
}
```

## Testing Recommendations

1. **Background Execution**:
   - Start action plan generation
   - Switch to different page/tab while generation is in progress
   - Verify generation completes successfully
   - Check that action plan appears after returning to page

2. **Button State**:
   - Go to "深化探索" page → verify button shows if no action plan
   - Click "生成行動計劃" → verify button disappears immediately
   - Go to "任務" page → verify button also disappeared there
   - Verify button doesn't reappear after action plan is generated

3. **JSON Parsing**:
   - Test with various user profiles (different amounts of data)
   - Verify action plan generates successfully even if response is truncated
   - Check console logs for truncation warnings
   - Verify fallback action plan is used if JSON parsing completely fails

## Build Status
✅ **BUILD SUCCEEDED** - All changes compile successfully

## Notes
- Background task has a time limit (typically 30 seconds to a few minutes)
- If generation takes longer than background task allows, it may still be interrupted
- JSON truncation handling provides graceful degradation - partial data is better than no data
- Fallback action plan ensures users always get something, even if AI generation fails completely
