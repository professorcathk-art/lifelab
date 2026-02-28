# Response to App Store Review Feedback

**Submission ID:** 38cfd67e-8fed-40d4-8876-fadcd50f8cfe  
**Version:** 1.3.1 (Build 2)  
**Date:** February 28, 2026

---

Dear App Review Team,

Thank you for your feedback. We have addressed all the issues identified in your review. Below is a summary of the changes made:

## 1. Guidelines 5.1.1(i) and 5.1.2(i) - Privacy - Data Collection and Data Use

**Issue:** The app did not clearly explain what data is sent, identify who receives it, and ask for user permission before sharing data with a third-party AI service.

**Resolution:**
- ✅ **Explicit Consent Mechanism**: Added a mandatory AI service consent checkbox on the login/signup page. Users must explicitly check the box and agree to the "AI 服務使用條款" (AI Service Terms) before they can proceed with registration or login. The app will not send any data to the AI service until explicit consent is obtained.

- ✅ **Clear Data Disclosure**: The consent checkbox includes a tappable link to the privacy policy, which clearly explains:
  - **What data is sent**: Interests, strengths, values, basic information (if provided), and deepening exploration data (if provided)
  - **Who receives the data**: Anthropic Claude Sonnet 4.5 (via AIML API) - Anthropic Inc.
  - **Data protection**: All data transmission uses HTTPS encryption, and Anthropic does not use the data for AI model training

- ✅ **Updated Privacy Policy**: The privacy policy (available at the link provided in App Store Connect) has been updated to include:
  - Detailed explanation of what data is collected and how
  - Explicit identification of Anthropic as the third-party AI service provider
  - Clear statement that data is only shared after explicit user consent
  - Confirmation that Anthropic provides equal or equivalent data protection standards

**Implementation Details:**
- Consent status is stored in UserDefaults (user-specific key)
- The app checks consent status before any AI API calls
- Users can review the privacy policy at any time through the consent checkbox link

## 2. Guideline 4.0 - Design - Typography

**Issue:** The app included hard-to-read type or typography.

**Resolution:**
- ✅ **Theme Switching Fix**: Fixed all instances where UI elements did not properly update when switching between light and dark modes. Added `@StateObject private var themeManager = ThemeManager.shared` to all custom components to ensure proper theme observation.

- ✅ **Text Visibility**: Ensured all text is clearly visible in both light and dark modes:
  - White text on dark backgrounds in dark mode
  - Dark text on light backgrounds in light mode
  - All UI components (text fields, buttons, labels, cards) now properly respond to theme changes

- ✅ **Comprehensive Review**: Conducted a thorough review of all screens to ensure consistent typography and readability across the entire app, including:
  - Login/Signup screens
  - Home/Dashboard
  - Profile page
  - Deepening Exploration page
  - Task Management page
  - Settings page

## 3. Guideline 2.1 - Performance - App Completeness (IAP Submission)

**Issue:** In-app purchase products (年/季/月付) were not submitted for review.

**Resolution:**
- ✅ **IAP Products Submitted**: All three subscription products (年/季/月付) have been properly configured and submitted for review in App Store Connect.

- ✅ **Metadata Completed**: All required metadata for the in-app purchase products has been completed, including:
  - Product descriptions
  - Localization information
  - App Review screenshots
  - Pricing information

- ✅ **Build Submission**: A new binary (Version 1.3.1, Build 2) has been uploaded with the IAP products properly linked to the app version.

## 4. Guideline 2.1 - Performance - App Completeness (IAP Purchase Bug)

**Issue:** An error message appeared during purchase of the plan, creating a poor user experience.

**Resolution:**
- ✅ **Purchase Flow Optimization**: 
  - Purchase is now immediately acknowledged upon successful payment
  - AI generation runs in the background (non-blocking) after purchase confirmation
  - Users are redirected to a dedicated progress page with a visual progress indicator while AI generates their life blueprint

- ✅ **Error Handling Improvements**:
  - Added retry logic for product loading with exponential backoff
  - Enhanced error messages with clear, actionable guidance
  - Improved network error handling and user feedback

- ✅ **Background Task Support**: Implemented proper background task handling to ensure AI generation continues even if the user switches screens or the app goes to background.

- ✅ **Subscription Check**: Enhanced subscription status verification to prevent false positives and ensure accurate subscription state management.

**Testing Notes:**
- All IAP flows have been tested in sandbox environment
- Purchase flow works correctly on both iPhone and iPad
- Error handling has been verified for various edge cases
- Background AI generation has been tested for reliability

---

## Summary

All issues identified in your review have been addressed:

1. ✅ **Privacy Compliance**: Explicit consent mechanism, clear data disclosure, and updated privacy policy
2. ✅ **Typography**: Fixed all readability issues across light and dark modes
3. ✅ **IAP Submission**: All products submitted and properly linked to the app version
4. ✅ **IAP Purchase Flow**: Fixed purchase bugs and improved user experience

The app is now ready for review. We appreciate your patience and look forward to your approval.

Best regards,  
LifeLab Development Team
