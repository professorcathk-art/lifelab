# Quick In-App Purchase Setup Checklist

## ⚠️ CRITICAL: Do These Steps in Order

### Step 1: Upload Screenshot (REQUIRED FIRST)
- [ ] Go to App Store Connect → My Apps → LifeLab → App Store tab
- [ ] Scroll to "App Review Information"
- [ ] Upload at least ONE screenshot (6.7" or 6.5" iPhone size)
- [ ] **Cannot proceed without this!**

### Step 2: Create Subscription Group
- [ ] Go to Features → In-App Purchases
- [ ] Click "+" → Select "Auto-Renewable Subscriptions"
- [ ] Name: `LifeLab Premium Subscriptions`
- [ ] Click "Create"

### Step 3: Create Product 1 - Annual (年付)
- [ ] In subscription group, click "+"
- [ ] **Product ID:** `com.resonance.lifelab.annually` ⚠️ EXACT MATCH
- [ ] Duration: 1 Year
- [ ] Price: $89.99 (or $91.08)
- [ ] Display Name (English): `Annual`
- [ ] Display Name (Chinese): `年付`
- [ ] Description: Add in English and Chinese
- [ ] Click "Create"

### Step 4: Create Product 2 - Quarterly (季付)
- [ ] In subscription group, click "+"
- [ ] **Product ID:** `com.resonance.lifelab.quarterly` ⚠️ EXACT MATCH
- [ ] Duration: 3 Months
- [ ] Price: $29.97
- [ ] Display Name (English): `Quarterly`
- [ ] Display Name (Chinese): `季付`
- [ ] Description: Add in English and Chinese
- [ ] Click "Create"

### Step 5: Create Product 3 - Monthly (月付)
- [ ] In subscription group, click "+"
- [ ] **Product ID:** `com.resonance.lifelab.monthly` ⚠️ EXACT MATCH
- [ ] Duration: 1 Month
- [ ] Price: $17.99
- [ ] Display Name (English): `Monthly`
- [ ] Display Name (Chinese): `月付`
- [ ] Description: Add in English and Chinese
- [ ] Click "Create"

### Step 6: Submit Products
- [ ] Go to each product (Annual, Quarterly, Monthly)
- [ ] Click "Submit for Review" button
- [ ] Confirm submission
- [ ] Status should show "Waiting for Review"

### Step 7: Upload Binary
- [ ] Build and archive app in Xcode
- [ ] Distribute to App Store Connect
- [ ] Wait for processing (10-30 min)
- [ ] In App Store tab, select new build

### Step 8: Submit App
- [ ] Verify all 3 products are submitted
- [ ] Verify new binary is selected
- [ ] Click "Submit for Review"

---

## Product IDs (Copy-Paste These)

```
com.resonance.lifelab.annually
com.resonance.lifelab.quarterly
com.resonance.lifelab.monthly
```

**⚠️ WARNING:** These MUST match exactly (case-sensitive, no spaces)

---

## Quick Reference

**Where to go:**
- App Store Connect: https://appstoreconnect.apple.com
- My Apps → LifeLab → Features → In-App Purchases

**What "binary" means:**
- Binary = Your compiled app file (.ipa)
- You upload it through Xcode → Archive → Distribute App

**Timeline:**
- Setup: 30-60 minutes
- Product review: 24-48 hours
- App review: 1-3 days

---

## If You Get Stuck

1. **"Cannot submit - missing screenshot"**
   → Upload screenshot first (Step 1)

2. **"Product ID already exists"**
   → Check if you created it before, or use different ID

3. **"Products not showing in app"**
   → Verify product IDs match exactly
   → Make sure products are submitted
   → Test in sandbox first

4. **Need help?**
   → See detailed guide: `IN_APP_PURCHASE_SETUP_GUIDE.md`
   → Apple Developer Support: https://developer.apple.com/contact/
