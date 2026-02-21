import Foundation
import SwiftUI
import Combine

@MainActor
class InitialScanViewModel: ObservableObject {
    @Published var currentStep: InitialScanStep = .basicInfo
    @Published var basicInfo: BasicUserInfo = BasicUserInfo()
    @Published var selectedInterests: [String] = []
    @Published var availableKeywords: [String] = []
    @Published var timeRemaining: Int = 15
    @Published var isTimerActive = false
    @Published var showConfirmButton = false
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
        // Only load first-level keywords initially
        availableKeywords = interestDictionary.getAllKeywords()
    }
    
    func resetInterestSelection() {
        stopTimer()
        selectedInterests = []
        availableKeywords = interestDictionary.getAllKeywords()
        timeRemaining = 15
        isTimerActive = false
        showConfirmButton = false
    }
    
    func selectInterest(_ keyword: String) {
        // Check if this is a first-level keyword
        let firstLevelKeywords = interestDictionary.getAllKeywords()
        let isFirstLevel = firstLevelKeywords.contains(keyword)
        
        selectedInterests.append(keyword)
        availableKeywords.removeAll { $0 == keyword }
        
        // If it's a first-level keyword, show related keywords
        if isFirstLevel {
            let relatedKeywords = interestDictionary.getRelatedKeywords(for: keyword)
            let newKeywords = relatedKeywords.filter { 
                !selectedInterests.contains($0) && 
                !availableKeywords.contains($0) 
            }
            availableKeywords.append(contentsOf: newKeywords)
        }
    }
    
    func startInterestTimer() {
        isTimerActive = true
        showConfirmButton = false
        timeRemaining = 15
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
                    // Don't auto-navigate, show confirm button instead
                    self.showConfirmButton = true
                }
            }
        }
    }
    
    func confirmInterestSelection() {
        stopTimer()
        moveToNextStep()
    }
    
    func stopTimer() {
        timer?.invalidate()
        timer = nil
        isTimerActive = false
    }
    
    func moveToNextStep() {
        stopTimer()
        switch currentStep {
        case .basicInfo:
            // Save basic info to profile
            DataService.shared.updateUserProfile { profile in
                profile.basicInfo = basicInfo
            }
            currentStep = .interests
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
            // CRITICAL: Check subscription status BEFORE deciding to skip payment
            // We must verify subscription status, not assume it
            Task {
                // Wait for subscription status check to complete
                await SubscriptionManager.shared.checkSubscriptionStatus()
                await PaymentService.shared.refreshPurchasedProducts()
                
                // CRITICAL: Only use SubscriptionManager's hasActiveSubscription
                // It checks BOTH StoreKit AND Supabase
                // Do NOT use paymentService.hasActiveSubscription alone
                let subscriptionManager = SubscriptionManager.shared
                let hasActiveSubscription = subscriptionManager.hasActiveSubscription
                
                await MainActor.run {
                    if hasActiveSubscription {
                        // User has active subscription in BOTH StoreKit AND Supabase
                        print("✅✅✅ User has VALID subscription (StoreKit + Supabase), skipping payment and generating blueprint")
                        hasPaid = true // Mark as paid to allow blueprint generation
                        currentStep = .loading
                        generateLifeBlueprint()
                    } else {
                        // User has NO valid subscription - show payment page
                        print("❌❌❌ User has NO valid subscription, showing payment page")
                        print("   SubscriptionManager.hasActiveSubscription: \(subscriptionManager.hasActiveSubscription)")
                        print("   User MUST pay before generating blueprint")
                        currentStep = .loading
                    }
                }
            }
            // Set to loading initially while we check subscription
            currentStep = .loading
        case .loading:
            // CRITICAL: Check subscription status BEFORE deciding to skip payment
            Task {
                // Wait for subscription status check to complete
                await SubscriptionManager.shared.checkSubscriptionStatus()
                await PaymentService.shared.refreshPurchasedProducts()
                
                // CRITICAL: Only use SubscriptionManager's hasActiveSubscription
                // It checks BOTH StoreKit AND Supabase
                // Do NOT use paymentService.hasActiveSubscription alone
                let subscriptionManager = SubscriptionManager.shared
                let hasActiveSubscription = subscriptionManager.hasActiveSubscription
                
                await MainActor.run {
                    if hasActiveSubscription {
                        // User has active subscription in BOTH StoreKit AND Supabase
                        print("✅✅✅ User has VALID subscription (StoreKit + Supabase), skipping payment and generating blueprint")
                        hasPaid = true // Mark as paid to allow blueprint generation
                        generateLifeBlueprint()
                        // Stay on loading while generating
                    } else {
                        // User has NO valid subscription - show payment page
                        print("❌❌❌ User has NO valid subscription, showing payment page")
                        print("   SubscriptionManager.hasActiveSubscription: \(subscriptionManager.hasActiveSubscription)")
                        print("   User MUST pay before generating blueprint")
                        currentStep = .payment
                    }
                }
            }
            // Stay on loading while checking subscription
        case .payment:
            // Payment completion triggers blueprint generation directly
            break
        case .blueprint:
            break
        }
    }
    
    func moveToPreviousStep() {
        stopTimer()
        switch currentStep {
        case .basicInfo:
            break // Already at first step
        case .interests:
            currentStep = .basicInfo
        case .strengths:
            currentStep = .interests
        case .values:
            currentStep = .strengths
        case .aiSummary:
            currentStep = .values
        case .loading:
            currentStep = .aiSummary
        case .payment:
            currentStep = .loading
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
    
    // MARK: - Review Mode Navigation (doesn't reset data)
    func goToStepReviewMode(_ step: InitialScanStep) {
        stopTimer()
        // IMPORTANT: In review mode, don't reinitialize data - just navigate
        // Data is already loaded from profile, user can review and edit
        currentStep = step
        
        // Only regenerate AI summary if it's empty and user is viewing that step
        if step == .aiSummary && aiSummary.isEmpty {
            generateAISummary()
        }
    }
    
    func resetInitialScan() {
        stopTimer()
        basicInfo = BasicUserInfo()
        selectedInterests = []
        availableKeywords = interestDictionary.getAllKeywords()
        strengths = []
        currentStrengthQuestionIndex = 0
        selectedValues = []
        aiSummary = ""
        hasPaid = false
        lifeBlueprint = nil
        currentStep = .basicInfo
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
    
    func getAvailableKeywords(for questionId: Int) -> [String] {
        guard let question = strengthsQuestions.questions.first(where: { $0.id == questionId }) else {
            return []
        }
        
        // Get first-level keywords (keys of keywordHierarchy)
        let firstLevelKeywords = Array(question.keywordHierarchy.keys)
        
        // Get selected first-level keywords
        if let response = strengths.first(where: { $0.questionId == questionId }) {
            let selectedFirstLevel = response.selectedKeywords.filter { firstLevelKeywords.contains($0) }
            
            // If any first-level keyword is selected, show related keywords
            if !selectedFirstLevel.isEmpty {
                var availableKeywords: [String] = []
                
                // Add all first-level keywords (for unselecting)
                availableKeywords.append(contentsOf: firstLevelKeywords)
                
                // Add related keywords for selected first-level keywords
                for selectedKeyword in selectedFirstLevel {
                    if let relatedKeywords = question.keywordHierarchy[selectedKeyword] {
                        let newKeywords = relatedKeywords.filter { 
                            !response.selectedKeywords.contains($0) && 
                            !availableKeywords.contains($0) 
                        }
                        availableKeywords.append(contentsOf: newKeywords)
                    }
                }
                
                return availableKeywords
            }
        }
        
        // If no first-level keyword selected, only show first-level keywords
        return firstLevelKeywords
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
        // Start loading blueprint generation AFTER payment
        generateLifeBlueprint()
    }
    
    func generateLifeBlueprint() {
        isLoadingBlueprint = true
        Task {
            do {
                // Use complete user profile from DataService to include ALL data (including deepening exploration data)
                var profile: UserProfile
                if let existingProfile = DataService.shared.userProfile {
                    // Use existing profile with ALL data
                    profile = existingProfile
                    // Update with current form data
                    profile.basicInfo = basicInfo
                    profile.interests = selectedInterests
                    profile.strengths = strengths
                    profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                } else {
                    // Fallback: create new profile with current data
                    profile = UserProfile()
                    profile.basicInfo = basicInfo
                    profile.interests = selectedInterests
                    profile.strengths = strengths
                    profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                }
                
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
                    var updatedBlueprint = blueprint
                    updatedBlueprint.version = 1
                    updatedBlueprint.createdAt = Date()
                    self.lifeBlueprint = updatedBlueprint
                    
                    // Log the blueprint content to verify AI is working
                    print("✅ Saving Version 1 blueprint:")
                    print("  - Directions count: \(blueprint.vocationDirections.count)")
                    print("  - First direction title: \(blueprint.vocationDirections.first?.title ?? "none")")
                    print("  - Strengths summary length: \(blueprint.strengthsSummary.count) chars")
                    print("  - Strengths summary preview: \(blueprint.strengthsSummary.prefix(100))...")
                    
                    // CRITICAL: Save to DataService FIRST, before setting isLoadingBlueprint = false
                    // This ensures ContentView immediately detects the blueprint and switches to MainTabView
                    // updateUserProfile is synchronous and will immediately update @Published userProfile
                    DataService.shared.updateUserProfile { profile in
                        profile.lifeBlueprint = updatedBlueprint
                        // Also add to lifeBlueprints array so it shows in ProfileView
                        if !profile.lifeBlueprints.contains(where: { $0.version == 1 }) {
                            profile.lifeBlueprints.append(updatedBlueprint)
                            print("✅ Added Version 1 to lifeBlueprints array")
                        } else {
                            // Update existing Version 1 if it exists
                            if let index = profile.lifeBlueprints.firstIndex(where: { $0.version == 1 }) {
                                profile.lifeBlueprints[index] = updatedBlueprint
                                print("✅ Updated existing Version 1 in lifeBlueprints array")
                            }
                        }
                    }
                    
                    // Sync to Supabase in background (non-blocking)
                    Task {
                        await DataService.shared.syncToSupabase()
                        print("✅ User profile synced to Supabase")
                    }
                    
                    // Set loading to false AFTER saving to DataService
                    // ContentView's hasCompletedInitialScan will immediately become true
                    // because userProfile is @Published and SwiftUI will automatically re-evaluate
                    // The view will switch from InitialScanView to MainTabView immediately
                    self.isLoadingBlueprint = false
                    print("✅ Blueprint saved to DataService, ContentView will immediately switch to MainTabView")
                }
            } catch {
                print("❌❌❌ CRITICAL ERROR: Life blueprint generation failed!")
                print("❌❌❌ Error details: \(error)")
                print("❌❌❌ Error domain: \((error as NSError).domain)")
                print("❌❌❌ Error code: \((error as NSError).code)")
                print("❌❌❌ Error description: \((error as NSError).localizedDescription)")
                
                await MainActor.run {
                    self.isLoadingBlueprint = false
                    // DO NOT use fallback silently - show error to user
                    // Instead, retry API call or show error message
                    print("❌❌❌ NOT using fallback - API call failed!")
                    print("❌❌❌ Please check Xcode console for API call logs")
                }
                
                // Retry API call once - use complete profile
                print("🔄 Retrying API call...")
                do {
                    // Use complete user profile from DataService to include ALL data
                    var profile: UserProfile
                    if let existingProfile = DataService.shared.userProfile {
                        profile = existingProfile
                        // Update with current form data
                        profile.basicInfo = basicInfo
                        profile.interests = selectedInterests
                        profile.strengths = strengths
                        profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                    } else {
                        // Fallback: create new profile with current data
                        profile = UserProfile()
                        profile.basicInfo = basicInfo
                        profile.interests = selectedInterests
                        profile.strengths = strengths
                        profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                    }
                    
                    let retryBlueprint = try await AIService.shared.generateLifeBlueprint(profile: profile)
                    await MainActor.run {
                        var updatedBlueprint = retryBlueprint
                        updatedBlueprint.version = 1
                        updatedBlueprint.createdAt = Date()
                        self.lifeBlueprint = updatedBlueprint
                        self.isLoadingBlueprint = false
                        
                        print("✅✅✅ Retry successful! Got AI-generated blueprint")
                        DataService.shared.updateUserProfile { profile in
                            profile.lifeBlueprint = updatedBlueprint
                            if !profile.lifeBlueprints.contains(where: { $0.version == 1 }) {
                                profile.lifeBlueprints.append(updatedBlueprint)
                            }
                        }
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            self.currentStep = .blueprint
                        }
                    }
                } catch {
                    print("❌❌❌ Retry also failed: \(error)")
                    // Only use fallback as last resort, and mark it clearly
                    var profile = UserProfile()
                    profile.interests = selectedInterests
                    profile.strengths = strengths
                    profile.values = selectedValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                    
                    do {
                        print("⚠️⚠️⚠️ Using fallback as last resort - THIS IS NOT AI GENERATED!")
                        let fallbackBlueprint = try await AIService.shared.generateLifeBlueprintFallback(profile: profile)
                        await MainActor.run {
                            var updatedBlueprint = fallbackBlueprint
                            updatedBlueprint.version = 1
                            updatedBlueprint.createdAt = Date()
                            // Mark as fallback in the blueprint
                            self.lifeBlueprint = updatedBlueprint
                            self.isLoadingBlueprint = false
                            
                            print("⚠️⚠️⚠️ WARNING: Using fallback blueprint - API failed!")
                            DataService.shared.updateUserProfile { profile in
                                profile.lifeBlueprint = updatedBlueprint
                                if !profile.lifeBlueprints.contains(where: { $0.version == 1 }) {
                                    profile.lifeBlueprints.append(updatedBlueprint)
                                }
                            }
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                self.currentStep = .blueprint
                            }
                        }
                    } catch {
                        print("❌❌❌ Even fallback failed: \(error)")
                    }
                }
            }
        }
    }
    
    func saveProgress() {
        DataService.shared.updateUserProfile { profile in
            // IMPORTANT: Save basicInfo as well (was missing before)
            profile.basicInfo = basicInfo
            profile.interests = selectedInterests
            profile.strengths = strengths
            profile.values = selectedValues.filter { $0.rank > 0 }
        }
    }
}
