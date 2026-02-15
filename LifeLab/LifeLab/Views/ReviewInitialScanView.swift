import SwiftUI

struct ReviewInitialScanView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = InitialScanViewModel()
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        VStack(spacing: 0) {
            // Header with reset option
            HStack {
                Button("取消") {
                    dismiss()
                }
                .foregroundColor(.blue)
                
                Spacer()
                
                Text("檢視初步掃描")
                    .font(.headline)
                
                Spacer()
                
                Button("重置") {
                    resetInitialScan()
                }
                .foregroundColor(.red)
            }
            .padding()
            .background(Color(.systemGray6))
            
            ProgressIndicator(step: viewModel.currentStep, onStepTap: { step in
                viewModel.saveProgress()
                viewModel.goToStep(step)
            })
            
            Group {
                switch viewModel.currentStep {
                case .basicInfo:
                    BasicInfoView()
                        .environmentObject(viewModel)
                case .interests:
                    InterestsSelectionView()
                        .environmentObject(viewModel)
                case .strengths:
                    StrengthsQuestionnaireView()
                        .environmentObject(viewModel)
                case .values:
                    ValuesRankingView()
                        .environmentObject(viewModel)
                case .aiSummary:
                    AISummaryView()
                        .environmentObject(viewModel)
                case .loading:
                    PlanGenerationLoadingView {
                        viewModel.currentStep = .payment
                    }
                case .payment:
                    PaymentView()
                        .environmentObject(viewModel)
                case .blueprint:
                    LifeBlueprintView()
                        .environmentObject(viewModel)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Navigation buttons - Hidden "上一步" and "下一步", users can use progress dots instead
            // Only show "完成檢視" button on blueprint step
            if viewModel.currentStep == .blueprint {
                HStack(spacing: 12) {
                    Button(action: {
                        viewModel.saveProgress()
                        dismiss()
                    }) {
                        Text("完成檢視")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(hex: "10b6cc"))
                            .cornerRadius(12)
                    }
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 16)
            }
        }
        .onAppear {
            loadCurrentData()
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
        
        // Set current step based on progress
        if profile.lifeBlueprint != nil {
            viewModel.lifeBlueprint = profile.lifeBlueprint
            viewModel.currentStep = .blueprint
        } else if !profile.values.isEmpty {
            // If values exist but no blueprint, regenerate summary if needed
            if viewModel.aiSummary.isEmpty {
                viewModel.generateAISummary()
            }
            viewModel.currentStep = .aiSummary
        } else if !profile.strengths.isEmpty {
            if viewModel.selectedValues.isEmpty {
                viewModel.initializeValues()
            }
            viewModel.currentStep = .values
        } else if !profile.interests.isEmpty {
            if viewModel.strengths.isEmpty {
                viewModel.initializeStrengthsQuestions()
            }
            viewModel.currentStep = .strengths
        } else if profile.basicInfo != nil {
            viewModel.currentStep = .interests
        } else {
            viewModel.currentStep = .basicInfo
        }
    }
    
    private func resetInitialScan() {
        viewModel.resetInitialScan()
        DataService.shared.updateUserProfile { profile in
            profile.interests = []
            profile.strengths = []
            profile.values = []
            profile.lifeBlueprint = nil
        }
    }
}

#Preview {
    ReviewInitialScanView()
        .environmentObject(DataService.shared)
}
