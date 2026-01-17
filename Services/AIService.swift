import Foundation

class AIService {
    static let shared = AIService()
    
    private init() {}
    
    func generateInitialSummary(interests: [String], strengths: [StrengthResponse], values: [ValueRanking]) async throws -> String {
        // Simulate AI processing delay
        try await Task.sleep(nanoseconds: 1_500_000_000)
        
        let interestsText = interests.joined(separator: "、")
        let strengthsText = strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let topValues = values.sorted { $0.rank < $1.rank }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        return """
        根據您的輸入，我們發現以下關鍵特質：
        
        **興趣關鍵詞**：\(interestsText)
        **天賦關鍵詞**：\(strengthsText)
        **核心價值觀**：\(topValues)
        
        這些特質顯示您是一個...
        """
    }
    
    func generateLifeBlueprint(profile: UserProfile) async throws -> LifeBlueprint {
        // Simulate AI processing delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
        let interests = profile.interests.joined(separator: "、")
        let strengths = profile.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let topValues = profile.values.sorted { $0.rank < $1.rank }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
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
        // Simulate AI processing delay
        try await Task.sleep(nanoseconds: 2_000_000_000)
        
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
