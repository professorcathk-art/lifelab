import SwiftUI

struct ReviewInitialScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = InitialScanViewModel()
    @EnvironmentObject var dataService: DataService
    @State private var showCancelAlert = false
    @State private var hasUnsavedChanges = false
    @State private var showSaveSuccessAlert = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Header without reset button - Minimal margin
            HStack {
                Button("取消") {
                    if hasUnsavedChanges {
                        showCancelAlert = true
                    } else {
                        dismiss()
                    }
                }
                .foregroundColor(BrandColors.actionAccent)
                .font(BrandTypography.body)
                
                Spacer()
                
                Text("檢視初步掃描")
                    .font(BrandTypography.headline)
                    .foregroundColor(BrandColors.primaryText)
                
                Spacer()
                
                // Placeholder for balance
                Color.clear
                    .frame(width: 60)
            }
            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
            .padding(.vertical, 8) // Fixed small padding instead of BrandSpacing
            .frame(height: 44) // Fixed height to prevent expansion
            .background(BrandColors.surface)
            .frame(maxWidth: ResponsiveLayout.maxContentWidth())
            
            ReviewProgressIndicator(step: viewModel.currentStep, onStepTap: { step in
                // Skip loading, payment, and blueprint steps in review mode
                if step != .loading && step != .payment && step != .blueprint {
                    // IMPORTANT: Save current changes before navigating
                    saveChangesSilently()
                    viewModel.goToStepReviewMode(step)
                }
            })
            
            Group {
                switch viewModel.currentStep {
                case .basicInfo:
                    BasicInfoView()
                        .environmentObject(viewModel)
                        .onChange(of: viewModel.basicInfo) { _ in
                            hasUnsavedChanges = true
                        }
                case .interests:
                    InterestsSelectionView()
                        .environmentObject(viewModel)
                        .onChange(of: viewModel.selectedInterests) { _ in
                            hasUnsavedChanges = true
                        }
                case .strengths:
                    StrengthsQuestionnaireView()
                        .environmentObject(viewModel)
                        .onChange(of: viewModel.strengths) { _ in
                            hasUnsavedChanges = true
                        }
                case .values:
                    ValuesRankingView()
                        .environmentObject(viewModel)
                        .onChange(of: viewModel.selectedValues) { _ in
                            hasUnsavedChanges = true
                        }
                case .aiSummary:
                    AISummaryView(isReviewMode: true)
                        .environmentObject(viewModel)
                        .environmentObject(dataService)
                default:
                    // Skip loading, payment, and blueprint steps in review mode
                    EmptyView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Save button - show on all review steps (blueprint is removed from review mode)
            if viewModel.currentStep != .blueprint && viewModel.currentStep != .loading && viewModel.currentStep != .payment {
                HStack(spacing: 12) {
                    Button(action: {
                        saveChanges()
                    }) {
                        Text("儲存變更")
                            .font(BrandTypography.headline)
                            .fontWeight(.bold)
                            .foregroundColor(BrandColors.invertedText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, BrandSpacing.md)
                            .background(BrandColors.actionAccent)
                            .cornerRadius(BrandRadius.medium)
                    }
                }
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.bottom, BrandSpacing.lg)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
            }
        }
        .frame(maxWidth: .infinity)
        .onAppear {
            loadCurrentData()
        }
        .alert("確認取消", isPresented: $showCancelAlert) {
            Button("繼續編輯", role: .cancel) { }
            Button("放棄變更", role: .destructive) {
                hasUnsavedChanges = false
                dismiss()
            }
        } message: {
            Text("您有未儲存的變更。如果現在取消，所有變更將會遺失。建議您先儲存變更。")
        }
        .alert("變更已儲存", isPresented: $showSaveSuccessAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("您的變更已成功儲存。")
        }
        .environmentObject(viewModel)
    }
    
    private func loadCurrentData() {
        guard let profile = dataService.userProfile else { return }
        
        // Load data synchronously (fast operations)
        viewModel.basicInfo = profile.basicInfo ?? BasicUserInfo()
        viewModel.selectedInterests = profile.interests
        viewModel.strengths = profile.strengths
        viewModel.selectedValues = profile.values
        viewModel.hasPaid = profile.lifeBlueprint != nil
        
        // Load keywords properly
        if !profile.interests.isEmpty {
            viewModel.loadInitialKeywords()
            // Remove already selected interests from available keywords
            for interest in profile.interests {
                viewModel.availableKeywords.removeAll { $0 == interest }
            }
        }
        
        // IMPORTANT: Always restore existing data, don't reset
        // Restore strengths data
        if !profile.strengths.isEmpty {
            // Initialize structure first if empty
            if viewModel.strengths.isEmpty {
                viewModel.initializeStrengthsQuestions()
            }
            // Restore selected keywords and answers from profile
            for (index, strength) in profile.strengths.enumerated() {
                if index < viewModel.strengths.count {
                    viewModel.strengths[index].selectedKeywords = strength.selectedKeywords
                    viewModel.strengths[index].userAnswer = strength.userAnswer
                }
            }
        } else if viewModel.strengths.isEmpty {
            viewModel.initializeStrengthsQuestions()
        }
        
        // Restore values data
        if !profile.values.isEmpty {
            // Initialize structure first if empty
            if viewModel.selectedValues.isEmpty {
                viewModel.initializeValues()
            }
            // Restore values from profile
            for profileValue in profile.values {
                if let index = viewModel.selectedValues.firstIndex(where: { $0.value == profileValue.value }) {
                    viewModel.selectedValues[index] = profileValue
                }
            }
        } else if viewModel.selectedValues.isEmpty {
            viewModel.initializeValues()
        }
        
        // IMPORTANT: Always start from basicInfo for review - allow user to review all answers
        viewModel.currentStep = .basicInfo
        
        // Load AI summary if it exists (but don't regenerate automatically)
        if let existingSummary = profile.lifeBlueprint?.strengthsSummary {
            viewModel.aiSummary = existingSummary
        }
    }
    
    private func saveChanges() {
        // Save all changes to user profile
        saveChangesSilently()
        
        // Show success alert
        showSaveSuccessAlert = true
    }
    
    private func saveChangesSilently() {
        // IMPORTANT: Save all current viewModel data to DataService
        // This includes basicInfo which was missing before
        DataService.shared.updateUserProfile { profile in
            profile.basicInfo = viewModel.basicInfo
            profile.interests = viewModel.selectedInterests
            profile.strengths = viewModel.strengths
            profile.values = viewModel.selectedValues
            
            // If AI summary was regenerated, update it in lifeBlueprint
            if !viewModel.aiSummary.isEmpty {
                // Update strengthsSummary in lifeBlueprint if it exists
                if var blueprint = profile.lifeBlueprint {
                    blueprint.strengthsSummary = viewModel.aiSummary
                    profile.lifeBlueprint = blueprint
                }
                // Also update in all versions if they exist
                if !profile.lifeBlueprints.isEmpty {
                    for i in profile.lifeBlueprints.indices {
                        profile.lifeBlueprints[i].strengthsSummary = viewModel.aiSummary
                    }
                }
            }
        }
        
        // Also call viewModel.saveProgress() for consistency
        viewModel.saveProgress()
        
        hasUnsavedChanges = false
    }
}

// MARK: - Review Progress Indicator (Skips loading and payment steps)
struct ReviewProgressIndicator: View {
    let step: InitialScanStep
    var onStepTap: ((InitialScanStep) -> Void)?
    
    // Steps to show in review mode (skip loading, payment, and blueprint)
    private let reviewSteps: [InitialScanStep] = [.basicInfo, .interests, .strengths, .values, .aiSummary]
    
    var body: some View {
        HStack(spacing: BrandSpacing.sm) {
            ForEach(reviewSteps, id: \.rawValue) { reviewStep in
                Button(action: {
                    onStepTap?(reviewStep)
                }) {
                    ZStack {
                        // Outer circle - Purple for current/completed, dark gray for future
                        Circle()
                            .fill(isStepCompleted(reviewStep) ? BrandColors.actionAccent : BrandColors.surface)
                            .frame(width: 12, height: 12)
                        
                        // Inner white dot for current/completed steps
                        if isStepCompleted(reviewStep) {
                            Circle()
                                .fill(BrandColors.primaryText) // Pure white
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, BrandSpacing.sm) // Reduced from lg to sm
        .frame(maxWidth: .infinity)
    }
    
    private func isStepCompleted(_ reviewStep: InitialScanStep) -> Bool {
        // Map review steps to their raw values (accounting for skipped steps)
        let stepMapping: [InitialScanStep: Int] = [
            .basicInfo: 1,
            .interests: 2,
            .strengths: 3,
            .values: 4,
            .aiSummary: 5
        ]
        
        if let currentStepValue = stepMapping[step],
           let reviewStepValue = stepMapping[reviewStep] {
            return currentStepValue >= reviewStepValue
        }
        return false
    }
}

#Preview {
    ReviewInitialScanView()
        .environmentObject(DataService.shared)
}
