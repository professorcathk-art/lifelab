# Purchase Flow Optimization Summary

## Issue
Apple testers encountered "無法載入產品" error during purchase. User's hypothesis: AI generation takes too long, causing timeout/runtime issues that prevent successful product loading.

## Root Cause Analysis
1. **Purchase Flow Issue**: After successful purchase, user was stuck on payment page waiting for AI to finish generating the blueprint
2. **AI Generation Timeout**: Long AI generation time (30+ seconds) could cause runtime issues, especially in sandbox environment
3. **Subscription Check False Positive**: User reported seeing "訂閱已過期" alert immediately after entering home page, even though subscription was valid

## Solutions Implemented

### 1. Immediate Navigation After Purchase ✅
**File**: `PaymentView.swift`

**Changes**:
- Removed success alert that blocked user interaction
- Immediately navigate to loading page (`currentStep = .loading`) after purchase success
- Start AI generation in background (non-blocking)
- User sees loading page immediately instead of being stuck on payment page

**Before**:
```swift
if success {
    showSuccess = true  // Show alert, user must click "確定"
}
// Alert handler calls completePayment() which starts AI generation
```

**After**:
```swift
if success {
    viewModel.hasPaid = true
    viewModel.currentStep = .loading  // Navigate immediately
    viewModel.generateLifeBlueprint()  // Start in background
    // No alert - user already sees loading page
}
```

### 2. Optimized AI Input & Token Limits ✅
**File**: `AIService.swift`

**Changes**:
- Reduced `max_tokens` from 3000 to 2000 (faster generation, less timeout risk)
- Limited interests to top 10 (instead of all)
- Limited strengths keywords to top 15 (instead of all)
- Limited strength answers to first 3 (most important ones)

**Impact**:
- Smaller input = faster API response
- Less token usage = lower cost
- Reduced timeout risk

**Code Changes**:
```swift
// Before: All interests
let interests = profile.interests.joined(separator: "、")

// After: Top 10 only
let limitedInterests = profile.interests.prefix(10)
let interests = limitedInterests.joined(separator: "、")

// Before: max_tokens: 3000
// After: max_tokens: 2000
```

### 3. Fixed Subscription Check Logic ✅
**File**: `ContentView.swift`

**Changes**:
- Only check subscription expiry if user has completed initial scan (has blueprint)
- Added 2-second delay before showing alert (handles sync delays)
- Prevents false positive alerts when user just purchased

**Before**:
```swift
.onChange(of: subscriptionManager.hasActiveSubscription) { hasActive in
    if !hasActive {
        // Immediately show alert - could be false positive
        showSubscriptionExpiredAlert = true
    }
}
```

**After**:
```swift
.onChange(of: subscriptionManager.hasActiveSubscription) { hasActive in
    // Only check if user has completed initial scan
    guard hasCompletedInitialScan else {
        return  // Skip check if still in initial scan
    }
    
    if !hasActive {
        // Wait 2 seconds (handles sync delays)
        Task {
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            await subscriptionManager.checkSubscriptionStatus()
            // Only show if still false after re-check
            if !subscriptionManager.hasActiveSubscription && hasCompletedInitialScan {
                showSubscriptionExpiredAlert = true
            }
        }
    }
}
```

## Expected Results

1. **Faster Purchase Flow**: User immediately sees loading page after purchase, no blocking alerts
2. **Reduced Timeout Risk**: Smaller AI input and lower token limit = faster generation
3. **Better UX**: User can see progress on loading page while AI generates in background
4. **No False Alerts**: Subscription expiry check only triggers for users who actually have blueprint

## Testing Recommendations

1. **Purchase Flow**:
   - Test purchase in sandbox
   - Verify immediate navigation to loading page
   - Verify AI generation continues in background
   - Verify user can see loading progress

2. **AI Generation**:
   - Test with various input sizes
   - Verify generation completes successfully
   - Monitor timeout rates

3. **Subscription Check**:
   - Test after fresh purchase (should not show false alert)
   - Test after actual expiry (should show alert)
   - Test during initial scan (should not check)

## Files Modified

1. `/LifeLab/LifeLab/Views/InitialScan/PaymentView.swift`
   - Removed success alert
   - Immediate navigation to loading page

2. `/LifeLab/LifeLab/ViewModels/InitialScanViewModel.swift`
   - Updated `completePayment()` to navigate immediately

3. `/LifeLab/LifeLab/Services/AIService.swift`
   - Reduced `max_tokens` from 3000 to 2000
   - Limited input sizes (interests, strengths, answers)

4. `/LifeLab/LifeLab/Views/ContentView.swift`
   - Fixed subscription expiry check logic

## Notes

- AI generation now runs in background, allowing user to see progress
- Purchase success is confirmed immediately, reducing user anxiety
- Smaller AI input may slightly reduce blueprint quality, but significantly improves reliability
- Subscription check improvements prevent false positive alerts
