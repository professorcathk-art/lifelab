# AI Prompt Documentation

## 初版生命藍圖 (Life Blueprint) Generation Prompt

**Location**: `LifeLab/LifeLab/Services/AIService.swift` - `generateLifeBlueprint(profile:)` function

**Prompt Used**:
```
你是一位專業的職業規劃顧問。請根據以下用戶資料，生成一份深度、專業的職業發展建議（生命藍圖）。這不是簡單重複用戶的輸入，而是基於這些資訊提供具體、可行的職業方向建議。

請以JSON格式回應，格式如下：

{
  "vocationDirections": [
    {
      "title": "職業方向標題（具體職位或領域）",
      "description": "詳細的職業方向描述（150-200字），包括：1) 這個方向如何結合用戶的興趣、天賦和價值觀；2) 具體的工作內容和發展路徑；3) 為什麼這個方向適合用戶；4) 需要具備的技能和學習建議",
      "marketFeasibility": "市場可行性評估（100-150字），包括：1) 當前市場需求；2) 未來發展趨勢；3) 薪資範圍；4) 競爭程度；5) 進入門檻"
    }
  ],
  "strengthsSummary": "優勢分析總結（200-250字），深入分析用戶的優勢組合如何形成競爭力，這些優勢在哪些職業領域最有價值，以及如何進一步發展這些優勢",
  "feasibilityAssessment": "可行性評估（200-250字），基於用戶的現有條件，評估各個方向的可行性，包括：1) 短期可達成的目標；2) 需要補強的技能；3) 建議的學習路徑；4) 潛在挑戰和解決方案"
}

用戶資料：
- 興趣：{interests}
- 天賦關鍵詞：{strengths}
- 天賦回答：{strengthsAnswers}
- 核心價值觀：{topValues}

請生成3-5個具體、可行的職業方向建議。每個建議應該：
1. 不是簡單重複用戶的興趣和天賦，而是提供具體的職業選擇
2. 結合市場實際情況，給出實用的建議
3. 包含具體的行動步驟和學習建議
4. 考慮用戶的價值觀，確保職業方向與價值觀一致

使用繁體中文回應，只返回JSON，不要其他文字。
```

**API Endpoint**: `https://api.aimlapi.com/v1/chat/completions`
**Model**: `anthropic/claude-sonnet-4.5`
**API Key**: Stored in `LifeLab/LifeLab/Services/APIConfig.swift` (not committed to git)

**Error Handling**:
- 30-second timeout protection
- Fallback to structured generation if JSON parsing fails
- Comprehensive logging (🔵 for requests, ✅ for success, ❌ for errors)

**Verification**:
To verify AI is actually being called, check console logs for:
- 🔵 Making API request to: ...
- 🔵 Response status: 200
- ✅ Successfully received response.

If you see "JSON parsing failed, using fallback", the AI response was received but couldn't be parsed, so fallback content is used.
