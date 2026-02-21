import SwiftUI

struct AISummaryView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: BrandSpacing.xxl) {
                VStack(spacing: BrandSpacing.md) {
                    Text("AI 分析總結")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("基於您的輸入，我們為您總結了以下關鍵特質")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                }
                .padding(.top, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                Group {
                    if viewModel.isLoadingSummary {
                        VStack(spacing: BrandSpacing.lg) {
                            ProgressView()
                                .scaleEffect(1.5)
                                .tint(BrandColors.primaryBlue)
                            Text("正在生成AI分析總結...")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            Text("這可能需要幾秒鐘時間")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.tertiaryText)
                        }
                        .padding(.vertical, 60)
                    } else if viewModel.aiSummary.isEmpty {
                        VStack(spacing: BrandSpacing.lg) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 40))
                                .foregroundColor(BrandColors.warning)
                            Text("無法生成總結")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.primaryText)
                            Text("請檢查網絡連接或稍後再試")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.vertical, 60)
                    } else {
                        VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                            // Parse and display markdown properly
                            Text(parseMarkdown(viewModel.aiSummary))
                                .font(BrandTypography.body)
                                .foregroundColor(BrandColors.primaryText)
                                .lineSpacing(8)
                        }
                        .padding(BrandSpacing.xl)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(BrandColors.secondaryBackground)
                        .cornerRadius(BrandRadius.medium)
                        .shadow(color: BrandShadow.medium.color, radius: BrandShadow.medium.radius, x: BrandShadow.medium.x, y: BrandShadow.medium.y)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    }
                }
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Next button - goes to loading animation
                if !viewModel.aiSummary.isEmpty {
                    Button(action: {
                        // Move to loading animation (before payment)
                        viewModel.currentStep = .loading
                    }) {
                        HStack(spacing: BrandSpacing.sm) {
                            Text("下一題")
                                .font(BrandTypography.headline)
                                .fontWeight(.bold)
                            Image(systemName: "arrow.right")
                                .font(.system(size: 16, weight: .bold))
                        }
                        .foregroundColor(BrandColors.invertedText) // Black text on white button
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(BrandColors.primaryText) // White background
                        .clipShape(Capsule()) // Pill shape
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .padding(.top, BrandSpacing.xxl)
                    .padding(.bottom, BrandSpacing.xxxl)
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
}

// Helper function to clean markdown and format it properly
private func parseMarkdown(_ text: String) -> String {
    var cleaned = text
    
    // Remove markdown headers (# ## ### etc.) - just remove the # symbols
    if let regex = try? NSRegularExpression(pattern: #"^#{1,6}\s+"#, options: [.anchorsMatchLines]) {
        let nsString = cleaned as NSString
        let range = NSRange(location: 0, length: nsString.length)
        cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
    }
    
    // Remove bold markdown (**text** or __text__) - keep the text
    cleaned = cleaned.replacingOccurrences(of: #"\*\*(.+?)\*\*"#, with: "$1", options: .regularExpression)
    cleaned = cleaned.replacingOccurrences(of: #"__(.+?)__"#, with: "$1", options: .regularExpression)
    
    // Remove italic markdown (*text* or _text_) - keep the text
    cleaned = cleaned.replacingOccurrences(of: #"(?<!\*)\*(?!\*)(.+?)(?<!\*)\*(?!\*)"#, with: "$1", options: .regularExpression)
    cleaned = cleaned.replacingOccurrences(of: #"(?<!_)_(?!_)(.+?)(?<!_)_(?!_)"#, with: "$1", options: .regularExpression)
    
    // Remove code blocks (```code```)
    cleaned = cleaned.replacingOccurrences(of: #"```[\s\S]*?```"#, with: "", options: .regularExpression)
    
    // Remove inline code (`code`) - keep the text
    cleaned = cleaned.replacingOccurrences(of: #"`([^`]+)`"#, with: "$1", options: .regularExpression)
    
    // Remove links [text](url) - keep the text
    cleaned = cleaned.replacingOccurrences(of: #"\[([^\]]+)\]\([^\)]+\)"#, with: "$1", options: .regularExpression)
    
    // Remove horizontal rules (--- or ***)
    if let regex = try? NSRegularExpression(pattern: #"^[-*]{3,}$"#, options: [.anchorsMatchLines]) {
        let nsString = cleaned as NSString
        let range = NSRange(location: 0, length: nsString.length)
        cleaned = regex.stringByReplacingMatches(in: cleaned, options: [], range: range, withTemplate: "")
    }
    
    // Clean up multiple newlines
    cleaned = cleaned.replacingOccurrences(of: #"\n{3,}"#, with: "\n\n", options: .regularExpression)
    
    // Trim whitespace
    cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)
    
    return cleaned
}

#Preview {
    AISummaryView()
        .environmentObject(InitialScanViewModel())
}
