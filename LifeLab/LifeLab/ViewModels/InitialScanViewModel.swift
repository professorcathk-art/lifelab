import Foundation
import SwiftUI
import Combine

@MainActor
class InitialScanViewModel: ObservableObject {
    @Published var currentStep: InitialScanStep = .basicInfo
    @Published var basicInfo: BasicUserInfo = BasicUserInfo()
    @Published var selectedInterests: [String] = []
    @Published var availableKeywords: [String] = []
    // New: Track selected sub-interests per category (for Interests)
    @Published var selectedSubInterests: [String: Set<String>] = [:] // categoryId -> Set of subInterestIds
    // New: Track selected talents per category (for Strengths Question 1)
    @Published var selectedTalents: [String: Set<String>] = [:] // categoryId -> Set of subTalentIds
    // New: Track selected energies per category (for Strengths Question 2)
    @Published var selectedEnergies: [String: Set<String>] = [:] // categoryId -> Set of subEnergyIds
    // New: Track selected praises per category (for Strengths Question 3)
    @Published var selectedPraises: [String: Set<String>] = [:] // categoryId -> Set of subPraiseIds
    // New: Track selected learnings per category (for Strengths Question 4)
    @Published var selectedLearnings: [String: Set<String>] = [:] // categoryId -> Set of subLearningIds
    // New: Track selected fulfillments per category (for Strengths Question 5)
    @Published var selectedFulfillments: [String: Set<String>] = [:] // categoryId -> Set of subFulfillmentIds
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
    @Published var hasGivenAIConsent = false  // Track user consent for AI data sharing
    
    // Store background task ID for blueprint generation
    private var blueprintBackgroundTaskID: UIBackgroundTaskIdentifier = .invalid
    
    private let interestDictionary = InterestDictionary.shared
    private let strengthsQuestions = StrengthsQuestions.shared
    private var timer: Timer?
    
    init() {
        loadInitialKeywords()
        // Load AI consent status from UserDefaults (user-specific)
        loadAIConsentStatus()
    }
    
    func loadAIConsentStatus() {
        if let userId = AuthService.shared.currentUser?.id {
            let consentKey = "lifelab_ai_consent_\(userId)"
            hasGivenAIConsent = UserDefaults.standard.bool(forKey: consentKey)
            print("📋 Loaded AI consent status for user \(userId): \(hasGivenAIConsent)")
        } else {
            hasGivenAIConsent = false
            print("📋 No user ID, consent status: false")
        }
    }
    
    func saveAIConsentStatus() {
        if let userId = AuthService.shared.currentUser?.id {
            let consentKey = "lifelab_ai_consent_\(userId)"
            UserDefaults.standard.set(true, forKey: consentKey)
            hasGivenAIConsent = true
        }
    }
    
    func loadInitialKeywords() {
        // Only load first-level keywords initially
        availableKeywords = interestDictionary.getAllKeywords()
    }
    
    func resetInterestSelection() {
        stopTimer()
        selectedInterests = []
        selectedSubInterests = [:]
        availableKeywords = interestDictionary.getAllKeywords()
        timeRemaining = 15
        isTimerActive = false
        showConfirmButton = false
    }
    
    // New: Get count of selected sub-interests for a category
    func getSelectedCount(for categoryId: String) -> Int {
        return selectedSubInterests[categoryId]?.count ?? 0
    }
    
    // New: Toggle sub-interest selection
    func toggleSubInterest(categoryId: String, subInterestId: String, label: String) {
        if selectedSubInterests[categoryId] == nil {
            selectedSubInterests[categoryId] = []
        }
        
        if selectedSubInterests[categoryId]?.contains(subInterestId) == true {
            // Deselect
            selectedSubInterests[categoryId]?.remove(subInterestId)
            selectedInterests.removeAll { $0 == label }
        } else {
            // Select
            selectedSubInterests[categoryId]?.insert(subInterestId)
            if !selectedInterests.contains(label) {
                selectedInterests.append(label)
            }
        }
    }
    
    // New: Check if sub-interest is selected
    func isSubInterestSelected(categoryId: String, subInterestId: String) -> Bool {
        return selectedSubInterests[categoryId]?.contains(subInterestId) ?? false
    }
    
    // New: Get all selected sub-interest labels for final submission
    func getAllSelectedSubInterestLabels() -> [String] {
        let dictionary = InterestDictionary.shared
        var labels: [String] = []
        
        for (categoryId, subInterestIds) in selectedSubInterests {
            if let category = dictionary.getCategory(byId: categoryId) {
                for subInterestId in subInterestIds {
                    if let subInterest = category.subInterests.first(where: { $0.id == subInterestId }) {
                        labels.append(subInterest.label)
                    }
                }
            }
        }
        
        return labels
    }
    
    // MARK: - Talent Selection (for Strengths Question 1)
    
    // Get count of selected talents for a category
    func getSelectedTalentCount(for categoryId: String) -> Int {
        return selectedTalents[categoryId]?.count ?? 0
    }
    
    // Toggle talent selection
    func toggleTalent(categoryId: String, talentId: String, label: String, questionId: Int) {
        if selectedTalents[categoryId] == nil {
            selectedTalents[categoryId] = []
        }
        
        // Get category title (first-level keyword)
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.talentCategories,
              let category = categories.first(where: { $0.id == categoryId }) else {
            return
        }
        let categoryTitle = category.title
        
        if selectedTalents[categoryId]?.contains(talentId) == true {
            // Deselect
            selectedTalents[categoryId]?.remove(talentId)
            // Remove from strength response
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                strengths[index].selectedKeywords.removeAll { $0 == label }
                // Only remove category title if no other sub-items are selected for this category
                if selectedTalents[categoryId]?.isEmpty ?? true {
                    strengths[index].selectedKeywords.removeAll { $0 == categoryTitle }
                }
            }
        } else {
            // Select
            selectedTalents[categoryId]?.insert(talentId)
            // Add to strength response (both category title and sub-label)
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                // Add category title (first-level keyword) if not already present
                if !strengths[index].selectedKeywords.contains(categoryTitle) {
                    strengths[index].selectedKeywords.append(categoryTitle)
                }
                // Add sub-label (second-level keyword)
                if !strengths[index].selectedKeywords.contains(label) {
                    strengths[index].selectedKeywords.append(label)
                }
            }
        }
    }
    
    // Check if talent is selected
    func isTalentSelected(categoryId: String, talentId: String) -> Bool {
        return selectedTalents[categoryId]?.contains(talentId) ?? false
    }
    
    // Get all selected talent labels for Question 1
    func getAllSelectedTalentLabels(for questionId: Int) -> [String] {
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.talentCategories else {
            return []
        }
        
        var labels: [String] = []
        
        for (categoryId, talentIds) in selectedTalents {
            if let category = categories.first(where: { $0.id == categoryId }) {
                for talentId in talentIds {
                    if let talent = category.subTalents.first(where: { $0.id == talentId }) {
                        labels.append(talent.label)
                    }
                }
            }
        }
        
        return labels
    }
    
    // MARK: - Energy Selection (for Strengths Question 2)
    
    // Get count of selected energies for a category
    func getSelectedEnergyCount(for categoryId: String) -> Int {
        return selectedEnergies[categoryId]?.count ?? 0
    }
    
    // Toggle energy selection
    func toggleEnergy(categoryId: String, energyId: String, label: String, questionId: Int) {
        if selectedEnergies[categoryId] == nil {
            selectedEnergies[categoryId] = []
        }
        
        // Get category title (first-level keyword)
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.energyCategories,
              let category = categories.first(where: { $0.id == categoryId }) else {
            return
        }
        let categoryTitle = category.title
        
        if selectedEnergies[categoryId]?.contains(energyId) == true {
            // Deselect
            selectedEnergies[categoryId]?.remove(energyId)
            // Remove from strength response
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                strengths[index].selectedKeywords.removeAll { $0 == label }
                // Only remove category title if no other sub-items are selected for this category
                if selectedEnergies[categoryId]?.isEmpty ?? true {
                    strengths[index].selectedKeywords.removeAll { $0 == categoryTitle }
                }
            }
        } else {
            // Select
            selectedEnergies[categoryId]?.insert(energyId)
            // Add to strength response (both category title and sub-label)
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                // Add category title (first-level keyword) if not already present
                if !strengths[index].selectedKeywords.contains(categoryTitle) {
                    strengths[index].selectedKeywords.append(categoryTitle)
                }
                // Add sub-label (second-level keyword)
                if !strengths[index].selectedKeywords.contains(label) {
                    strengths[index].selectedKeywords.append(label)
                }
            }
        }
    }
    
    // Check if energy is selected
    func isEnergySelected(categoryId: String, energyId: String) -> Bool {
        return selectedEnergies[categoryId]?.contains(energyId) ?? false
    }
    
    // Get all selected energy labels for Question 2
    func getAllSelectedEnergyLabels(for questionId: Int) -> [String] {
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.energyCategories else {
            return []
        }
        
        var labels: [String] = []
        
        for (categoryId, energyIds) in selectedEnergies {
            if let category = categories.first(where: { $0.id == categoryId }) {
                for energyId in energyIds {
                    if let energy = category.subEnergies.first(where: { $0.id == energyId }) {
                        labels.append(energy.label)
                    }
                }
            }
        }
        
        return labels
    }
    
    // MARK: - Praise Selection (for Strengths Question 3)
    
    // Get count of selected praises for a category
    func getSelectedPraiseCount(for categoryId: String) -> Int {
        return selectedPraises[categoryId]?.count ?? 0
    }
    
    // Toggle praise selection
    func togglePraise(categoryId: String, praiseId: String, label: String, questionId: Int) {
        if selectedPraises[categoryId] == nil {
            selectedPraises[categoryId] = []
        }
        
        // Get category title (first-level keyword)
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.praiseCategories,
              let category = categories.first(where: { $0.id == categoryId }) else {
            return
        }
        let categoryTitle = category.title
        
        if selectedPraises[categoryId]?.contains(praiseId) == true {
            // Deselect
            selectedPraises[categoryId]?.remove(praiseId)
            // Remove from strength response
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                strengths[index].selectedKeywords.removeAll { $0 == label }
                // Only remove category title if no other sub-items are selected for this category
                if selectedPraises[categoryId]?.isEmpty ?? true {
                    strengths[index].selectedKeywords.removeAll { $0 == categoryTitle }
                }
            }
        } else {
            // Select
            selectedPraises[categoryId]?.insert(praiseId)
            // Add to strength response (both category title and sub-label)
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                // Add category title (first-level keyword) if not already present
                if !strengths[index].selectedKeywords.contains(categoryTitle) {
                    strengths[index].selectedKeywords.append(categoryTitle)
                }
                // Add sub-label (second-level keyword)
                if !strengths[index].selectedKeywords.contains(label) {
                    strengths[index].selectedKeywords.append(label)
                }
            }
        }
    }
    
    // Check if praise is selected
    func isPraiseSelected(categoryId: String, praiseId: String) -> Bool {
        return selectedPraises[categoryId]?.contains(praiseId) ?? false
    }
    
    // Get all selected praise labels for Question 3
    func getAllSelectedPraiseLabels(for questionId: Int) -> [String] {
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.praiseCategories else {
            return []
        }
        
        var labels: [String] = []
        
        for (categoryId, praiseIds) in selectedPraises {
            if let category = categories.first(where: { $0.id == categoryId }) {
                for praiseId in praiseIds {
                    if let praise = category.subPraises.first(where: { $0.id == praiseId }) {
                        labels.append(praise.label)
                    }
                }
            }
        }
        
        return labels
    }
    
    // MARK: - Learning Selection (for Strengths Question 4)
    
    // Get count of selected learnings for a category
    func getSelectedLearningCount(for categoryId: String) -> Int {
        return selectedLearnings[categoryId]?.count ?? 0
    }
    
    // Toggle learning selection
    func toggleLearning(categoryId: String, learningId: String, label: String, questionId: Int) {
        if selectedLearnings[categoryId] == nil {
            selectedLearnings[categoryId] = []
        }
        
        // Get category title (first-level keyword)
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.learningCategories,
              let category = categories.first(where: { $0.id == categoryId }) else {
            return
        }
        let categoryTitle = category.title
        
        if selectedLearnings[categoryId]?.contains(learningId) == true {
            // Deselect
            selectedLearnings[categoryId]?.remove(learningId)
            // Remove from strength response
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                strengths[index].selectedKeywords.removeAll { $0 == label }
                // Only remove category title if no other sub-items are selected for this category
                if selectedLearnings[categoryId]?.isEmpty ?? true {
                    strengths[index].selectedKeywords.removeAll { $0 == categoryTitle }
                }
            }
        } else {
            // Select
            selectedLearnings[categoryId]?.insert(learningId)
            // Add to strength response (both category title and sub-label)
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                // Add category title (first-level keyword) if not already present
                if !strengths[index].selectedKeywords.contains(categoryTitle) {
                    strengths[index].selectedKeywords.append(categoryTitle)
                }
                // Add sub-label (second-level keyword)
                if !strengths[index].selectedKeywords.contains(label) {
                    strengths[index].selectedKeywords.append(label)
                }
            }
        }
    }
    
    // Check if learning is selected
    func isLearningSelected(categoryId: String, learningId: String) -> Bool {
        return selectedLearnings[categoryId]?.contains(learningId) ?? false
    }
    
    // Get all selected learning labels for Question 4
    func getAllSelectedLearningLabels(for questionId: Int) -> [String] {
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.learningCategories else {
            return []
        }
        
        var labels: [String] = []
        
        for (categoryId, learningIds) in selectedLearnings {
            if let category = categories.first(where: { $0.id == categoryId }) {
                for learningId in learningIds {
                    if let learning = category.subLearning.first(where: { $0.id == learningId }) {
                        labels.append(learning.label)
                    }
                }
            }
        }
        
        return labels
    }
    
    // MARK: - Fulfillment Selection (for Strengths Question 5)
    
    // Get count of selected fulfillments for a category
    func getSelectedFulfillmentCount(for categoryId: String) -> Int {
        return selectedFulfillments[categoryId]?.count ?? 0
    }
    
    // Toggle fulfillment selection
    func toggleFulfillment(categoryId: String, fulfillmentId: String, label: String, questionId: Int) {
        if selectedFulfillments[categoryId] == nil {
            selectedFulfillments[categoryId] = []
        }
        
        // Get category title (first-level keyword)
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.fulfillmentCategories,
              let category = categories.first(where: { $0.id == categoryId }) else {
            return
        }
        let categoryTitle = category.title
        
        if selectedFulfillments[categoryId]?.contains(fulfillmentId) == true {
            // Deselect
            selectedFulfillments[categoryId]?.remove(fulfillmentId)
            // Remove from strength response
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                strengths[index].selectedKeywords.removeAll { $0 == label }
                // Only remove category title if no other sub-items are selected for this category
                if selectedFulfillments[categoryId]?.isEmpty ?? true {
                    strengths[index].selectedKeywords.removeAll { $0 == categoryTitle }
                }
            }
        } else {
            // Select
            selectedFulfillments[categoryId]?.insert(fulfillmentId)
            // Add to strength response (both category title and sub-label)
            if let index = strengths.firstIndex(where: { $0.questionId == questionId }) {
                // Add category title (first-level keyword) if not already present
                if !strengths[index].selectedKeywords.contains(categoryTitle) {
                    strengths[index].selectedKeywords.append(categoryTitle)
                }
                // Add sub-label (second-level keyword)
                if !strengths[index].selectedKeywords.contains(label) {
                    strengths[index].selectedKeywords.append(label)
                }
            }
        }
    }
    
    // Check if fulfillment is selected
    func isFulfillmentSelected(categoryId: String, fulfillmentId: String) -> Bool {
        return selectedFulfillments[categoryId]?.contains(fulfillmentId) ?? false
    }
    
    // Get all selected fulfillment labels for Question 5
    func getAllSelectedFulfillmentLabels(for questionId: Int) -> [String] {
        guard let question = StrengthsQuestions.shared.questions.first(where: { $0.id == questionId }),
              let categories = question.fulfillmentCategories else {
            return []
        }
        
        var labels: [String] = []
        
        for (categoryId, fulfillmentIds) in selectedFulfillments {
            if let category = categories.first(where: { $0.id == categoryId }) {
                for fulfillmentId in fulfillmentIds {
                    if let fulfillment = category.subFulfillment.first(where: { $0.id == fulfillmentId }) {
                        labels.append(fulfillment.label)
                    }
                }
            }
        }
        
        return labels
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
        // CRITICAL: Sync selectedSubInterests to selectedInterests before moving to next step
        // This ensures backward compatibility with existing code that uses selectedInterests
        let allLabels = getAllSelectedSubInterestLabels()
        selectedInterests = allLabels
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
            // Check if user has already given consent (from login page)
            if hasGivenAIConsent {
                // User already consented during login, proceed directly to AI summary
                currentStep = .aiSummary
                generateAISummary()
            } else {
                // User hasn't consented yet (shouldn't happen if login flow is correct, but fallback)
                // Move to AI consent screen before sending data to AI
                currentStep = .aiConsent
            }
        case .aiConsent:
            // Only proceed to AI summary if consent has been given
            guard hasGivenAIConsent else {
                print("⚠️ User has not given AI consent yet")
                return
            }
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
        case .aiConsent:
            currentStep = .values
        case .aiSummary:
            currentStep = .aiConsent
        case .loading:
            currentStep = .aiSummary
        case .payment:
            // CRITICAL: Don't allow going back from payment page to loading page
            // User must complete payment to proceed
            currentStep = .payment // Stay on payment page
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
        
        // Question 1 uses talentCategories (Bottom Sheet pattern), not keywordHierarchy
        if question.id == 1 {
            // Return empty array - Question 1 uses Bottom Sheet, not inline keywords
            return []
        }
        
        // Question 2 uses energyCategories (Bottom Sheet pattern), not keywordHierarchy
        if question.id == 2 {
            // Return empty array - Question 2 uses Bottom Sheet, not inline keywords
            return []
        }
        
        // Question 3 uses praiseCategories (Bottom Sheet pattern), not keywordHierarchy
        if question.id == 3 {
            // Return empty array - Question 3 uses Bottom Sheet, not inline keywords
            return []
        }
        
        // Question 4 uses learningCategories (Bottom Sheet pattern), not keywordHierarchy
        if question.id == 4 {
            // Return empty array - Question 4 uses Bottom Sheet, not inline keywords
            return []
        }
        
        // Question 5 uses fulfillmentCategories (Bottom Sheet pattern), not keywordHierarchy
        if question.id == 5 {
            // Return empty array - Question 5 uses Bottom Sheet, not inline keywords
            return []
        }
        
        // Get first-level keywords (keys of keywordHierarchy) for Questions 2-5
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
        // CRITICAL: Ensure user has given consent before sending data to AI
        guard hasGivenAIConsent else {
            print("❌ Cannot generate AI summary: User has not given consent")
            isLoadingSummary = false
            return
        }
        
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
        // Navigate to loading page immediately
        currentStep = .loading
        // Start blueprint generation in background (non-blocking)
        generateLifeBlueprint()
    }
    
    func generateLifeBlueprint() {
        // CRITICAL: Ensure user has given consent before sending data to AI
        guard hasGivenAIConsent else {
            print("❌ Cannot generate life blueprint: User has not given consent")
            isLoadingBlueprint = false
            return
        }
        
        isLoadingBlueprint = true
        
        // CRITICAL: Request background execution time to continue task even when app is minimized
        // This allows the task to continue for up to ~30 seconds after app goes to background
        // Store background task ID in class property so it can be accessed in closures
        blueprintBackgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "GenerateLifeBlueprint") { [weak self] in
            // Task expired - end background task
            print("⚠️ Background task expired - ending task")
            guard let self = self else { return }
            if self.blueprintBackgroundTaskID != .invalid {
                UIApplication.shared.endBackgroundTask(self.blueprintBackgroundTaskID)
                self.blueprintBackgroundTaskID = .invalid
            }
        }
        
        // Capture current values before starting background task
        let currentBasicInfo = basicInfo
        let currentInterests = selectedInterests
        let currentStrengths = strengths
        let currentValues = selectedValues
        
        // Capture background task ID for use in Task closure
        let capturedTaskID = blueprintBackgroundTaskID
        
        print("🔄 Starting blueprint generation (will continue in background if app is minimized)")
        print("   Background task ID: \(capturedTaskID.rawValue)")
        
        // Use Task to ensure task continues even if app goes to background
        // beginBackgroundTask provides up to ~30 seconds of background execution time
        Task { [weak self] in
            guard let self = self else {
                // End background task if view model is deallocated
                if capturedTaskID != .invalid {
                    await MainActor.run {
                        UIApplication.shared.endBackgroundTask(capturedTaskID)
                    }
                }
                return
            }
            
            // Helper function to end background task
            let endBackgroundTask = {
                if self.blueprintBackgroundTaskID != .invalid {
                    UIApplication.shared.endBackgroundTask(self.blueprintBackgroundTaskID)
                    self.blueprintBackgroundTaskID = .invalid
                    print("✅ Background task ended successfully")
                }
            }
            
            do {
                // Use complete user profile from DataService to include ALL data (including deepening exploration data)
                // Initialize profile first, then update it
                let profile: UserProfile = await MainActor.run {
                    if let existingProfile = DataService.shared.userProfile {
                        // Use existing profile with ALL data
                        var updatedProfile = existingProfile
                        // Update with current form data (captured before task started)
                        updatedProfile.basicInfo = currentBasicInfo
                        updatedProfile.interests = currentInterests
                        updatedProfile.strengths = currentStrengths
                        updatedProfile.values = currentValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                        return updatedProfile
                    } else {
                        // Fallback: create new profile with current data
                        var newProfile = UserProfile()
                        newProfile.basicInfo = currentBasicInfo
                        newProfile.interests = currentInterests
                        newProfile.strengths = currentStrengths
                        newProfile.values = currentValues.filter { $0.rank > 0 && !$0.isGreyedOut }
                        return newProfile
                    }
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
                
                print("✅ Blueprint generation completed (even if app was in background)")
                
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
                    
                    // CRITICAL: Do NOT set currentStep to .blueprint here
                    // ContentView will automatically detect the blueprint and switch to MainTabView
                    // Setting currentStep here would keep user on the blueprint preview page
                    print("✅ Blueprint saved to DataService, ContentView will immediately switch to MainTabView")
                    print("   NOT setting currentStep - ContentView will handle navigation automatically")
                    
                    // End background task now that we're done
                    endBackgroundTask()
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
                    
                    // End background task even on error
                    endBackgroundTask()
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
