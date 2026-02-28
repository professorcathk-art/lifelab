import SwiftUI

struct AISummaryView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @EnvironmentObject var dataService: DataService
    var isReviewMode: Bool = false // Flag to indicate if in review mode
    
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
                
                // Button - different for review mode vs initial scan
                if !viewModel.aiSummary.isEmpty {
                    if isReviewMode {
                        // Review mode: Show regenerate button
                        Button(action: {
                            // Regenerate AI summary
                            viewModel.generateAISummary()
                        }) {
                            HStack(spacing: BrandSpacing.sm) {
                                if viewModel.isLoadingSummary {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(
                                            tint: themeManager.isDarkMode ? Color.black : Color.white
                                        ))
                                        .scaleEffect(0.9)
                                } else {
                                    Image(systemName: "arrow.clockwise")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                Text(viewModel.isLoadingSummary ? "正在重新生成..." : "重新生成 AI 分析總結")
                                    .font(BrandTypography.headline)
                                    .fontWeight(.bold)
                            }
                            .foregroundColor(
                                // CRITICAL: Ensure proper contrast
                                // Dark mode: White background → Black text
                                // Light mode: Purple background → White text
                                themeManager.isDarkMode ? Color.black : Color.white
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                // CRITICAL: Ensure proper contrast
                                // Dark mode: White background
                                // Light mode: Purple background
                                themeManager.isDarkMode ? Color.white : BrandColors.actionAccent
                            )
                            .clipShape(Capsule()) // Pill shape
                        }
                        .buttonStyle(.plain)
                        .disabled(viewModel.isLoadingSummary)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.top, BrandSpacing.xxl)
                        .padding(.bottom, BrandSpacing.xxxl)
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                        .onChange(of: viewModel.aiSummary) { newSummary in
                            // When AI summary is regenerated, save to user profile
                            if !newSummary.isEmpty && !viewModel.isLoadingSummary {
                                dataService.updateUserProfile { profile in
                                    // Update strengthsSummary in lifeBlueprint if it exists
                                    if var blueprint = profile.lifeBlueprint {
                                        blueprint.strengthsSummary = newSummary
                                        profile.lifeBlueprint = blueprint
                                    }
                                    // Also update in all versions if they exist
                                    if !profile.lifeBlueprints.isEmpty {
                                        for i in profile.lifeBlueprints.indices {
                                            profile.lifeBlueprints[i].strengthsSummary = newSummary
                                        }
                                    }
                                }
                                print("✅ AI summary updated in user profile")
                            }
                        }
                    } else {
                        // Initial scan mode: Show next button
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
                            .foregroundColor(
                                // CRITICAL: Ensure proper contrast
                                // Dark mode: White background → Black text
                                // Light mode: Dark charcoal background → White text
                                themeManager.isDarkMode ? Color.black : Color.white
                            )
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                // CRITICAL: Ensure proper contrast
                                // Dark mode: White background
                                // Light mode: Dark charcoal background
                                themeManager.isDarkMode ? Color.white : BrandColors.primaryText
                            )
                            .clipShape(Capsule()) // Pill shape
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.top, BrandSpacing.xxl)
                        .padding(.bottom, BrandSpacing.xxxl)
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    }
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
