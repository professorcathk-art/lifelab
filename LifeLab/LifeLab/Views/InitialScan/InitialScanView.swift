import SwiftUI

struct InitialScanView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressIndicator(step: viewModel.currentStep)
            
            Group {
                switch viewModel.currentStep {
                case .basicInfo:
                    BasicInfoView()
                case .interests:
                    InterestsSelectionView()
                case .strengths:
                    StrengthsQuestionnaireView()
                case .values:
                    ValuesRankingView()
                case .aiSummary:
                    AISummaryView()
                case .loading:
                    // Show loading animation BEFORE payment (just animation, no AI)
                    PlanGenerationLoadingView {
                        // After animation completes, show payment page
                        viewModel.currentStep = .payment
                    }
                case .payment:
                    PaymentView()
                case .blueprint:
                    LifeBlueprintView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // No navigation buttons - use progress dots instead
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ProgressIndicator: View {
    let step: InitialScanStep
    
    var body: some View {
        // NO background box - dots directly on pure black background
        // DISABLED: Users cannot tap to jump between steps - must complete in order
        HStack(spacing: BrandSpacing.sm) {
            ForEach(1...8, id: \.self) { index in
                ZStack {
                    // Outer circle - Purple for current/completed, dark gray for future
                    Circle()
                        .fill(step.rawValue >= index ? BrandColors.actionAccent : BrandColors.surface)
                        .frame(width: 12, height: 12)
                    
                    // Inner white dot for current/completed steps
                    if step.rawValue >= index {
                        Circle()
                            .fill(BrandColors.primaryText) // Pure white
                            .frame(width: 6, height: 6)
                    }
                }
            }
        }
        .padding(.vertical, BrandSpacing.lg)
        .frame(maxWidth: .infinity)
        // NO background, NO shadow - clean dots on pure black
        // NO tap interaction - users must complete steps in order
    }
}

#Preview {
    InitialScanView()
        .environmentObject(InitialScanViewModel())
}
