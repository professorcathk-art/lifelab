import Foundation

class AIService {
    static let shared = AIService()
    
    private init() {}
    
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
            "max_tokens": 2000,
            "temperature": 0.7
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
        
        print("🔵 Making API request to: \(APIConfig.aimlAPIURL)")
        print("🔵 Model: \(APIConfig.model)")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            print("❌ Invalid response type")
            throw NSError(domain: "AIService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        print("🔵 Response status: \(httpResponse.statusCode)")
        
        guard httpResponse.statusCode == 200 else {
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
        
        print("✅ Successfully received response: \(content.prefix(100))...")
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
    
    func generateLifeBlueprint(profile: UserProfile) async throws -> LifeBlueprint {
        let interests = profile.interests.joined(separator: "、")
        let strengths = profile.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let strengthsAnswers = profile.strengths.compactMap { $0.userAnswer }.filter { !$0.isEmpty }.joined(separator: "\n")
        let topValues = profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
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
          "strengthsSummary": "優勢總結（150-200字）",
          "feasibilityAssessment": "可行性評估（150-200字）"
        }
        
        用戶資料：
        - 興趣：\(interests)
        - 天賦關鍵詞：\(strengths)
        - 天賦回答：\(strengthsAnswers.isEmpty ? "無" : strengthsAnswers)
        - 核心價值觀：\(topValues)
        
        請生成3-5個天職方向建議，每個方向要具體、可行，並符合用戶的興趣、天賦和價值觀。使用繁體中文回應，只返回JSON，不要其他文字。
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
        
        // Remove markdown code blocks if present
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") {
            jsonString = String(jsonString.dropLast(3))
        }
        jsonString = jsonString.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Parse JSON response
        guard let jsonData = jsonString.data(using: .utf8),
              let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            // Fallback to structured generation if JSON parsing fails
            print("JSON parsing failed, using fallback. Response: \(response.prefix(200))")
            return try await generateLifeBlueprintFallback(profile: profile)
        }
        
        var directions: [VocationDirection] = []
        if let directionsArray = json["vocationDirections"] as? [[String: Any]] {
            for dir in directionsArray {
                let title = dir["title"] as? String ?? ""
                let description = dir["description"] as? String ?? ""
                let feasibility = dir["marketFeasibility"] as? String ?? ""
                directions.append(VocationDirection(title: title, description: description, marketFeasibility: feasibility))
            }
        }
        
        let strengthsSummary = json["strengthsSummary"] as? String ?? ""
        let feasibilityAssessment = json["feasibilityAssessment"] as? String ?? ""
        
        return LifeBlueprint(
            vocationDirections: directions.isEmpty ? try await generateLifeBlueprintFallback(profile: profile).vocationDirections : directions,
            strengthsSummary: strengthsSummary.isEmpty ? "您的獨特優勢在於結合了\(strengths)等多項能力。" : strengthsSummary,
            feasibilityAssessment: feasibilityAssessment.isEmpty ? "基於您目前的資源和條件，這些方向都具有良好的可行性。" : feasibilityAssessment
        )
    }
    
    func generateLifeBlueprintFallback(profile: UserProfile) async throws -> LifeBlueprint {
        let interests = profile.interests.joined(separator: "、")
        let strengths = profile.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let topValues = profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        let directions = [
            VocationDirection(
                title: "基於您的興趣和天賦的方向一",
                description: "結合\(interests)的興趣與\(strengths)的天賦，這個方向能夠讓您發揮所長。",
                marketFeasibility: "市場需求穩定，發展前景良好"
            ),
            VocationDirection(
                title: "基於您的價值觀的方向二",
                description: "這個方向能夠體現您的核心價值觀：\(topValues)，讓您在工作中找到意義。",
                marketFeasibility: "市場需求增長中，需要持續學習"
            )
        ]
        
        return LifeBlueprint(
            vocationDirections: directions,
            strengthsSummary: "您的獨特優勢在於結合了\(strengths)等多項能力，這讓您在相關領域具有競爭優勢。",
            feasibilityAssessment: "基於您目前的資源和條件，這些方向都具有良好的可行性。建議從短期目標開始，逐步建立相關經驗和技能。"
        )
    }
    
    func generateActionPlan(profile: UserProfile) async throws -> ActionPlan {
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
            for direction in blueprint.vocationDirections {
                context += "- \(direction.title): \(direction.description)\n"
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
        
        // Remove markdown code blocks if present
        if jsonString.hasPrefix("```json") {
            jsonString = String(jsonString.dropFirst(7))
        }
        if jsonString.hasPrefix("```") {
            jsonString = String(jsonString.dropFirst(3))
        }
        if jsonString.hasSuffix("```") {
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
                         milestones: milestones.isEmpty ? try await generateActionPlanFallback().milestones : milestones)
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
        
        return ActionPlan(shortTerm: shortTerm, midTerm: midTerm, longTerm: longTerm, milestones: milestones)
    }
}
