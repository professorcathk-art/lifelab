# Currency Consistency Fix - Monthly Equivalent Price

## Problem Identified

**Issue**: The annual plan showed **HKD** (Hong Kong Dollars) for the billed amount, but **GBP** (British Pounds) for the monthly equivalent price. This was confusing and incorrect.

**Root Cause**: 
- `billedAmount()` uses `product.displayPrice` which correctly shows the product's currency (HKD)
- `monthlyEquivalent()` was using `Locale.current` to format the price, which might be different from the product's actual currency

## Solution Implemented

### ✅ Fixed: Use Product's Price Format Style

**Before (WRONG):**
```swift
func monthlyEquivalent(from products: [Product]) -> String? {
    // ...
    let formatter = NumberFormatter()
    formatter.numberStyle = .currency
    formatter.locale = Locale.current  // ❌ Uses device locale, not product currency
    // ...
}
```

**After (CORRECT):**
```swift
func monthlyEquivalent(from products: [Product]) -> String? {
    // ...
    // CRITICAL: Use product.priceFormatStyle to get the SAME currency as displayPrice
    let priceFormatStyle = product.priceFormatStyle
    
    // Format the monthly price using the SAME format style as the product
    let monthlyPriceDecimal = Decimal(monthlyPrice)
    let formattedMonthlyPrice = monthlyPriceDecimal.formatted(priceFormatStyle)
    
    return "約 \(formattedMonthlyPrice)/月"
}
```

### How It Works

1. **`product.priceFormatStyle`**: Contains the exact formatting style used by `displayPrice`
   - Includes currency code (HKD, GBP, USD, etc.)
   - Includes currency symbol ($, £, HK$, etc.)
   - Includes locale-specific formatting (decimal separators, grouping)

2. **`Decimal.formatted(priceFormatStyle)`**: Formats the calculated monthly price using the **exact same style** as the product's billed amount

3. **Result**: Both billed amount and monthly equivalent now use the **same currency** and formatting

## Example

### Before (WRONG):
```
年付  節省 58%
HK$ 699.00 /年  ← HKD
約 £58.25/月    ← GBP (WRONG!)
```

### After (CORRECT):
```
年付  節省 58%
HK$ 699.00 /年  ← HKD
約 HK$ 58.25/月 ← HKD (CORRECT!)
```

## Technical Details

### StoreKit 2 Product Properties

- **`product.displayPrice`**: Formatted string (e.g., "HK$ 699.00")
  - Uses `product.priceFormatStyle` internally
  - Already localized and formatted

- **`product.price`**: `Decimal` value (e.g., 699.00)
  - Raw numeric value
  - No currency information

- **`product.priceFormatStyle`**: `FloatingPointFormatStyle<Decimal>.Currency`
  - Contains currency code, symbol, locale
  - Used by `displayPrice` for formatting
  - **This is what we now use for monthly equivalent**

### Why This Works

1. **Same Source**: Both `displayPrice` and our monthly equivalent use `priceFormatStyle`
2. **Consistent Currency**: Guaranteed to use the same currency code
3. **Consistent Formatting**: Same decimal separators, grouping, symbol placement
4. **No Parsing Needed**: No need to extract currency from strings

## Testing Checklist

- [x] Build succeeds
- [ ] Test with HKD products (should show HKD for both billed and monthly)
- [ ] Test with GBP products (should show GBP for both)
- [ ] Test with USD products (should show USD for both)
- [ ] Test with EUR products (should show EUR for both)
- [ ] Test with JPY products (should show JPY for both)
- [ ] Verify formatting matches (decimal places, grouping)

## Benefits

✅ **Currency Consistency**: Billed amount and monthly equivalent always match
✅ **No Parsing**: Uses StoreKit's built-in formatting
✅ **Future-Proof**: Works with any currency StoreKit supports
✅ **Cleaner Code**: Simpler implementation, no manual currency detection

## Files Modified

- `LifeLab/LifeLab/Views/InitialScan/PaymentView.swift`
  - Updated `monthlyEquivalent(from:)` method
  - Now uses `product.priceFormatStyle` instead of `Locale.current`

---

**Status**: ✅ **FIXED**  
**Build**: ✅ **SUCCESS**  
**Ready for Testing**: ✅ **YES**
