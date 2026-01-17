import SwiftUI

struct AISummaryView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("AI 分析總結")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("基於您的輸入，我們為您總結了以下關鍵特質")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                if viewModel.isLoadingSummary {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.vertical, 60)
                } else {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(viewModel.aiSummary)
                            .font(.body)
                            .lineSpacing(8)
                    }
                    .padding(20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    .padding(.horizontal, 20)
                }
                
                if !viewModel.aiSummary.isEmpty {
                    Button(action: {
                        viewModel.moveToNextStep()
                    }) {
                        Text("查看初版生命藍圖")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
        }
    }
}

#Preview {
    AISummaryView()
        .environmentObject(InitialScanViewModel())
}
