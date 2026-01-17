import SwiftUI

struct InitialScanView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        VStack(spacing: 0) {
            ProgressIndicator(step: viewModel.currentStep)
            
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
        }
        #if os(iOS)
        .navigationBarTitleDisplayMode(.inline)
        #endif
    }
}

struct ProgressIndicator: View {
    let step: InitialScanStep
    
    var body: some View {
        HStack(spacing: 8) {
            ForEach(1...6, id: \.self) { index in
                Circle()
                    .fill(step.rawValue >= index ? Color.blue : Color.gray.opacity(0.3))
                    .frame(width: 12, height: 12)
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 20)
    }
}

#Preview {
    InitialScanView()
        .environmentObject(InitialScanViewModel())
}
