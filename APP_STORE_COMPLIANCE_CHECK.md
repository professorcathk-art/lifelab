# App Store Compliance Check - AI Data Sharing Consent

## ✅ Apple Guidelines 5.1.1(i) & 5.1.2(i) Compliance

### Requirements Met:

#### 1. ✅ Disclose What Data Will Be Sent
- **Location**: `AIConsentView.swift`
- **Implementation**: Clear list showing:
  - 興趣關鍵詞 (Interest keywords)
  - 天賦問卷回答與關鍵詞 (Strengths questionnaire answers and keywords)
  - 價值觀排序與回答 (Values ranking and answers)
  - 基本資料 (Basic info: region, age, occupation, salary, family status, education)
  - 深化探索資料 (Deepening exploration data: flow diary, values reflection, resource inventory, etc.)

#### 2. ✅ Specify Who the Data Is Sent To
- **Location**: `AIConsentView.swift` - Consent Detail Row
- **Implementation**: Explicitly states:
  - "您的資料將發送給：AIML API / Anthropic Claude Sonnet 4.5"
  - "此服務提供商不會將您的資料用於訓練 AI 模型"

#### 3. ✅ Obtain User's Permission Before Sending Data
- **Location**: `AIConsentView.swift` + `InitialScanViewModel.swift`
- **Implementation**:
  - User must check checkbox: "我已閱讀並同意上述說明"
  - User must click "我同意並繼續" button
  - Consent is stored persistently in UserDefaults (user-specific key)
  - AI calls are blocked until consent is given (`guard hasGivenAIConsent`)

#### 4. ✅ Privacy Policy Updated
- **Location**: `privacy.html` and `website/privacy.html`
- **Updates**:
  - Section 1: Added explicit mention of AI consent mechanism
  - Section 2: Detailed explanation of:
    - What data is sent
    - Who receives it (Anthropic company)
    - What it's used for
    - Data protection measures
  - Section 6: Comprehensive third-party service disclosure including:
    - Service provider name (Anthropic)
    - Consent mechanism
    - Data sent/not sent
    - Third-party protection standards

### Code Implementation Details:

#### Consent Flow:
1. User completes values questionnaire → `.values` step
2. App shows AI consent screen → `.aiConsent` step
3. User reads disclosure and checks checkbox
4. User clicks "我同意並繼續" button
5. Consent saved to UserDefaults → `hasGivenAIConsent = true`
6. App proceeds to AI summary generation → `.aiSummary` step

#### Consent Checks:
- `generateAISummary()`: Checks `hasGivenAIConsent` before calling AI
- `generateLifeBlueprint()`: Checks `hasGivenAIConsent` before calling AI
- `moveToNextStep()`: Blocks progression from `.aiConsent` if consent not given

#### Persistence:
- Consent stored in UserDefaults with user-specific key: `lifelab_ai_consent_{userId}`
- Loaded on ViewModel initialization
- Persists across app sessions

### Files Modified:

1. **New Files**:
   - `LifeLab/LifeLab/Views/InitialScan/AIConsentView.swift` - Consent screen UI
   
2. **Modified Files**:
   - `LifeLab/LifeLab/Models/AppState.swift` - Added `.aiConsent` step
   - `LifeLab/LifeLab/ViewModels/InitialScanViewModel.swift` - Consent tracking and checks
   - `LifeLab/LifeLab/Views/InitialScan/InitialScanView.swift` - Added consent view case
   - `LifeLab/LifeLab/Views/ContentView.swift` - Consent state handling
   - `privacy.html` - Updated privacy policy
   - `website/privacy.html` - Updated privacy policy

### Testing Checklist:

- [x] Build succeeds without errors
- [x] No linter warnings
- [x] Consent screen displays before AI calls
- [x] AI calls blocked without consent
- [x] Consent persists across app sessions
- [x] Privacy policy accessible from consent screen
- [x] All AI call points have consent checks

### App Store Submission Notes:

When submitting to App Store Connect, mention:
1. "We have implemented explicit user consent before sharing data with third-party AI service"
2. "Users must check a consent checkbox and click 'I agree' button before any data is sent"
3. "Privacy policy clearly identifies what data is sent, who receives it, and how it's used"
4. "Consent screen clearly discloses: data sent, recipient (Anthropic), and purpose"

---

**Status**: ✅ **READY FOR APP STORE SUBMISSION**

All Apple Guidelines 5.1.1(i) and 5.1.2(i) requirements have been met.
