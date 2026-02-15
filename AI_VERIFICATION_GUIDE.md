# AI Verification Guide

## How to Verify AI is Working Correctly

### 1. Check Console Logs

When generating 生命藍圖, check the Xcode console for these log messages:

**✅ Success Indicators:**
```
🔵 Making API request to: https://api.aimlapi.com/v1/chat/completions
🔵 Model: anthropic/claude-sonnet-4.5
🔵 Response status: 200
✅ Successfully received response.
✅ Successfully parsed JSON from AI response
✅ JSON keys: vocationDirections, strengthsSummary, feasibilityAssessment
✅ Found 3 vocation directions
  Direction 1: [Title]...
  Direction 2: [Title]...
  Direction 3: [Title]...
✅ Strengths summary length: 245 characters
✅ Feasibility assessment length: 198 characters
✅ Returning AI-generated blueprint with 3 directions
```

**❌ Error Indicators:**
```
❌ API Error (400): [error message]
❌ Failed to parse response JSON. Raw response: [response]
❌ JSON parsing failed, using fallback. Response: [first 500 chars]
⚠️ No vocationDirections found in JSON
⚠️ Directions array is empty, using fallback
```

### 2. Verify in Profile View

**If AI is working correctly:**
- 生命藍圖 should show **different content** each time (based on your inputs)
- Each direction should have:
  - Unique title (not generic)
  - Detailed description (150-200 words)
  - Market feasibility analysis
- Strengths summary should be personalized
- Feasibility assessment should be specific to your profile

**If AI is NOT working (using fallback):**
- Content will be **the same every time**
- Generic descriptions like "您的獨特優勢在於結合了..."
- No specific job titles or career paths
- Same placeholder text

### 3. Test Different Inputs

To verify AI is truly generating content:

1. **Test 1**: Complete survey with interests: ["設計", "寫作"]
   - Check if blueprint mentions design/writing careers

2. **Test 2**: Complete survey with interests: ["技術", "數據分析"]
   - Check if blueprint mentions tech/data careers

3. **Test 3**: Complete survey with different values
   - Check if blueprint reflects your values

**If all three tests show the same content**, AI is likely using fallback.

### 4. Check API Response

The AI service logs the first 500 characters of the response. Look for:
- JSON structure with `vocationDirections`, `strengthsSummary`, `feasibilityAssessment`
- Chinese text (繁體中文)
- Specific job titles and career advice
- Not just repeating your input keywords

### 5. Network Issues

If you see:
- `❌ API Error (400/401/403)`: API key or authentication issue
- `❌ API Error (500)`: Server error
- `❌ API Error (timeout)`: Network timeout (30 seconds)

Check:
- API key is correct in `APIConfig.swift`
- Internet connection
- API service status

### 6. JSON Parsing Issues

If you see:
- `❌ JSON parsing failed, using fallback`
- But response status is 200

The AI returned content but it's not valid JSON. Check the logged response to see what format it returned.

---

## Current Implementation

**Location**: `LifeLab/LifeLab/Services/AIService.swift`

**Function**: `generateLifeBlueprint(profile:)`

**Logging**: Comprehensive logging added at every step:
- API request
- Response status
- JSON parsing
- Direction count
- Content length

**Fallback**: If AI fails, uses `generateLifeBlueprintFallback()` which creates generic content.

---

## How to Debug

1. **Open Xcode Console** (View → Debug Area → Activate Console)
2. **Run the app** and complete the survey
3. **Watch for log messages** when generating blueprint
4. **Check Profile View** to see if content is personalized or generic

If you see fallback being used, check:
- API key is valid
- Network connection
- API response format
- JSON structure matches expected format
