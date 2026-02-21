# Apple App Review Response - LifeLab (Concise Version)

## Answers to Apple's Questions

### 1. Does your app use third-party AI service?

**Yes.** Our app uses AIML API (api.aimlapi.com) with Anthropic Claude Sonnet 4.5 model to generate personalized career guidance and life blueprint recommendations.

---

### 2. What personal data does it collect/send to third-party AI service?

**Data sent to AI service (only for generating recommendations):**

- **Basic info** (optional): Region, age, occupation, salary, family status, education
- **Interests**: User-selected keywords
- **Strengths**: Selected keywords and questionnaire answers
- **Values**: Core values ranking and reflection answers
- **Deepening data** (optional): Flow diary entries, resource inventory, acquired strengths

**Important:**
- **No PII sent**: No names, emails, device IDs, or authentication tokens
- **HTTPS encrypted** transmission
- Data sent **only when user clicks** "開啟我的理想人生" button
- **Not used for training** (per AIML API privacy policy)

**Data NOT sent:**
- Authentication credentials
- Email addresses
- Device identifiers
- Payment information

---

### 3. Does the app obtain user's consent before sending data?

**Yes.** Explicit consent is obtained through:

1. **Explicit user action**: User must click "開啟我的理想人生" button, which clearly states "解鎖專屬 AI 深度分析" (Unlock exclusive AI deep analysis)

2. **Transparent disclosure**: Before data collection, users see: "請填寫您的基本資料，這將幫助AI為您提供更精準的建議" (Please fill in your basic information, which will help AI provide more accurate recommendations)

3. **Privacy Policy**: Available in App Store Connect and explains AI service usage

4. **User control**: Users can delete account/data anytime via Settings → Account → Delete Account

5. **No automatic transmission**: Data sent only when user explicitly requests AI generation

**Consent flow:**
User fills information → Sees AI usage notice → Clicks button (explicit consent) → Data sent to AI → Receives recommendations

---

## How to Resubmit

1. **App Store Connect** → My Apps → LifeLab → Resolution Center → Reply to App Review
2. **Copy the 3 answers above** into the reply box
3. **Update App Privacy**:
   - Data Collection: Yes
   - Third-Party Sharing: Yes → Add AIML API (Purpose: AI Analysis, Data: User Content, Not Linked to User: Yes)
4. **Privacy Policy URL**: Ensure it's filled in App Information page
5. **Submit for Review**
