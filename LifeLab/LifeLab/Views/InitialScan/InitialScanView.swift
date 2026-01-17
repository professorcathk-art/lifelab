import SwiftUI

struct InitialScanView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressIndicator(step: viewModel.currentStep, onStepTap: { step in
                viewModel.goToStep(step)
            })
            
            Group {
                switch viewModel.currentStep {
                case .interests:
                    InterestsSelectionView()
                case .strengths:
                    StrengthsQuestionnaireView()
                case .values:
                    ValuesRankingView()
                case .aiSummary:
                    AISummaryView()
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
    var onStepTap: ((InitialScanStep) -> Void)?
    
    var body: some View {
        HStack(spacing: BrandSpacing.sm) {
            ForEach(1...6, id: \.self) { index in
                Button(action: {
                    if let targetStep = InitialScanStep(rawValue: index) {
                        onStepTap?(targetStep)
                    }
                }) {
                    ZStack {
                        Circle()
                            .fill(step.rawValue >= index ? BrandColors.primaryBlue : BrandColors.tertiaryBackground)
                            .frame(width: 14, height: 14)
                        
                        if step.rawValue >= index {
                            Circle()
                                .fill(.white)
                                .frame(width: 6, height: 6)
                        }
                    }
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, BrandSpacing.lg)
        .padding(.horizontal, BrandSpacing.xl)
        .background(
            RoundedRectangle(cornerRadius: BrandRadius.medium)
                .fill(BrandColors.secondaryBackground)
                .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
        )
        .padding(.horizontal, BrandSpacing.lg)
    }
}

#Preview {
    InitialScanView()
        .environmentObject(InitialScanViewModel())
}
