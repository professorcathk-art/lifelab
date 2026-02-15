import Foundation

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    // Helper function to extract partial JSON when response is truncated
    private func extractPartialJSON(from jsonString: String) -> String? {
        // Try to find the last complete JSON structure
        // Look for the last complete "vocationDirections" array
        guard let directionsStart = jsonString.range(of: "\"vocationDirections\": [") else {
            return nil
        }
        
        let startIndex = directionsStart.upperBound
        guard startIndex < jsonString.endIndex else {
            return nil
        }
        
        var bracketCount = 1  // We're inside the array
        var lastValidIndex: String.Index?
        
        var currentIndex = startIndex
        while currentIndex < jsonString.endIndex {
            let char = jsonString[currentIndex]
            if char == "[" {
                bracketCount += 1
            } else if char == "]" {
                bracketCount -= 1
                if bracketCount == 0 {
                    // Check bounds before using index(after:)
                    if currentIndex < jsonString.endIndex {
                        let nextIndex = jsonString.index(after: currentIndex)
                        if nextIndex <= jsonString.endIndex {
                            lastValidIndex = nextIndex
                        } else {
                            lastValidIndex = jsonString.endIndex
                        }
                    } else {
                        lastValidIndex = jsonString.endIndex
                    }
                    break
                }
            }
            // Check bounds before incrementing
            let nextIndex = jsonString.index(after: currentIndex)
            if nextIndex >= jsonString.endIndex {
                break
            }
            currentIndex = nextIndex
        }
        
        // Try to construct a valid JSON object - with safe bounds checking
        if let jsonStart = jsonString.range(of: "{"),
           let validEnd = lastValidIndex,
           jsonStart.lowerBound < jsonString.endIndex,
           validEnd > jsonStart.lowerBound && validEnd <= jsonString.endIndex {
            let partialJson = String(jsonString[jsonStart.lowerBound..<validEnd])
            // Try to close the JSON properly - add missing closing braces
            var closedJson = partialJson
            // Count how many opening braces we have vs closing braces
            let openBraces = closedJson.filter { $0 == "{" }.count
            let closeBraces = closedJson.filter { $0 == "}" }.count
            let missingBraces = openBraces - closeBraces
            for _ in 0..<missingBraces {
                closedJson += "\n}"
            }
            return closedJson
        }
        return nil
    }
    
    private func makeAPIRequest(messages: [[String: Any]]) async throws -> String {
        guard let url = URL(string: APIConfig.aimlAPIURL) else {
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid API URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(APIConfig.aimlAPIKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "model": APIConfig.model,
            "messages": messages,
            "max_tokens": 3000,  // Reduced to save tokens while still getting complete responses
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔵 Making API request to: \(APIConfig.aimlAPIURL)")
        print("🔵 Model: \(APIConfig.model)")
        print("🔵 API Key (first 10 chars): \(String(APIConfig.aimlAPIKey.prefix(10)))...")
        print("🔵 Request body size: \(request.httpBody?.count ?? 0) bytes")
        
        // Configure URLSession with NO timeout - let it load until completion
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = TimeInterval.infinity  // No timeout - wait indefinitely
        config.timeoutIntervalForResource = TimeInterval.infinity  // No timeout - wait indefinitely
        config.waitsForConnectivity = true  // Wait for network connectivity
        config.requestCachePolicy = .reloadIgnoringLocalCacheData  // Don't use cache
        let session = URLSession(configuration: config)
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NSError(domain: "AIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("🔵 Response status: \(httpResponse.statusCode)")
        
        // Accept both 200 (OK) and 201 (Created) as success
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            print("❌ API Error (\(httpResponse.statusCode)): \(errorMessage.prefix(200))")
            throw NSError(domain: "AIService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API Error: \(errorMessage)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            print("❌ Failed to parse JSON")
            throw NSError(domain: "AIService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        guard let choices = json["choices"] as? [[String: Any]],
              let firstChoice = choices.first,
              let message = firstChoice["message"] as? [String: Any],
              let content = message["content"] as? String else {
            print("❌ Failed to extract content from response")
            print("Response structure: \(json.keys)")
            throw NSError(domain: "AIService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to extract content from response"])
        }
        
        // Check if response was truncated
        let finishReason = firstChoice["finish_reason"] as? String ?? ""
        if finishReason == "max_tokens" {
            print("⚠️ WARNING: Response was truncated due to max_tokens limit")
            print("⚠️ This means the JSON might be incomplete")
        }
        
        print("✅ Successfully received response")
        print("✅ Response content length: \(content.count) characters")
        print("✅ Finish reason: \(finishReason.isEmpty ? "normal" : finishReason)")
        print("✅ Response preview: \(content.prefix(200))...")
        
        // Verify response is not empty
        guard !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            print("❌ ERROR: Response content is empty!")
            throw NSError(domain: "AIService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Empty response from API"])
        }
        
        return content
    }
    
    func generateInitialSummary(interests: [String], strengths: [StrengthResponse], values: [ValueRanking]) async throws -> String {
        let interestsText = interests.joined(separator: "、")
        let strengthsText = strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let strengthsAnswers = strengths.compactMap { $0.userAnswer }.filter { !$0.isEmpty }.joined(separator: "\n")
        let topValues = values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        let prompt = """
        請根據以下用戶輸入，生成一份簡潔的個人特質總結（200-300字）：

        興趣關鍵詞：\(interestsText)
        
        天賦關鍵詞：\(strengthsText)
        
        用戶對天賦問題的回答：
        \(strengthsAnswers.isEmpty ? "無" : strengthsAnswers)
        
        核心價值觀（前3名）：\(topValues)
        
        請用繁體中文，以溫暖、專業的語氣，總結這些特質如何塑造這個人的獨特性，並指出可能的發展方向。格式要清晰易讀。
        """
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        return try await makeAPIRequest(messages: messages)
    }
    
    func generateVennOverlapSummary(interests: [String], strengths: [String], values: [String], interestStrengthOverlap: [String], interestValueOverlap: [String], strengthValueOverlap: [String], allOverlap: [String]) async throws -> String {
        let prompt = """
        請分析以下用戶的興趣、天賦和價值觀的交集，生成一份簡潔的總結（100-150字）：
        
        興趣：\(interests.joined(separator: "、"))
        天賦：\(strengths.joined(separator: "、"))
        價值觀：\(values.joined(separator: "、"))
        
        交集分析：
        - 興趣 x 天賦：\(interestStrengthOverlap.isEmpty ? "無明顯交集" : interestStrengthOverlap.joined(separator: "、"))
        - 興趣 x 價值觀：\(interestValueOverlap.isEmpty ? "無明顯交集" : interestValueOverlap.joined(separator: "、"))
        - 天賦 x 價值觀：\(strengthValueOverlap.isEmpty ? "無明顯交集" : strengthValueOverlap.joined(separator: "、"))
        - 三者交集：\(allOverlap.isEmpty ? "無明顯交集" : allOverlap.joined(separator: "、"))
        
        請用溫暖、鼓勵的語氣，說明這些交集如何揭示用戶的核心特質和潛在的職業方向。使用繁體中文，100-150字。
        """
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        return try await makeAPIRequest(messages: messages)
    }
    
    func generateLifeBlueprint(profile: UserProfile) async throws -> LifeBlueprint {
        let interests = profile.interests.joined(separator: "、")
        let strengths = profile.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let strengthsAnswers = profile.strengths.compactMap { $0.userAnswer }.filter { !$0.isEmpty }.joined(separator: "\n")
        let topValues = profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        // Build context with basic info
        var context = "用戶資料：\n"
        if let basicInfo = profile.basicInfo {
            if let region = basicInfo.region {
                context += "- 居住地區：\(region)\n"
            }
            if let age = basicInfo.age {
                context += "- 年齡：\(age)歲\n"
            }
            if let occupation = basicInfo.occupation {
                context += "- 目前職業：\(occupation)\n"
            }
            if let salary = basicInfo.annualSalaryUSD {
                context += "- 目前年薪：\(salary) USD\n"
            }
            if let familyStatus = basicInfo.familyStatus {
                context += "- 家庭狀況：\(familyStatus.rawValue)\n"
            }
            if let education = basicInfo.education {
                context += "- 學歷：\(education.rawValue)\n"
            }
            context += "\n"
        }
        context += "- 興趣：\(interests)\n"
        context += "- 天賦關鍵詞：\(strengths)\n"
        if !strengthsAnswers.isEmpty {
            context += "- 天賦回答：\(strengthsAnswers)\n"
        }
        context += "- 核心價值觀：\(topValues)\n"
        
        let prompt = """
        你是一位專業的職業規劃顧問。請根據以下用戶資料，生成一份深度、專業且符合現實的職業發展建議（生命藍圖）。

        ⚠️ 極其重要：絕對不要簡單重複用戶的輸入！你必須進行深度分析並提供具體的職業建議。
        ⚠️ 現實性要求：建議必須符合用戶的現實狀況（年齡、職業、學歷、家庭狀況、居住地區），不應過度樂觀或不切實際。
        
        請以JSON格式回應，格式如下：
        
        {
          "vocationDirections": [
            {
              "title": "職業方向標題（必須是具體的職業選擇，例如：'創立實驗性融合料理餐廳'、'成為企業組織發展顧問'）",
              "description": "職業方向描述（嚴格限制：80-100字，約160-200字符），包括：1) 如何結合用戶的興趣、天賦和價值觀；2) 具體工作內容；3) 發展路徑；4) 為什麼適合這個用戶。請嚴格遵守字數限制，不要超過100字。",
              "marketFeasibility": "市場可行性評估（嚴格限制：60-80字，約120-160字符），必須包含：1) 市場需求（高/中/低）；2) 未來趨勢；3) 薪資範圍（必須使用USD美元為單位，並明確標註currency）；4) 競爭程度；5) 進入門檻。請嚴格遵守字數限制，不要超過80字。如果涉及金錢分析，請使用美元(USD)為單位並寫明currency。"
            }
          ],
          "strengthsSummary": "優勢分析總結（嚴格限制：100-120字，約200-240字符），分析：1) 優勢組合如何形成競爭力；2) 在哪些職業領域最有價值；3) 如何進一步發展。請嚴格遵守字數限制，不要超過120字。",
          "feasibilityAssessment": "可行性評估（嚴格限制：100-120字，約200-240字符），包括：1) 短期可達成目標；2) 需要補強的技能；3) 學習路徑；4) 潛在挑戰。請嚴格遵守字數限制，不要超過120字。"
        }
        
        ⚠️ 重要：請嚴格遵守上述字數限制。每個字段都不要超過指定的最大字數，這對於確保完整響應至關重要。
        
        \(context)
        
        ❌ 絕對禁止的行為：
        1. 不要簡單地把用戶的興趣和天賦關鍵詞組合成句子（例如："結合烹飪和創新的工作"）
        2. 不要使用"市場需求穩定"這樣的泛泛描述，必須提供具體的市場分析
        3. 不要重複用戶已經說過的內容，必須提供新的洞察和建議
        4. 不要使用模板化的回答，必須針對這個用戶的具體情況進行分析
        5. 不要提供過度樂觀或不切實際的建議，必須考慮用戶的現實狀況（年齡、職業、學歷、家庭狀況、居住地區）
        
        ✅ 必須做到：
        1. 每個職業方向必須是具體、可執行的職業選擇，且符合用戶的現實狀況：
           - 考慮用戶的年齡、目前職業、學歷背景
           - 考慮用戶的家庭狀況（是否有家庭責任）
           - 考慮用戶的居住地區（提供當地真實市場數據和例子）
           - 例如：如果用戶在香港，提供香港本地市場的真實數據和例子（如：香港餐飲業平均薪資、市場規模等）
        
        2. 每個方向的marketFeasibility必須包含具體信息，且使用USD美元為單位：
           - "當前市場需求：高（餐飲創新領域年增長率15%，高端餐廳市場規模達XX億USD）"
           - "未來趨勢：持續增長（消費者對體驗式餐飲需求上升）"
           - "薪資範圍：主廚年薪80,000-150,000 USD（currency: USD），餐廳經營者年收入200,000-500,000 USD（currency: USD）"
           - "競爭程度：中等（需要獨特定位和技術優勢）"
           - "進入門檻：需要餐飲經驗和創新能力，建議先從副主廚開始"
           - 如果用戶提供了居住地區，請提供該地區的真實市場數據和例子
        
        3. 必須明確結合用戶的核心價值觀（\(topValues)），確保職業方向與價值觀高度一致
        
        4. 請生成3個具體、可行且符合現實的職業方向建議，優先考慮與用戶價值觀最匹配且符合用戶現實狀況的方向。只生成3個，不要超過。
        
        使用繁體中文回應，只返回JSON，不要其他文字。確保每個方向都是獨特且具體的，不要重複。所有涉及金錢的分析必須使用USD美元為單位並明確標註currency。
        """
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        let response = try await makeAPIRequest(messages: messages)
        
        // Try to extract JSON from response (might have markdown code blocks)
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present - with safe bounds checking
        if jsonString.hasPrefix("```json") && jsonString.count >= 7 {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to find JSON object boundaries if response is malformed - with safe bounds checking
        if let jsonStart = jsonString.range(of: "{"), jsonStart.lowerBound < jsonString.endIndex {
            jsonString = String(jsonString[jsonStart.lowerBound..<jsonString.endIndex])
        }
        if let jsonEnd = jsonString.range(of: "}", options: .backwards), jsonEnd.upperBound <= jsonString.endIndex {
            jsonString = String(jsonString[jsonString.startIndex..<jsonEnd.upperBound])
        }
        
        // Parse JSON response with better error handling
        print("🔵 Attempting to parse JSON from response...")
        print("🔵 JSON string length: \(jsonString.count) characters")
        print("🔵 JSON string preview: \(jsonString.prefix(300))...")
        print("🔵 JSON string end: ...\(jsonString.suffix(200))")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌❌❌ CRITICAL: Failed to convert JSON string to Data")
            print("❌❌❌ This means API responded but response format is wrong")
            print("❌❌❌ JSON string: \(jsonString.prefix(500))")
            print("❌❌❌ Full response: \(response)")
            throw NSError(domain: "AIService", code: -6, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to Data. Response: \(response.prefix(200))"])
        }
        
        // Try to parse JSON with better error handling
        var json: [String: Any]
        do {
            guard let parsedJson = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                throw NSError(domain: "AIService", code: -7, userInfo: [NSLocalizedDescriptionKey: "JSON is not a dictionary"])
            }
            json = parsedJson
        } catch let parseError as NSError {
            print("❌❌❌ CRITICAL: JSON parsing failed!")
            print("❌❌❌ Parse error: \(parseError.localizedDescription)")
            if let errorIndex = parseError.userInfo["NSJSONSerializationErrorIndex"] as? Int {
                print("❌❌❌ Error at index: \(errorIndex)")
                let contextStart = max(0, errorIndex - 100)
                let contextEnd = min(jsonString.count, errorIndex + 100)
                // Safe bounds checking before creating string indices
                if contextStart < jsonString.count && contextEnd <= jsonString.count && contextStart < contextEnd {
                    let startIdx = jsonString.index(jsonString.startIndex, offsetBy: contextStart)
                    let endIdx = jsonString.index(jsonString.startIndex, offsetBy: contextEnd)
                    if endIdx <= jsonString.endIndex && startIdx < endIdx {
                        print("❌❌❌ Context around error: ...\(String(jsonString[startIdx..<endIdx]))...")
                    }
                }
            }
            print("❌❌❌ Full response length: \(response.count) characters")
            print("❌❌❌ JSON string length: \(jsonString.count) characters")
            print("❌❌❌ JSON string (first 1000 chars): \(jsonString.prefix(1000))")
            print("❌❌❌ JSON string (last 500 chars): \(jsonString.suffix(500))")
            
            // Check if response was truncated (common cause of "Unterminated string")
            if parseError.localizedDescription.contains("Unterminated string") {
                print("❌❌❌ ERROR: JSON string appears to be truncated!")
                print("❌❌❌ Attempting to extract partial JSON...")
                
                // Try to extract what we can from partial JSON
                if let partialJsonString = extractPartialJSON(from: jsonString) {
                    print("✅✅✅ Successfully extracted partial JSON!")
                    if let partialData = partialJsonString.data(using: .utf8),
                       let partialJson = try? JSONSerialization.jsonObject(with: partialData) as? [String: Any] {
                        json = partialJson
                        print("✅✅✅ Using partial JSON with \(partialJson.keys.count) keys")
                        // Continue with partial JSON instead of throwing
                    } else {
                        print("❌❌❌ Failed to parse extracted partial JSON")
                        throw NSError(domain: "AIService", code: -7, userInfo: [NSLocalizedDescriptionKey: "JSON parsing failed: \(parseError.localizedDescription). Response preview: \(response.prefix(500))"])
                    }
                } else {
                    print("❌❌❌ Could not extract partial JSON")
                    throw NSError(domain: "AIService", code: -7, userInfo: [NSLocalizedDescriptionKey: "JSON parsing failed: \(parseError.localizedDescription). Response preview: \(response.prefix(500))"])
                }
            } else {
                throw NSError(domain: "AIService", code: -7, userInfo: [NSLocalizedDescriptionKey: "JSON parsing failed: \(parseError.localizedDescription). Response preview: \(response.prefix(500))"])
            }
        }
        
        print("✅ Successfully parsed JSON from AI response")
        print("✅ JSON keys: \(json.keys.joined(separator: ", "))")
        
        var directions: [VocationDirection] = []
        if let directionsArray = json["vocationDirections"] as? [[String: Any]] {
            print("✅✅✅ Found \(directionsArray.count) vocation directions from AI API!")
            for (idx, dir) in directionsArray.enumerated() {
                let title = dir["title"] as? String ?? ""
                let description = dir["description"] as? String ?? ""
                let feasibility = dir["marketFeasibility"] as? String ?? ""
                print("  🔵 AI Direction \(idx + 1): \(title)")
                print("     Description: \(description.prefix(100))...")
                print("     Feasibility: \(feasibility.prefix(50))...")
                
                // Validate that this is NOT just repeating user input
                let isRepeating = title.contains(interests) || title.contains(strengths) || 
                                 description.contains(interests) || description.contains(strengths)
                if isRepeating {
                    print("  ⚠️ WARNING: Direction \(idx + 1) appears to be repeating user input!")
                }
                
                directions.append(VocationDirection(title: title, description: description, marketFeasibility: feasibility, priority: idx + 1, isFavorite: false))
            }
        } else {
            print("❌❌❌ ERROR: No vocationDirections found in JSON!")
            print("❌❌❌ JSON keys: \(json.keys.joined(separator: ", "))")
            throw NSError(domain: "AIService", code: -10, userInfo: [NSLocalizedDescriptionKey: "AI response missing vocationDirections"])
        }
        
        let strengthsSummary = json["strengthsSummary"] as? String ?? ""
        let feasibilityAssessment = json["feasibilityAssessment"] as? String ?? ""
        
        print("✅ Strengths summary length: \(strengthsSummary.count) characters")
        print("✅ Feasibility assessment length: \(feasibilityAssessment.count) characters")
        
        // CRITICAL: If directions is empty, throw error instead of using fallback silently
        if directions.isEmpty {
            print("❌❌❌ CRITICAL ERROR: Directions array is empty after parsing!")
            print("❌❌❌ This means AI API was called but returned empty directions")
            print("❌❌❌ JSON structure: \(json)")
            print("❌❌❌ Full response was: \(response.prefix(1000))")
            throw NSError(domain: "AIService", code: -11, userInfo: [NSLocalizedDescriptionKey: "AI returned empty vocation directions"])
        }
        
        if strengthsSummary.isEmpty {
            print("⚠️ Strengths summary is empty, using fallback text")
        }
        
        if feasibilityAssessment.isEmpty {
            print("⚠️ Feasibility assessment is empty, using fallback text")
        }
        
        print("✅✅✅ SUCCESS: Returning AI-generated blueprint with \(directions.count) directions")
        print("✅✅✅ This is REAL AI analysis, NOT fallback!")
        
        // Validate that directions are NOT just repeating user input or using fallback patterns
        for (idx, dir) in directions.enumerated() {
            let titleLower = dir.title.lowercased()
            let descLower = dir.description.lowercased()
            
            // Check for fallback patterns
            if titleLower.contains("基於您的興趣和天賦的方向") || 
               titleLower.contains("基於您的價值觀的方向") ||
               (descLower.contains("結合") && descLower.contains("的興趣與") && descLower.contains("的天賦")) {
                print("❌❌❌ WARNING: Direction \(idx + 1) looks like fallback content!")
                print("❌❌❌ Title: \(dir.title)")
                print("❌❌❌ This should NOT happen if AI is working correctly!")
            }
            
            // Check for generic "市场需求稳定"
            if dir.marketFeasibility.contains("市場需求穩定") && dir.marketFeasibility.count < 30 {
                print("❌❌❌ WARNING: Direction \(idx + 1) has generic fallback feasibility text!")
                print("❌❌❌ Feasibility: \(dir.marketFeasibility)")
            }
            
            print("  🔵 AI Direction \(idx + 1): \(dir.title)")
            print("     Description: \(dir.description.prefix(80))...")
            print("     Feasibility: \(dir.marketFeasibility.prefix(50))...")
        }
        
        if strengthsSummary.isEmpty {
            print("⚠️ WARNING: Strengths summary is empty! Using fallback text.")
        } else {
            print("✅ AI-generated strengths summary: \(strengthsSummary.prefix(100))...")
        }
        
        if feasibilityAssessment.isEmpty {
            print("⚠️ WARNING: Feasibility assessment is empty! Using fallback text.")
        } else {
            print("✅ AI-generated feasibility assessment: \(feasibilityAssessment.prefix(100))...")
        }
        
        return LifeBlueprint(
            vocationDirections: directions,
            strengthsSummary: strengthsSummary.isEmpty ? "您的獨特優勢在於結合了\(strengths)等多項能力。" : strengthsSummary,
            feasibilityAssessment: feasibilityAssessment.isEmpty ? "基於您目前的資源和條件，這些方向都具有良好的可行性。" : feasibilityAssessment
        )
    }
    
    func generateLifeBlueprint(interests: [String], strengths: [StrengthResponse], values: [ValueRanking], flowDiary: [FlowDiaryEntry] = [], valuesQuestions: ValuesQuestions? = nil, resourceInventory: ResourceInventory? = nil, acquiredStrengths: AcquiredStrengths? = nil, feasibilityAssessment: FeasibilityAssessment? = nil) async throws -> LifeBlueprint {
        let interestsText = interests.joined(separator: "、")
        let strengthsText = strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let strengthsAnswers = strengths.compactMap { $0.userAnswer }.filter { !$0.isEmpty }.joined(separator: "\n")
        let topValues = values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        var context = "用戶資料：\n"
        context += "- 興趣：\(interestsText)\n"
        context += "- 天賦關鍵詞：\(strengthsText)\n"
        if !strengthsAnswers.isEmpty {
            context += "- 天賦回答：\(strengthsAnswers)\n"
        }
        context += "- 核心價值觀：\(topValues)\n"
        
        // Add deepening exploration data if available
        if !flowDiary.isEmpty {
            let flowActivities = flowDiary.map { $0.activity }.filter { !$0.isEmpty }.joined(separator: "、")
            context += "- 心流事件：\(flowActivities)\n"
        }
        
        if let valuesQ = valuesQuestions {
            var valuesContext = ""
            if let admired = valuesQ.admiredPeople { valuesContext += "欣賞的人：\(admired)\n" }
            if let characters = valuesQ.favoriteCharacters { valuesContext += "喜歡的角色：\(characters)\n" }
            if !valuesContext.isEmpty {
                context += "\n價值觀深度探索：\n\(valuesContext)"
            }
        }
        
        if let resources = resourceInventory {
            var resourcesContext = ""
            if let time = resources.time { resourcesContext += "時間資源：\(time)\n" }
            if let money = resources.money { resourcesContext += "金錢資源：\(money)\n" }
            if let items = resources.items { resourcesContext += "物品資源：\(items)\n" }
            if let network = resources.network { resourcesContext += "人脈資源：\(network)\n" }
            if !resourcesContext.isEmpty {
                context += "\n資源盤點：\n\(resourcesContext)"
            }
        }
        
        if let acquired = acquiredStrengths {
            var strengthsContext = ""
            if let exp = acquired.experience { strengthsContext += "經驗：\(exp)\n" }
            if let knowledge = acquired.knowledge { strengthsContext += "知識：\(knowledge)\n" }
            if let skills = acquired.skills { strengthsContext += "技能：\(skills)\n" }
            if let achievements = acquired.achievements { strengthsContext += "實績：\(achievements)\n" }
            if !strengthsContext.isEmpty {
                context += "\n後天強項：\n\(strengthsContext)"
            }
        }
        
        if let feasibility = feasibilityAssessment {
            var feasibilityContext = ""
            if let p1 = feasibility.path1 { feasibilityContext += "路徑1：\(p1)\n" }
            if let p2 = feasibility.path2 { feasibilityContext += "路徑2：\(p2)\n" }
            if !feasibilityContext.isEmpty {
                context += "\n可行性評估：\n\(feasibilityContext)"
            }
        }
        
        let prompt = """
        請根據以下用戶資料，生成一份個人化的生命藍圖。請以JSON格式回應，格式如下：
        
        {
          "vocationDirections": [
            {
              "title": "方向標題",
              "description": "方向描述（100-150字）",
              "marketFeasibility": "市場可行性評估"
            }
          ],
          "strengthsSummary": "優勢總結（嚴格限制：100-120字，約200-240字符），請嚴格遵守字數限制",
          "feasibilityAssessment": "可行性評估（嚴格限制：100-120字，約200-240字符），請嚴格遵守字數限制"
        }
        
        \(context)
        
        請生成3-5個天職方向建議，每個方向要具體、可行，並符合用戶的興趣、天賦和價值觀。如果提供了深化探索的資料，請整合這些資訊使建議更加精準。使用繁體中文回應，只返回JSON，不要其他文字。
        """
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        print("🔵🔵🔵 CALLING AI API FOR LIFE BLUEPRINT (with deepening data)")
        let response = try await makeAPIRequest(messages: messages)
        
        // Try to extract JSON from response (might have markdown code blocks)
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present - with safe bounds checking
        if jsonString.hasPrefix("```json") && jsonString.count >= 7 {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Try to find JSON object boundaries if response is malformed - with safe bounds checking
        if let jsonStart = jsonString.range(of: "{"), jsonStart.lowerBound < jsonString.endIndex {
            jsonString = String(jsonString[jsonStart.lowerBound..<jsonString.endIndex])
        }
        if let jsonEnd = jsonString.range(of: "}", options: .backwards), jsonEnd.upperBound <= jsonString.endIndex {
            jsonString = String(jsonString[jsonString.startIndex..<jsonEnd.upperBound])
        }
        
        // Parse JSON response with better error handling
        print("🔵 Attempting to parse JSON from response...")
        print("🔵 JSON string length: \(jsonString.count) characters")
        
        guard let jsonData = jsonString.data(using: .utf8) else {
            print("❌❌❌ CRITICAL: Failed to convert JSON string to Data")
            throw NSError(domain: "AIService", code: -8, userInfo: [NSLocalizedDescriptionKey: "Failed to convert JSON string to Data"])
        }
        
        var json: [String: Any]
        do {
            guard let parsedJson = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
                throw NSError(domain: "AIService", code: -8, userInfo: [NSLocalizedDescriptionKey: "JSON is not a dictionary"])
            }
            json = parsedJson
        } catch let parseError as NSError {
            print("❌❌❌ CRITICAL: JSON parsing failed!")
            print("❌❌❌ Parse error: \(parseError.localizedDescription)")
            if let errorIndex = parseError.userInfo["NSJSONSerializationErrorIndex"] as? Int {
                print("❌❌❌ Error at index: \(errorIndex)")
                let contextStart = max(0, errorIndex - 100)
                let contextEnd = min(jsonString.count, errorIndex + 100)
                // Safe bounds checking before creating string indices
                if contextStart < jsonString.count && contextEnd <= jsonString.count && contextStart < contextEnd {
                    let startIdx = jsonString.index(jsonString.startIndex, offsetBy: contextStart)
                    let endIdx = jsonString.index(jsonString.startIndex, offsetBy: contextEnd)
                    if endIdx <= jsonString.endIndex && startIdx < endIdx {
                        print("❌❌❌ Context around error: ...\(String(jsonString[startIdx..<endIdx]))...")
                    }
                }
            } else {
                print("❌❌❌ Error at index: unknown")
            }
            print("❌❌❌ JSON string (first 1000): \(jsonString.prefix(1000))")
            print("❌❌❌ JSON string (last 500): \(jsonString.suffix(500))")
            throw NSError(domain: "AIService", code: -8, userInfo: [NSLocalizedDescriptionKey: "JSON parsing failed: \(parseError.localizedDescription)"])
        }
        
        // Extract vocation directions
        var directions: [VocationDirection] = []
        if let directionsArray = json["vocationDirections"] as? [[String: Any]] {
            print("✅✅✅ Found \(directionsArray.count) vocation directions from AI!")
            for (idx, dir) in directionsArray.enumerated() {
                let title = dir["title"] as? String ?? ""
                let description = dir["description"] as? String ?? ""
                let feasibility = dir["marketFeasibility"] as? String ?? ""
                print("  🔵 AI Direction \(idx + 1): \(title)")
                print("     Description: \(description.prefix(80))...")
                print("     Feasibility: \(feasibility.prefix(50))...")
                directions.append(VocationDirection(title: title, description: description, marketFeasibility: feasibility, priority: idx + 1, isFavorite: false))
            }
        } else {
            print("❌❌❌ ERROR: No vocationDirections in JSON!")
            throw NSError(domain: "AIService", code: -9, userInfo: [NSLocalizedDescriptionKey: "AI response missing vocationDirections"])
        }
        
        // CRITICAL: If directions is empty, throw error
        if directions.isEmpty {
            print("❌❌❌ CRITICAL: Directions array is empty!")
            throw NSError(domain: "AIService", code: -12, userInfo: [NSLocalizedDescriptionKey: "AI returned empty directions"])
        }
        
        let strengthsSummary = json["strengthsSummary"] as? String ?? ""
        let feasibilityAssessment = json["feasibilityAssessment"] as? String ?? ""
        
        print("✅✅✅ SUCCESS: Returning AI-generated blueprint with \(directions.count) directions")
        
        return LifeBlueprint(
            vocationDirections: directions,
            strengthsSummary: strengthsSummary.isEmpty ? "根據您的興趣和天賦，您展現出獨特的優勢組合。" : strengthsSummary,
            feasibilityAssessment: feasibilityAssessment.isEmpty ? "建議您從最感興趣的方向開始探索，逐步驗證可行性。" : feasibilityAssessment
        )
    }
    
    func generateLifeBlueprintFallback(interests: [String], strengths: [StrengthResponse], values: [ValueRanking]) async throws -> LifeBlueprint {
        let interestsText = interests.joined(separator: "、")
        let strengthsText = strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let topValues = values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        let directions = [
            VocationDirection(
                title: "基於您的興趣和天賦的方向一",
                description: "結合\(interestsText)的興趣與\(strengthsText)的天賦，這個方向能夠讓您發揮所長。",
                marketFeasibility: "市場需求穩定，發展前景良好",
                priority: 1,
                isFavorite: false
            ),
            VocationDirection(
                title: "基於您的價值觀的方向二",
                description: "這個方向能夠體現您的核心價值觀：\(topValues)，讓您在工作中找到意義。",
                marketFeasibility: "市場需求增長中，需要持續學習",
                priority: 2,
                isFavorite: false
            )
        ]
        
        return LifeBlueprint(
            vocationDirections: directions,
            strengthsSummary: "您的獨特優勢在於結合了\(strengthsText)等多項能力，這讓您在相關領域具有競爭優勢。",
            feasibilityAssessment: "基於您目前的資源和條件，這些方向都具有良好的可行性。建議從短期目標開始，逐步建立相關經驗和技能。"
        )
    }
    
    func generateLifeBlueprintFallback(profile: UserProfile) async throws -> LifeBlueprint {
        return try await generateLifeBlueprintFallback(
            interests: profile.interests,
            strengths: profile.strengths,
            values: profile.values
        )
    }
    
    func generateActionPlan(profile: UserProfile, favoriteDirection: VocationDirection? = nil) async throws -> ActionPlan {
        // Build context from user profile
        let interests = profile.interests.joined(separator: "、")
        let strengths = profile.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let topValues = profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        var context = "用戶資料：\n"
        context += "- 興趣：\(interests)\n"
        context += "- 天賦：\(strengths)\n"
        context += "- 價值觀：\(topValues)\n"
        
        if let blueprint = profile.lifeBlueprint {
            context += "\n生命藍圖方向：\n"
            // If favorite direction is provided, prioritize it
            if let favorite = favoriteDirection {
                context += "【當前行動方向（最愛）】\n"
                context += "- \(favorite.title): \(favorite.description)\n"
                context += "市場可行性：\(favorite.marketFeasibility)\n"
                context += "\n其他方向：\n"
                for direction in blueprint.vocationDirections.filter({ $0.id != favorite.id }) {
                    context += "- \(direction.title): \(direction.description)\n"
                }
            } else {
                for direction in blueprint.vocationDirections {
                    context += "- \(direction.title): \(direction.description)\n"
                }
            }
        }
        
        if let flowDiary = profile.flowDiaryEntries.first(where: { !$0.activity.isEmpty }) {
            context += "\n心流事件：\(flowDiary.activity)\n"
        }
        
        if let resources = profile.resourceInventory {
            context += "\n資源盤點：\n"
            if let time = resources.time { context += "- 時間：\(time)\n" }
            if let money = resources.money { context += "- 金錢：\(money)\n" }
        }
        
        let prompt = """
        請根據以下用戶資料，生成一份詳細的行動計劃。請以JSON格式回應，格式如下：
        
        {
          "shortTerm": [
            {
              "title": "任務標題",
              "description": "任務描述",
              "dueDate": "YYYY-MM-DD"
            }
          ],
          "midTerm": [
            {
              "title": "任務標題",
              "description": "任務描述",
              "dueDate": "YYYY-MM-DD"
            }
          ],
          "longTerm": [
            {
              "title": "任務標題",
              "description": "任務描述",
              "dueDate": "YYYY-MM-DD"
            }
          ],
          "milestones": [
            {
              "title": "里程碑標題",
              "description": "里程碑描述",
              "targetDate": "YYYY-MM-DD",
              "successIndicators": ["指標1", "指標2"]
            }
          ]
        }
        
        \(context)
        
        請生成：
        - 短期目標（1-3個月）：2-3個具體可執行的任務
        - 中期目標（3-6個月）：2-3個任務
        - 長期目標（6-12個月）：1-2個任務
        - 關鍵里程碑：2-3個里程碑，每個包含成功指標
        
        所有日期請使用未來日期（從今天開始計算）。使用繁體中文，只返回JSON，不要其他文字。
        """
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        let response = try await makeAPIRequest(messages: messages)
        
        // Try to extract JSON from response (might have markdown code blocks)
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present - with safe bounds checking
        if jsonString.hasPrefix("```json") && jsonString.count >= 7 {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse JSON response
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("Action plan JSON parsing failed, using fallback. Response: \(response.prefix(200))")
            return try await generateActionPlanFallback()
        }
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        var shortTerm: [ActionItem] = []
        if let shortTermArray = json["shortTerm"] as? [[String: Any]] {
            for item in shortTermArray {
                let title = item["title"] as? String ?? ""
                let description = item["description"] as? String ?? ""
                var dueDate: Date? = nil
                if let dateString = item["dueDate"] as? String {
                    dueDate = dateFormatter.date(from: dateString)
                }
                shortTerm.append(ActionItem(title: title, description: description, dueDate: dueDate))
            }
        }
        
        var midTerm: [ActionItem] = []
        if let midTermArray = json["midTerm"] as? [[String: Any]] {
            for item in midTermArray {
                let title = item["title"] as? String ?? ""
                let description = item["description"] as? String ?? ""
                var dueDate: Date? = nil
                if let dateString = item["dueDate"] as? String {
                    dueDate = dateFormatter.date(from: dateString)
                }
                midTerm.append(ActionItem(title: title, description: description, dueDate: dueDate))
            }
        }
        
        var longTerm: [ActionItem] = []
        if let longTermArray = json["longTerm"] as? [[String: Any]] {
            for item in longTermArray {
                let title = item["title"] as? String ?? ""
                let description = item["description"] as? String ?? ""
                var dueDate: Date? = nil
                if let dateString = item["dueDate"] as? String {
                    dueDate = dateFormatter.date(from: dateString)
                }
                longTerm.append(ActionItem(title: title, description: description, dueDate: dueDate))
            }
        }
        
        var milestones: [Milestone] = []
        if let milestonesArray = json["milestones"] as? [[String: Any]] {
            for milestone in milestonesArray {
                let title = milestone["title"] as? String ?? ""
                let description = milestone["description"] as? String ?? ""
                var targetDate: Date? = nil
                if let dateString = milestone["targetDate"] as? String {
                    targetDate = dateFormatter.date(from: dateString)
                }
                let indicators = milestone["successIndicators"] as? [String] ?? []
                milestones.append(Milestone(title: title, description: description, targetDate: targetDate, successIndicators: indicators))
            }
        }
        
        // Use fallback if no valid data
        if shortTerm.isEmpty && midTerm.isEmpty && longTerm.isEmpty {
            return try await generateActionPlanFallback()
        }
        
        return ActionPlan(shortTerm: shortTerm.isEmpty ? try await generateActionPlanFallback().shortTerm : shortTerm,
                         midTerm: midTerm.isEmpty ? try await generateActionPlanFallback().midTerm : midTerm,
                         longTerm: longTerm.isEmpty ? try await generateActionPlanFallback().longTerm : longTerm,
                         milestones: milestones.isEmpty ? try await generateActionPlanFallback().milestones : milestones,
                         todayTasks: [],
                         todayTasksLastGenerated: nil)
    }
    
    private func generateActionPlanFallback() async throws -> ActionPlan {
        let shortTerm = [
            ActionItem(title: "明確目標", description: "確定1-2個最感興趣的方向，進行深入研究", dueDate: Calendar.current.date(byAdding: .month, value: 1, to: Date())),
            ActionItem(title: "建立基礎", description: "開始學習相關基礎知識和技能", dueDate: Calendar.current.date(byAdding: .month, value: 2, to: Date()))
        ]
        
        let midTerm = [
            ActionItem(title: "技能強化", description: "通過實踐項目或課程深化專業技能", dueDate: Calendar.current.date(byAdding: .month, value: 4, to: Date())),
            ActionItem(title: "建立網絡", description: "參與相關社群，建立專業人脈", dueDate: Calendar.current.date(byAdding: .month, value: 5, to: Date()))
        ]
        
        let longTerm = [
            ActionItem(title: "職業轉換", description: "完成職業轉換或開始獨立實踐", dueDate: Calendar.current.date(byAdding: .month, value: 9, to: Date()))
        ]
        
        let milestones = [
            Milestone(title: "完成基礎學習", description: "掌握核心知識和技能", targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()), successIndicators: ["完成相關課程", "完成實踐項目"]),
            Milestone(title: "建立專業網絡", description: "建立穩定的專業人脈關係", targetDate: Calendar.current.date(byAdding: .month, value: 6, to: Date()), successIndicators: ["參與3個以上相關活動", "建立10個以上專業聯繫"])
        ]
        
        return ActionPlan(shortTerm: shortTerm, midTerm: midTerm, longTerm: longTerm, milestones: milestones, todayTasks: [], todayTasksLastGenerated: nil)
    }
    
    func generateTodayTasks(profile: UserProfile) async throws -> [ActionItem] {
        guard let actionPlan = profile.actionPlan else {
            throw NSError(domain: "AIService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No action plan found"])
        }
        
        // Build context from short-term and mid-term goals
        var context = "用戶的短期目標（1-3個月）：\n"
        for (index, task) in actionPlan.shortTerm.prefix(3).enumerated() {
            context += "\(index + 1). \(task.title): \(task.description)\n"
        }
        
        context += "\n用戶的中期目標（3-6個月）：\n"
        for (index, task) in actionPlan.midTerm.prefix(2).enumerated() {
            context += "\(index + 1). \(task.title): \(task.description)\n"
        }
        
        let today = Date()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let todayString = dateFormatter.string(from: today)
        
        let prompt = """
        請根據用戶的短期和中期目標，為今天（\(todayString)）生成3個具體可執行的今日任務。
        
        要求：
        1. 任務必須是今天可以完成的具體行動
        2. 任務應該與短期和中期目標相關，幫助推進這些目標
        3. 任務要具體、可執行，不要過於抽象
        4. 每個任務應該有明確的標題和簡短描述
        
        請以JSON格式回應，格式如下：
        
        {
          "todayTasks": [
            {
              "title": "任務標題（具體可執行）",
              "description": "任務描述（說明如何執行）"
            },
            {
              "title": "任務標題",
              "description": "任務描述"
            },
            {
              "title": "任務標題",
              "description": "任務描述"
            }
          ]
        }
        
        \(context)
        
        使用繁體中文，只返回JSON，不要其他文字。
        """
        
        let messages: [[String: Any]] = [
            [
                "role": "user",
                "content": prompt
            ]
        ]
        
        let response = try await makeAPIRequest(messages: messages)
        
        // Parse JSON response
        var jsonString = response.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Remove markdown code blocks if present
        if jsonString.hasPrefix("```json") && jsonString.count >= 7 {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") && jsonString.count >= 3 {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let todayTasksArray = json["todayTasks"] as? [[String: Any]] else {
            print("Today tasks JSON parsing failed, using fallback")
            return generateTodayTasksFallback(actionPlan: actionPlan)
        }
        
        var todayTasks: [ActionItem] = []
        for item in todayTasksArray {
            let title = item["title"] as? String ?? ""
            let description = item["description"] as? String ?? ""
            todayTasks.append(ActionItem(title: title, description: description, dueDate: today))
        }
        
        // Ensure we have exactly 3 tasks
        if todayTasks.count < 3 {
            let fallback = generateTodayTasksFallback(actionPlan: actionPlan)
            todayTasks.append(contentsOf: fallback.prefix(3 - todayTasks.count))
        }
        
        return Array(todayTasks.prefix(3))
    }
    
    private func generateTodayTasksFallback(actionPlan: ActionPlan) -> [ActionItem] {
        let today = Date()
        var tasks: [ActionItem] = []
        
        // Generate 3 tasks based on short-term goals
        if let firstShortTerm = actionPlan.shortTerm.first {
            tasks.append(ActionItem(
                title: "開始執行：\(firstShortTerm.title)",
                description: "今天開始執行這個短期目標的第一步",
                dueDate: today
            ))
        }
        
        if actionPlan.shortTerm.count > 1 {
            let secondTask = actionPlan.shortTerm[1]
            tasks.append(ActionItem(
                title: "規劃：\(secondTask.title)",
                description: "為這個目標制定具體的行動計劃",
                dueDate: today
            ))
        }
        
        if let firstMidTerm = actionPlan.midTerm.first {
            tasks.append(ActionItem(
                title: "研究：\(firstMidTerm.title)",
                description: "了解實現這個中期目標所需的資源和步驟",
                dueDate: today
            ))
        }
        
        // Fill up to 3 tasks if needed
        while tasks.count < 3 {
            tasks.append(ActionItem(
                title: "推進目標進度",
                description: "繼續推進您的職業發展目標",
                dueDate: today
            ))
        }
        
        return Array(tasks.prefix(3))
    }
}
