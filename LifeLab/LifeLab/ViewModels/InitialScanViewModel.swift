import Foundation
import SwiftUI
import Combine

@MainActor
class InitialScanViewModel: ObservableObject {
    @Published var currentStep: InitialScanStep = .interests
    @Published var selectedInterests: [String] = []
    @Published var availableKeywords: [String] = []
    @Published var timeRemaining: Int = 10
    @Published var isTimerActive = false
    @Published var strengths: [StrengthResponse] = []
    @Published var currentStrengthQuestionIndex = 0
    @Published var selectedValues: [ValueRanking] = []
    @Published var aiSummary: String = ""
    @Published var isLoadingSummary = false
    @Published var hasPaid = false
    @Published var lifeBlueprint: LifeBlueprint?
    @Published var isLoadingBlueprint = false
    
    private let interestDictionary = InterestDictionary.shared
    private let strengthsQuestions = StrengthsQuestions.shared
    private var timer: Timer?
    
    init() {
        loadInitialKeywords()
    }
    
    func loadInitialKeywords() {
        availableKeywords = interestDictionary.getAllKeywords()
    }
    
    func selectInterest(_ keyword: String) {
        selectedInterests.append(keyword)
        availableKeywords.removeAll { $0 == keyword }
        
        let relatedKeywords = interestDictionary.getRelatedKeywords(for: keyword)
        let newKeywords = relatedKeywords.filter { !selectedInterests.contains($0) && !availableKeywords.contains($0) }
        availableKeywords.append(contentsOf: newKeywords)
    }
    
    func startInterestTimer() {
        isTimerActive = true
        timeRemaining = 10
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            Task { @MainActor in
                if self.timeRemaining > 0 {
                    self.timeRemaining -= 1
                } else {
                    self.stopTimer()
                    self.moveToNextStep()
                }
            }
        }
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }
    
    func moveToNextStep() {
        stopTimer()
        switch currentStep {
        case .interests:
            initializeStrengthsQuestions()
            currentStep = .strengths
        case .strengths:
            initializeValues()
            currentStep = .values
        case .values:
            currentStep = .aiSummary
            generateAISummary()
        case .aiSummary:
            currentStep = .payment
        case .payment:
            currentStep = .blueprint
            generateLifeBlueprint()
        case .blueprint:
            break
        }
    }
    
    func moveToPreviousStep() {
        stopTimer()
        switch currentStep {
        case .interests:
            break // Already at first step
        case .strengths:
            currentStep = .interests
        case .values:
            currentStep = .strengths
        case .aiSummary:
            currentStep = .values
        case .payment:
            currentStep = .aiSummary
        case .blueprint:
            currentStep = .payment
        }
    }
    
    func goToStep(_ step: InitialScanStep) {
        stopTimer()
        currentStep = step
        
        // Reinitialize data if needed
        switch step {
        case .strengths:
            if strengths.isEmpty {
                initializeStrengthsQuestions()
            }
        case .values:
            if selectedValues.isEmpty {
                initializeValues()
            }
        case .aiSummary:
            if aiSummary.isEmpty {
                generateAISummary()
            }
        case .blueprint:
            if lifeBlueprint == nil {
                generateLifeBlueprint()
            }
        default:
            break
        }
    }
    
    func resetInitialScan() {
        stopTimer()
        selectedInterests = []
        availableKeywords = interestDictionary.getAllKeywords()
        strengths = []
        currentStrengthQuestionIndex = 0
        selectedValues = []
        aiSummary = ""
        hasPaid = false
        lifeBlueprint = nil
        currentStep = .interests
        loadInitialKeywords()
    }
    
    func initializeStrengthsQuestions() {
        strengths = strengthsQuestions.questions.map { question in
            StrengthResponse(questionId: question.id, question: question.question)
        }
    }
    
    func selectStrengthKeyword(_ keyword: String, for questionId: Int) {
        if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
            if !strengths[index].selectedKeywords.contains(keyword) {
                strengths[index].selectedKeywords.append(keyword)
            }
        }
    }
    
    func removeStrengthKeyword(_ keyword: String, from questionId: Int) {
        if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
            strengths[index].selectedKeywords.removeAll { $0 == keyword }
        }
    }
    
    func initializeValues() {
        selectedValues = CoreValue.allCases.map { value in
            ValueRanking(value: value, rank: 0, isGreyedOut: false)
        }
    }
    
    func updateValueRank(_ valueId: UUID, newRank: Int) {
        if let index = selectedValues.firstIndex(where: { $0.id == valueId }) {
            selectedValues[index].rank = newRank
        }
    }
    
    func reorderValues(from source: IndexSet, to destination: Int) {
        selectedValues.move(fromOffsets: source, toOffset: destination)
        for (index, _) in selectedValues.enumerated() {
            selectedValues[index].rank = index + 1
        }
    }
    
    func generateAISummary() {
        isLoadingSummary = true
        Task {
            do {
                // Add timeout to prevent infinite loading
                let summary = try await withThrowingTaskGroup(of: String.self) { [weak self] group in
                    guard let self = self else {
                        throw NSError(domain: "ViewModel", code: -1, userInfo: [NSLocalizedDescriptionKey: "ViewModel deallocated"])
                    }
                    group.addTask {
                        try await AIService.shared.generateInitialSummary(
                            interests: self.selectedInterests,
                            strengths: self.strengths,
                            values: self.selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                        )
                    }
                    
                    group.addTask {
                        try await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                        throw NSError(domain: "Timeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
                    }
                    
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                }
                
                await MainActor.run {
                    self.aiSummary = summary
                    self.isLoadingSummary = false
                }
            } catch {
                print("AI Summary generation error: \(error)")
                await MainActor.run {
                    self.isLoadingSummary = false
                    // Generate fallback summary
                    self.aiSummary = generateFallbackSummary()
                }
            }
        }
    }
    
    private func generateFallbackSummary() -> String {
        let interestsText = self.selectedInterests.joined(separator: "、")
        let strengthsText = self.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
        let strengthsAnswers = self.strengths.compactMap { $0.userAnswer }.filter { !$0.isEmpty }
        let topValues = self.selectedValues.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
        
        var summary = "根據您的輸入，我們發現以下關鍵特質：\n\n"
        
        if !interestsText.isEmpty {
            summary += "**興趣關鍵詞**：\(interestsText)\n\n"
        }
        
        if !strengthsText.isEmpty {
            summary += "**天賦關鍵詞**：\(strengthsText)\n\n"
        }
        
        if !strengthsAnswers.isEmpty {
            summary += "**您的天賦回答**：\n"
            for (index, answer) in strengthsAnswers.enumerated() {
                summary += "\(index + 1). \(answer)\n"
            }
            summary += "\n"
        }
        
        if !topValues.isEmpty {
            summary += "**核心價值觀**：\(topValues)\n\n"
        }
        
        summary += "這些特質顯示您是一個具有獨特優勢的人。結合您的興趣、天賦和價值觀，我們建議您探索能夠發揮這些特質的領域，找到真正適合您的發展方向。"
        
        return summary
    }
    
    func completePayment() {
        hasPaid = true
        moveToNextStep()
    }
    
    func generateLifeBlueprint() {
        isLoadingBlueprint = true
        Task {
            do {
                var profile = UserProfile()
                profile.interests = selectedInterests
                profile.strengths = strengths
                profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                
                // Add timeout to prevent infinite loading
                let blueprint = try await withThrowingTaskGroup(of: LifeBlueprint.self) { group in
                    group.addTask {
                        try await AIService.shared.generateLifeBlueprint(profile: profile)
                    }
                    
                    group.addTask {
                        try await Task.sleep(nanoseconds: 30_000_000_000) // 30 seconds
                        throw NSError(domain: "Timeout", code: -1, userInfo: [NSLocalizedDescriptionKey: "Request timed out"])
                    }
                    
                    let result = try await group.next()!
                    group.cancelAll()
                    return result
                }
                
                await MainActor.run {
                    self.lifeBlueprint = blueprint
                    self.isLoadingBlueprint = false
                    DataService.shared.updateUserProfile { profile in
                        profile.lifeBlueprint = blueprint
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingBlueprint = false
                }
                
                // Use fallback if API fails
                var profile = UserProfile()
                profile.interests = selectedInterests
                profile.strengths = strengths
                profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                
                do {
                    let fallbackBlueprint = try await AIService.shared.generateLifeBlueprintFallback(profile: profile)
                    await MainActor.run {
                        self.lifeBlueprint = fallbackBlueprint
                        DataService.shared.updateUserProfile { profile in
                            profile.lifeBlueprint = fallbackBlueprint
                        }
                    }
                } catch {
                    print("Fallback generation failed: \(error)")
                }
            }
        }
    }
    
    func saveProgress() {
        DataService.shared.updateUserProfile { profile in
            profile.interests = selectedInterests
            profile.strengths = strengths
            profile.values = selectedValues.filter { $0.rank > 0 }
        }
    }
}
