import Foundation
import SwiftUI
import Combine

@MainActor
class InitialScanViewModel: ObservableObject {
    @Published var currentStep: InitialScanStep = .interests
    @Published var selectedInterests: [String] = []
    @Published var availableKeywords: [String] = []
    @Published var timeRemaining: Int = 60
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
        timeRemaining = 60
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            Task { @MainActor in
                guard let self = self else { return }
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
            ValueRanking(value: value, rank: 0)
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
                let summary = try await AIService.shared.generateInitialSummary(
                    interests: selectedInterests,
                    strengths: strengths,
                    values: selectedValues.filter { $0.rank > 0 }
                )
                await MainActor.run {
                    self.aiSummary = summary
                    self.isLoadingSummary = false
                }
            } catch {
                await MainActor.run {
                    self.isLoadingSummary = false
                }
            }
        }
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
                profile.values = selectedValues.filter { $0.rank > 0 }
                
                let blueprint = try await AIService.shared.generateLifeBlueprint(profile: profile)
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
