# In-App Purchase Setup Guide - App Store Connect

## Issue Summary
Apple requires that all in-app purchase products referenced in your app must be created and submitted for review in App Store Connect before your app can be approved.

**Your Products:**
- 年付 (Yearly): `com.resonance.lifelab.annually`
- 季付 (Quarterly): `com.resonance.lifelab.quarterly`
- 月付 (Monthly): `com.resonance.lifelab.monthly`

## Step-by-Step Guide

### Prerequisites
1. ✅ Your app must already be created in App Store Connect
2. ✅ You must have Admin or App Manager access
3. ✅ You need at least ONE App Review screenshot uploaded (required by Apple)

---

## Part 1: Upload App Review Screenshot (REQUIRED FIRST)

**⚠️ IMPORTANT:** You MUST upload at least one App Review screenshot before you can submit in-app purchases.

### Steps:
1. Go to [App Store Connect](https://appstoreconnect.apple.com)
2. Navigate to **My Apps** → Select **LifeLab**
3. Go to **App Store** tab
4. Select **iOS App** (or your app version)
5. Scroll to **App Review Information** section
6. Under **Screenshots**, upload at least one screenshot:
   - **Required sizes:** 6.7" (iPhone 14 Pro Max) or 6.5" (iPhone 11 Pro Max)
   - **Format:** PNG or JPEG
   - **Content:** Should show your app's main functionality
   - **Recommendation:** Use a screenshot of the login screen or main dashboard

**Note:** You can use the same screenshot for all required sizes, or use Xcode's screenshot tool to generate all sizes automatically.

---

## Part 2: Create Subscription Group

### Steps:
1. In App Store Connect, go to **My Apps** → **LifeLab**
2. Click on **Features** tab (top navigation)
3. Click **In-App Purchases** (left sidebar)
4. Click **+** button (top right) or **Create** button
5. Select **Auto-Renewable Subscriptions**
6. Click **Create**

### Configure Subscription Group:
1. **Subscription Group Reference Name:**
   - Enter: `LifeLab Premium Subscriptions`
   - This is internal only, users won't see this

2. **Subscription Group ID:**
   - Auto-generated (e.g., `21481234`)
   - Note this down - you'll need it for all three products

3. Click **Create**

---

## Part 3: Create First Subscription Product (Yearly - 年付)

### Steps:
1. In the subscription group you just created, click **+** or **Create Subscription**
2. Fill in the following:

#### Basic Information:
- **Subscription Reference Name:** `LifeLab Annual Subscription`
- **Product ID:** `com.resonance.lifelab.annually` ⚠️ **MUST MATCH EXACTLY**
- **Subscription Duration:** `1 Year`

#### Subscription Pricing:
1. Click **Add Subscription Pricing**
2. Select **United States** (or your primary market)
3. Set price: **$89.99** (or calculate: $7.59/month × 12 = $91.08, but you can round to $89.99)
4. Click **Next**
5. Review and click **Create**

#### Localization (Required):
Click **Add Localization** for each language:

**English (U.S.):**
- **Display Name:** `LifeLab Annual Subscription`
- **Description:** `Unlock your personalized life blueprint with annual subscription. Save 58% compared to monthly pricing.`

**Chinese (Traditional - Taiwan):**
- **Display Name:** `LifeLab 年付訂閱`
- **Description:** `解鎖您的個人化生命藍圖，年付訂閱可節省 58% 費用。`

**Chinese (Simplified - China):**
- **Display Name:** `LifeLab 年付订阅`
- **Description:** `解锁您的个性化生命蓝图，年付订阅可节省 58% 费用。`

#### Subscription Display Name:
- **English:** `Annual`
- **Chinese (Traditional):** `年付`
- **Chinese (Simplified):** `年付`

#### Review Information:
- **Review Notes:** `This is an annual subscription for LifeLab premium features. Users can unlock their personalized life blueprint after completing the initial questionnaire.`
- **Screenshot:** Upload a screenshot showing the subscription screen (optional but recommended)

---

## Part 4: Create Second Subscription Product (Quarterly - 季付)

### Steps:
1. In the same subscription group, click **+** or **Create Subscription**
2. Fill in:

#### Basic Information:
- **Subscription Reference Name:** `LifeLab Quarterly Subscription`
- **Product ID:** `com.resonance.lifelab.quarterly` ⚠️ **MUST MATCH EXACTLY**
- **Subscription Duration:** `3 Months`

#### Subscription Pricing:
1. Click **Add Subscription Pricing**
2. Select **United States**
3. Set price: **$29.97** (or $9.99/month × 3 = $29.97)
4. Click **Next** → **Create**

#### Localization:
**English (U.S.):**
- **Display Name:** `LifeLab Quarterly Subscription`
- **Description:** `Unlock your personalized life blueprint with quarterly subscription. Save 48% compared to monthly pricing.`

**Chinese (Traditional):**
- **Display Name:** `LifeLab 季付訂閱`
- **Description:** `解鎖您的個人化生命藍圖，季付訂閱可節省 48% 費用。`

**Chinese (Simplified):**
- **Display Name:** `LifeLab 季付订阅`
- **Description:** `解锁您的个性化生命蓝图，季付订阅可节省 48% 费用。`

#### Subscription Display Name:
- **English:** `Quarterly`
- **Chinese (Traditional):** `季付`
- **Chinese (Simplified):** `季付`

---

## Part 5: Create Third Subscription Product (Monthly - 月付)

### Steps:
1. In the same subscription group, click **+** or **Create Subscription**
2. Fill in:

#### Basic Information:
- **Subscription Reference Name:** `LifeLab Monthly Subscription`
- **Product ID:** `com.resonance.lifelab.monthly` ⚠️ **MUST MATCH EXACTLY**
- **Subscription Duration:** `1 Month`

#### Subscription Pricing:
1. Click **Add Subscription Pricing**
2. Select **United States**
3. Set price: **$17.99**
4. Click **Next** → **Create**

#### Localization:
**English (U.S.):**
- **Display Name:** `LifeLab Monthly Subscription`
- **Description:** `Unlock your personalized life blueprint with monthly subscription.`

**Chinese (Traditional):**
- **Display Name:** `LifeLab 月付訂閱`
- **Description:** `解鎖您的個人化生命藍圖，月付訂閱。`

**Chinese (Simplified):**
- **Display Name:** `LifeLab 月付订阅`
- **Description:** `解锁您的个性化生命蓝图，月付订阅。`

#### Subscription Display Name:
- **English:** `Monthly`
- **Chinese (Traditional):** `月付`
- **Chinese (Simplified):** `月付`

---

## Part 6: Set Up Subscription Group Display Order

### Steps:
1. Go back to your **Subscription Group**
2. Click **Edit** next to "Subscription Display Order"
3. Arrange in order (drag to reorder):
   1. **Monthly** (Highest price shown first)
   2. **Quarterly**
   3. **Annual** (Best value - shown last)
4. Click **Save**

**Note:** Apple typically shows subscriptions from highest to lowest price, but you can customize the order.

---

## Part 7: Submit Products for Review

### Steps:
1. Go to **In-App Purchases** section
2. For EACH product (Annual, Quarterly, Monthly):
   - Click on the product
   - Scroll to bottom
   - Click **Submit for Review** button
   - Confirm submission

### Important Notes:
- ⚠️ All three products must be submitted
- ⚠️ Products will show status as "Waiting for Review"
- ⚠️ Review typically takes 24-48 hours
- ⚠️ You can submit products even if your app binary isn't ready yet

---

## Part 8: Upload New App Binary

### Steps:
1. Build your app in Xcode:
   ```bash
   # Archive your app
   Product → Archive
   ```

2. After archiving:
   - Click **Distribute App**
   - Select **App Store Connect**
   - Click **Upload**
   - Follow the wizard to upload

3. Or use command line:
   ```bash
   xcodebuild -archivePath build/LifeLab.xcarchive \
     -exportOptionsPlist ExportOptions.plist \
     -exportPath build
   ```

4. In App Store Connect:
   - Go to **TestFlight** tab
   - Wait for processing (usually 10-30 minutes)
   - Once processed, go to **App Store** tab
   - Select your app version
   - Under **Build**, select the new build
   - Click **Save**

---

## Part 9: Submit App for Review

### Steps:
1. In App Store Connect, go to **App Store** tab
2. Make sure:
   - ✅ All three in-app purchases are submitted
   - ✅ New binary is selected
   - ✅ App Review Information is complete
   - ✅ Screenshots are uploaded
   - ✅ Description and metadata are complete

3. Click **Submit for Review** button (top right)

---

## Verification Checklist

Before submitting, verify:

- [ ] All three product IDs match exactly:
  - `com.resonance.lifelab.annually`
  - `com.resonance.lifelab.quarterly`
  - `com.resonance.lifelab.monthly`

- [ ] All three products are in the same subscription group

- [ ] All products have:
  - [ ] Reference name
  - [ ] Product ID (matching code)
  - [ ] Duration (1 Year, 3 Months, 1 Month)
  - [ ] Pricing set
  - [ ] Localizations (at least English)
  - [ ] Display names
  - [ ] Descriptions

- [ ] At least one App Review screenshot is uploaded

- [ ] All three products are submitted for review

- [ ] New app binary is uploaded and selected

---

## Common Issues & Solutions

### Issue 1: "Product ID already exists"
**Solution:** Product IDs are unique across all apps. If you see this error, you may have created it before. Check your existing in-app purchases.

### Issue 2: "Cannot submit - missing screenshot"
**Solution:** You MUST upload at least one App Review screenshot before submitting in-app purchases.

### Issue 3: "Products not showing in app"
**Solution:** 
- Verify product IDs match exactly (case-sensitive)
- Make sure products are submitted and approved
- Test in sandbox environment first
- Check that your app is using StoreKit 2 correctly

### Issue 4: "Price doesn't match"
**Solution:** 
- Your code shows monthly equivalent prices ($7.59, $9.99, $17.99)
- But StoreKit products should be:
  - Annual: $89.99/year (or $91.08/year = $7.59 × 12)
  - Quarterly: $29.97/3 months (or $29.97 = $9.99 × 3)
  - Monthly: $17.99/month
- The code will display monthly equivalents, but StoreKit handles actual pricing

---

## Testing Before Submission

### Sandbox Testing:
1. Create a sandbox test account in App Store Connect:
   - **Users and Access** → **Sandbox Testers** → **+**
   - Use a test email (doesn't need to be real)

2. Test in your app:
   - Sign out of App Store
   - When prompted, sign in with sandbox account
   - Test purchasing each subscription tier
   - Verify products load correctly

### Important Notes:
- Sandbox purchases don't charge real money
- Sandbox subscriptions expire quickly (for testing)
- Use sandbox to verify product IDs match

---

## Timeline Estimate

- **Creating products:** 30-60 minutes
- **Product review:** 24-48 hours (usually faster)
- **App binary upload:** 10-30 minutes processing
- **App review:** 1-3 days (after all products approved)

**Total:** Plan for 2-4 days from start to approval

---

## Additional Resources

- [Apple's In-App Purchase Guide](https://developer.apple.com/in-app-purchase/)
- [StoreKit 2 Documentation](https://developer.apple.com/documentation/storekit)
- [App Store Connect Help](https://help.apple.com/app-store-connect/)

---

## Need Help?

If you encounter issues:
1. Check Apple's documentation links above
2. Verify product IDs match exactly
3. Ensure all required fields are filled
4. Make sure screenshots are uploaded
5. Contact Apple Developer Support if needed

---

## Summary

**What you need to do:**
1. ✅ Upload App Review screenshot (REQUIRED FIRST)
2. ✅ Create subscription group
3. ✅ Create 3 subscription products with exact product IDs
4. ✅ Submit all 3 products for review
5. ✅ Upload new app binary
6. ✅ Submit app for review

**Product IDs (must match exactly):**
- `com.resonance.lifelab.annually`
- `com.resonance.lifelab.quarterly`
- `com.resonance.lifelab.monthly`

Good luck! 🚀
