# Apple Guideline 3.1.2(c) - Price Display Fix

## Issue from Apple

**Guideline 3.1.2(c) - Business - Payments - Subscriptions**

The auto-renewable subscription displays the **monthly calculated pricing** more clearly and conspicuously than the **billed amount**.

### Apple's Requirement:
- **Billed amount** must be the **most clear and conspicuous** pricing element
- Monthly calculated pricing must be **subordinate** (smaller, less prominent)
- Factors include: font size, color, location

## Solution Implemented

### ✅ Smart Solution: Use StoreKit Actual Prices

**Why This is Better:**
1. **Multi-currency support**: StoreKit automatically handles currency conversion
2. **Locale formatting**: Prices formatted according to user's region
3. **Always accurate**: Uses actual prices from App Store Connect
4. **Compliant**: Shows billed amount prominently

### Changes Made

#### 1. Updated `SubscriptionPackage` Enum

**Before:**
```swift
var price: String {
    // Monthly equivalent prices (WRONG - too prominent)
    case .yearly: return "US$ 7.59"      // Monthly equivalent
    case .quarterly: return "US$ 9.99"    // Monthly equivalent
    case .monthly: return "US$ 17.99"    // Monthly equivalent
}

var period: String {
    case .yearly: return "/月（年付）"    // Shows monthly equivalent
}
```

**After:**
```swift
// Get ACTUAL billed amount from StoreKit (most prominent)
func billedAmount(from products: [Product]) -> String {
    if let product = products.first(where: { $0.id == productID }) {
        // Use StoreKit's displayPrice - handles currency & locale automatically
        return product.displayPrice  // e.g., "89.99 USD" or "¥6,480" or "€79.99"
    }
    return fallbackPrice  // Fallback if StoreKit not available
}

// Calculate monthly equivalent (subordinate, smaller)
func monthlyEquivalent(from products: [Product]) -> String? {
    // Only for yearly/quarterly, calculated from actual StoreKit price
    // Returns "約 7.59 USD/月" (smaller, subordinate)
}
```

#### 2. Updated `PackageCard` Component

**Before:**
```swift
// Monthly equivalent was prominent (WRONG)
Text(price)  // "US$ 7.59" - large, bold
    .font(BrandTypography.title2)  // Large font
Text(package.period)  // "/月（年付）" - smaller
    .font(BrandTypography.subheadline)
```

**After:**
```swift
// Billed amount is MOST PROMINENT (CORRECT)
VStack(alignment: .leading) {
    HStack {
        Text(billedAmount)  // "89.99 USD" - LARGE, BOLD
            .font(BrandTypography.title)  // Large font
            .fontWeight(.bold)
        Text("/\(package.billingPeriod)")  // "/年" - smaller
            .font(BrandTypography.title3)  // Smaller font
    }
    
    // Monthly equivalent (subordinate, smaller)
    if let monthlyEq = monthlyEquivalent {
        Text(monthlyEq)  // "約 7.59 USD/月" - MUCH smaller
            .font(BrandTypography.caption)  // Smallest font
            .foregroundColor(BrandColors.tertiaryText)  // Less prominent color
    }
}
```

### Display Hierarchy (Apple Compliant)

**Most Prominent → Least Prominent:**

1. **Billed Amount** (e.g., "89.99 USD")
   - Font: `BrandTypography.title` (large)
   - Weight: `.bold`
   - Color: `BrandColors.primaryText` (most visible)

2. **Billing Period** (e.g., "/年")
   - Font: `BrandTypography.title3` (medium)
   - Color: `BrandColors.secondaryText` (less visible)

3. **Monthly Equivalent** (e.g., "約 7.59 USD/月")
   - Font: `BrandTypography.caption` (smallest)
   - Color: `BrandColors.tertiaryText` (least visible)
   - Only shown for yearly/quarterly subscriptions

## Examples

### Yearly Subscription Display:

**Before (WRONG):**
```
年付  節省 58%
US$ 7.59 /月（年付）  ← Monthly equivalent too prominent
```

**After (CORRECT):**
```
年付  節省 58%
89.99 USD /年  ← Billed amount prominent
約 7.59 USD/月  ← Monthly equivalent subordinate (small)
```

### Quarterly Subscription Display:

**Before (WRONG):**
```
季付  節省 48%
US$ 9.99 /月（季付，90天週期）  ← Monthly equivalent too prominent
```

**After (CORRECT):**
```
季付  節省 48%
29.99 USD /季  ← Billed amount prominent
約 9.99 USD/月  ← Monthly equivalent subordinate (small)
```

### Monthly Subscription Display:

**Before (WRONG):**
```
月付
US$ 17.99 /月  ← This was actually correct
```

**After (CORRECT):**
```
月付
17.99 USD /月  ← Billed amount (no monthly equivalent needed)
```

## Multi-Currency Support

### How It Works:

1. **StoreKit `displayPrice`** automatically:
   - Converts USD to user's local currency
   - Formats according to user's locale
   - Uses correct currency symbol

2. **Examples:**
   - **US User**: "89.99 USD"
   - **EU User**: "€79.99"
   - **JP User**: "¥6,480"
   - **HK User**: "HK$ 699"

3. **Monthly Equivalent**:
   - Calculated from actual StoreKit price
   - Formatted using user's locale
   - Shows "約" (approximately) prefix

## Code Changes Summary

### Files Modified:
1. `LifeLab/LifeLab/Views/InitialScan/PaymentView.swift`
   - Updated `SubscriptionPackage` enum
   - Added `billedAmount(from:)` method
   - Added `monthlyEquivalent(from:)` method
   - Updated `PackageCard` component

### Key Improvements:
- ✅ Billed amount is most prominent
- ✅ Monthly equivalent is subordinate
- ✅ Multi-currency support via StoreKit
- ✅ Locale-aware formatting
- ✅ Compliant with Apple guidelines

## Testing Checklist

- [ ] Verify billed amount displays prominently (large, bold)
- [ ] Verify monthly equivalent displays subordinate (small, less visible)
- [ ] Test with different currencies (USD, EUR, JPY, etc.)
- [ ] Test with StoreKit products loaded
- [ ] Test fallback when StoreKit products not available
- [ ] Verify yearly subscription shows monthly equivalent
- [ ] Verify quarterly subscription shows monthly equivalent
- [ ] Verify monthly subscription shows NO monthly equivalent

## Apple Guideline Compliance

✅ **Billed amount is most prominent**
- Large font (`BrandTypography.title`)
- Bold weight
- Primary text color
- Top position

✅ **Monthly equivalent is subordinate**
- Small font (`BrandTypography.caption`)
- Tertiary text color (less visible)
- Below billed amount
- Only for yearly/quarterly

✅ **Multi-currency support**
- Uses StoreKit `displayPrice`
- Automatic currency conversion
- Locale-aware formatting

## Response to Apple

**Suggested Response:**
```
We have revised the subscription purchase flow to ensure compliance with Guideline 3.1.2(c):

1. **Billed Amount is Most Prominent:**
   - Displayed in large, bold font (title size)
   - Primary text color for maximum visibility
   - Positioned at the top of each subscription option

2. **Monthly Equivalent is Subordinate:**
   - Displayed in small font (caption size)
   - Tertiary text color (less visible)
   - Positioned below the billed amount
   - Only shown for yearly and quarterly subscriptions

3. **Multi-Currency Support:**
   - Uses StoreKit's actual product prices
   - Automatically formats according to user's locale
   - Displays correct currency symbols

The billed amount (e.g., "89.99 USD/年") is now the most clear and conspicuous pricing element, with monthly equivalent pricing displayed in a subordinate position and size.
```

## Summary

✅ **Fixed**: Billed amount is now most prominent
✅ **Fixed**: Monthly equivalent is subordinate
✅ **Added**: Multi-currency support via StoreKit
✅ **Compliant**: Meets Apple Guideline 3.1.2(c) requirements

The solution is smarter than hardcoding prices because it:
- Supports all currencies automatically
- Uses actual App Store Connect prices
- Formats according to user's locale
- Always shows accurate pricing
