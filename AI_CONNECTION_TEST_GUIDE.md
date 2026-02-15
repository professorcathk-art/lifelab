# AI Connection Test Guide
**Date**: 2026-01-18

---

## 🧪 How to Test AI Connection

### Step 1: Open Xcode Console
1. Open Xcode
2. Run the app (⌘R)
3. Go to: **View → Debug Area → Activate Console** (or press ⌘⇧Y)
4. Keep console visible during testing

### Step 2: Complete Survey
1. Complete the initial scan survey
2. Select interests, answer strengths questions, rank values
3. Watch console for logs

### Step 3: Generate Version 1 Blueprint
1. Complete payment step
2. Watch console for these logs:

**Expected Logs (AI Working)**:
```
🔵 Making API request to: https://api.aimlapi.com/v1/chat/completions
🔵 Model: anthropic/claude-sonnet-4.5
🔵 API Key (first 10 chars): 49a6737099...
🔵 Request body size: [number] bytes
🔵 User data - Interests: [your interests]
🔵 User data - Strengths: [your strengths]
🔵 User data - Values: [your values]
🔵 Response status: 200
✅ Successfully received response
✅ Response content length: [number] characters
✅ Response preview: [JSON content]...
🔵 Attempting to parse JSON from response...
✅ Successfully parsed JSON from AI response
✅ JSON keys: vocationDirections, strengthsSummary, feasibilityAssessment
✅ Found 3 vocation directions
  Direction 1: [specific job title]...
✅ Strengths summary length: [number] characters
✅ Feasibility assessment length: [number] characters
✅ AI-generated directions:
  1. [Job Title 1]
     Description: [description]...
  2. [Job Title 2]
     Description: [description]...
✅ AI-generated strengths summary: [content]...
✅ Saving Version 1 blueprint:
  - Directions count: 3
  - First direction title: [specific title]
✅ Added Version 1 to lifeBlueprints array
```

**If AI NOT Working**:
```
❌ API Error (400/401/403): [error message]
OR
❌ JSON parsing failed, using fallback
❌ Response preview: [shows what AI returned]
⚠️ Using fallback blueprint (AI generation failed)
```

### Step 4: Check Profile View
1. Go to "個人檔案" tab
2. Check if Version 1 blueprint shows
3. Verify content is:
   - **Personalized** (mentions your specific interests/strengths)
   - **Different** from generic placeholder
   - **Specific** (has actual job titles, not generic descriptions)

### Step 5: Generate Version 2 Blueprint
1. Complete all deepening exploration steps
2. Click "生成更新版生命藍圖 (Version 2)"
3. Watch console for similar logs
4. Check if Version 2 content is different from Version 1

---

## 🔍 Troubleshooting

### Problem: Always Shows Same Content

**Check Console For**:
- `⚠️ Using fallback` → AI not working, using fallback
- `❌ JSON parsing failed` → AI returned invalid JSON
- `❌ API Error` → API connection issue

**Solutions**:
1. Check API key is correct
2. Check internet connection
3. Check API service status
4. Review error message in console

### Problem: No Logs Appearing

**Check**:
- Console is visible (⌘⇧Y)
- App is running (not crashed)
- Logs are not filtered

### Problem: API Error 401/403

**Cause**: Invalid API key
**Solution**: Verify API key in `APIConfig.swift`

### Problem: API Error 400

**Cause**: Invalid request format
**Solution**: Check request body structure

### Problem: JSON Parsing Failed

**Cause**: AI returned non-JSON or malformed JSON
**Solution**: Check console for response preview to see what AI returned

---

## ✅ Success Indicators

### AI is Working If You See:
1. ✅ `Response status: 200`
2. ✅ `Successfully parsed JSON from AI response`
3. ✅ `Found 3 vocation directions` (or more)
4. ✅ `AI-generated directions:` with specific job titles
5. ✅ Content in 個人檔案 is **different each time**
6. ✅ Content mentions your **specific** interests/strengths
7. ✅ Content has **actual job titles**, not generic descriptions

### AI is NOT Working If You See:
1. ❌ `API Error (400/401/403/500)`
2. ❌ `JSON parsing failed, using fallback`
3. ❌ `⚠️ Using fallback blueprint`
4. ❌ `⚠️ Directions array is empty`
5. ❌ Content in 個人檔案 is **same every time**
6. ❌ Content is **generic** (doesn't mention your specific inputs)
7. ❌ Content has **generic titles** like "基於您的興趣和天賦的方向一"

---

## 📊 Test Results Template

**Test Date**: ___________

**API Connection**:
- [ ] Request sent successfully
- [ ] Response status: 200
- [ ] Response received

**JSON Parsing**:
- [ ] JSON parsed successfully
- [ ] Directions extracted
- [ ] Summary extracted
- [ ] Assessment extracted

**Content Quality**:
- [ ] Content is personalized
- [ ] Content mentions specific interests
- [ ] Content has specific job titles
- [ ] Content is different from previous generation

**Data Persistence**:
- [ ] Version 1 saved correctly
- [ ] Version 2 saved correctly
- [ ] Both versions show in 個人檔案
- [ ] Content persists after app restart

---

**Last Updated**: 2026-01-18
