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
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("正在生成AI分析總結...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("這可能需要幾秒鐘時間")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 60)
                } else if viewModel.aiSummary.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 40))
                            .foregroundColor(.orange)
                        Text("無法生成總結")
                            .font(.headline)
                        Text("請檢查網絡連接或稍後再試")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.vertical, 60)
                } else {
                    VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                        Text(viewModel.aiSummary)
                            .font(BrandTypography.body)
                            .foregroundColor(BrandColors.primaryText)
                            .lineSpacing(8)
                    }
                    .padding(BrandSpacing.xl)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(BrandColors.secondaryBackground)
                    .cornerRadius(BrandRadius.medium)
                    .shadow(color: BrandShadow.medium.color, radius: BrandShadow.medium.radius, x: BrandShadow.medium.x, y: BrandShadow.medium.y)
                    .padding(.horizontal, BrandSpacing.xl)
                }
                
                // Navigation handled by progress dots - no buttons needed
            }
        }
    }
}

#Preview {
    AISummaryView()
        .environmentObject(InitialScanViewModel())
}
