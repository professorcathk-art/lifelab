# Blueprint Saving Fix
**Date**: 2026-01-18  
**Issue**: Version 1 blueprint not showing in 個人檔案, always shows Version 2

---

## Problem Identified

### Root Cause:
1. **Version 1** was saved to `profile.lifeBlueprint` only, NOT to `profile.lifeBlueprints` array
2. **Version 2** was saved to both `profile.lifeBlueprints` array AND `profile.lifeBlueprint`
3. **ProfileView** logic:
   - If `lifeBlueprints` is empty → show `lifeBlueprint`
   - If `lifeBlueprints` is not empty → show `lifeBlueprints` array
4. Since Version 2 adds to `lifeBlueprints`, it becomes non-empty
5. ProfileView then shows `lifeBlueprints` array, which only contains Version 2
6. Version 1 is lost because it's not in the array!

---

## Fixes Applied

### 1. Save Version 1 to Array ✅
**File**: `LifeLab/LifeLab/ViewModels/InitialScanViewModel.swift`

**Changes**:
- When Version 1 is generated, now also adds it to `lifeBlueprints` array
- Checks if Version 1 already exists before adding (to avoid duplicates)
- Updates existing Version 1 if it exists

**Code**:
```swift
DataService.shared.updateUserProfile { profile in
    profile.lifeBlueprint = updatedBlueprint
    // Also add to lifeBlueprints array so it shows in ProfileView
    if !profile.lifeBlueprints.contains(where: { $0.version == 1 }) {
        profile.lifeBlueprints.append(updatedBlueprint)
    } else {
        // Update existing Version 1 if it exists
        if let index = profile.lifeBlueprints.firstIndex(where: { $0.version == 1 }) {
            profile.lifeBlueprints[index] = updatedBlueprint
        }
    }
}
```

### 2. Fix ProfileView Display Logic ✅
**File**: `LifeLab/LifeLab/Views/ProfileView.swift`

**Changes**:
- Now combines `lifeBlueprint` and `lifeBlueprints` array
- Ensures current blueprint is included even if not in array
- Sorts by version (newest first)

**Code**:
```swift
// Show all versions - combine lifeBlueprint and lifeBlueprints
var allBlueprints = profile.lifeBlueprints
// Add current lifeBlueprint if it's not already in the array
if let currentBlueprint = profile.lifeBlueprint {
    if !allBlueprints.contains(where: { $0.version == currentBlueprint.version && abs($0.createdAt.timeIntervalSince(currentBlueprint.createdAt)) < 1 }) {
        allBlueprints.append(currentBlueprint)
    }
}
```

### 3. Enhanced Logging ✅
**Files**: 
- `LifeLab/LifeLab/ViewModels/InitialScanViewModel.swift`
- `LifeLab/LifeLab/Views/DeepeningExplorationView.swift`
- `LifeLab/LifeLab/Services/AIService.swift`

**Added Logging**:
- Logs blueprint content when saving
- Logs direction count and titles
- Logs summary lengths
- Warns if using fallback data
- Verifies AI-generated content vs fallback

**Example Logs**:
```
✅ Saving Version 1 blueprint:
  - Directions count: 3
  - First direction title: 軟體工程師
  - Strengths summary length: 245 chars
  - Strengths summary preview: 根據您的興趣和天賦分析...
✅ Added Version 1 to lifeBlueprints array
```

---

## How to Verify AI is Working

### Check Console Logs:
1. Open Xcode Console (View → Debug Area → Activate Console)
2. Complete survey and generate blueprint
3. Look for these logs:

**✅ AI Working**:
```
✅ Successfully parsed JSON from AI response
✅ Found 3 vocation directions
  Direction 1: [Unique title based on your inputs]...
✅ AI-generated strengths summary: [Personalized content]...
✅ Saving Version 1 blueprint:
  - Directions count: 3
  - First direction title: [Specific job title]
```

**❌ AI NOT Working (Using Fallback)**:
```
❌ JSON parsing failed, using fallback
⚠️ Using fallback blueprint (AI generation failed)
⚠️ WARNING: Directions array is empty!
```

### Check Profile View:
1. Go to "個人檔案"
2. Check if blueprint content is:
   - **Different each time** (if AI working)
   - **Same every time** (if using fallback)
3. Check if Version 1 and Version 2 both show
4. Check if content is personalized based on your inputs

---

## Testing Steps

1. **Clear existing data** (Settings → Clear Data)
2. **Complete survey** with specific interests (e.g., "設計", "寫作")
3. **Generate Version 1** → Check console logs
4. **Go to 個人檔案** → Verify Version 1 shows with personalized content
5. **Complete 深化探索**
6. **Generate Version 2** → Check console logs
7. **Go to 個人檔案** → Verify both Version 1 and Version 2 show
8. **Compare content** → Should be different if AI is working

---

## Expected Behavior

### If AI is Working:
- Version 1: Shows personalized content based on your survey inputs
- Version 2: Shows updated content including deepening exploration data
- Both versions visible in 個人檔案
- Content is different each time you regenerate

### If AI is NOT Working:
- Same generic content every time
- Same placeholder text
- Console shows fallback warnings
- Content doesn't reflect your inputs

---

**Last Updated**: 2026-01-18  
**Status**: ✅ Fixed
