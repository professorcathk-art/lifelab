import SwiftUI

struct InterestsSelectionView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var hasStarted = false
    
    var body: some View {
        ZStack {
            // Pure black background - NO gradients, NO white/gray at bottom
            BrandColors.background
                .ignoresSafeArea()
            
            if !hasStarted {
                welcomeScreen
            } else {
                keywordsSelectionScreen
            }
        }
        .preferredColorScheme(ThemeManager.shared.isDarkMode ? .dark : .light)
    }
    
    // MARK: - Welcome Screen
    private var welcomeScreen: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: BrandSpacing.xxl) {
                    Spacer()
                        .frame(height: BrandSpacing.xxxl)
                    
                    VStack(spacing: BrandSpacing.xxl) {
                        // Hero Icon - Clean circle with purple heart, NO glow/shadow
                        ZStack {
                            Circle()
                                .fill(BrandColors.surface) // #1C1C1E - Dark charcoal
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "heart.fill")
                                .font(.system(size: 60))
                                .foregroundColor(BrandColors.actionAccent) // Purple #8B5CF6
                        }
                        // NO shadow, NO glow - clean and flat
                        
                        VStack(spacing: BrandSpacing.lg) {
                            Text("我喜歡的事")
                                .font(BrandTypography.largeTitle)
                                .foregroundColor(BrandColors.primaryText) // Pure white
                            
                            Text("接下來，我們會請您選擇感興趣的關鍵詞")
                                .font(BrandTypography.title3)
                                .foregroundColor(BrandColors.primaryText) // Pure white
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            
                            // Instruction List - Purple circles, white text, increased spacing
                            VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                                HStack(spacing: BrandSpacing.md) {
                                    Image(systemName: "1.circle.fill")
                                        .foregroundColor(BrandColors.actionAccent) // Purple
                                        .font(.system(size: 20))
                                    Text("點擊您感興趣的關鍵詞")
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                }
                                
                                HStack(spacing: BrandSpacing.md) {
                                    Image(systemName: "2.circle.fill")
                                        .foregroundColor(BrandColors.actionAccent) // Purple
                                        .font(.system(size: 20))
                                    Text("我們會根據您的選擇顯示相關詞語")
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                }
                                
                                HStack(spacing: BrandSpacing.md) {
                                    Image(systemName: "3.circle.fill")
                                        .foregroundColor(BrandColors.actionAccent) // Purple
                                        .font(.system(size: 20))
                                    Text("選擇越多，分析越準確")
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                }
                            }
                            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            .padding(.top, BrandSpacing.sm)
                        }
                        
                        // Warning/Info Box - Dark charcoal background, yellow timer icon, white text
                        VStack(spacing: BrandSpacing.md) {
                            HStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "timer")
                                    .foregroundColor(BrandColors.brandAccent) // Golden yellow #FFC107
                                    .font(.system(size: 18))
                                Text("點擊「開始」後，計時器將開始倒數")
                                    .font(BrandTypography.subheadline)
                                    .fontWeight(.semibold)
                                    .foregroundColor(BrandColors.primaryText) // Pure white
                            }
                            .padding(BrandSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(BrandColors.surface) // #1C1C1E
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(BrandColors.actionAccent.opacity(0.3), lineWidth: 1) // Thin purple border
                                    )
                            )
                            
                            // Timer Text - Large, heavy/monospaced, pure white
                            Text("剩餘時間：\(viewModel.timeRemaining)秒")
                                .font(.system(size: 28, weight: .heavy, design: .monospaced))
                                .foregroundColor(BrandColors.primaryText) // Pure white
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    }
                    .frame(maxWidth: .infinity)
                    
                    Spacer()
                        .frame(height: BrandSpacing.xxxl)
                }
            }
            
            // Fixed Bottom Button - White background, black text, NO glow
            VStack {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        hasStarted = true
                        viewModel.startInterestTimer()
                    }
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Text("開始")
                            .font(BrandTypography.headline)
                            .fontWeight(.bold)
                        Image(systemName: "play.fill")
                            .font(.system(size: 16, weight: .bold))
                    }
                    .foregroundColor(BrandColors.invertedText) // Black text
                    .frame(maxWidth: .infinity)
                    .frame(height: 50) // Fixed height
                    .background(BrandColors.primaryText) // White background
                    .clipShape(Capsule()) // Pill shape
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.bottom, BrandSpacing.lg)
                .padding(.top, BrandSpacing.md)
                .background(BrandColors.background) // Pure black background for button area
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
            }
        }
    }
    
    // MARK: - Keywords Selection Screen
    private var keywordsSelectionScreen: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(spacing: BrandSpacing.xxl) {
                    VStack(spacing: BrandSpacing.md) {
                        Text("我喜歡的事")
                            .font(BrandTypography.largeTitle)
                            .foregroundColor(BrandColors.primaryText)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            .padding(.top, BrandSpacing.xxxl)
                        
                        if viewModel.isTimerActive {
                            // Timer Card - Dark charcoal, yellow timer, white text
                            HStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "timer")
                                    .foregroundColor(BrandColors.brandAccent) // Golden yellow
                                    .font(.system(size: 18))
                                Text("剩餘時間：\(viewModel.timeRemaining)秒")
                                    .font(.system(size: 24, weight: .heavy, design: .monospaced))
                                    .foregroundColor(BrandColors.primaryText) // Pure white
                            }
                            .padding(BrandSpacing.lg)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(BrandColors.surface) // #1C1C1E
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(BrandColors.actionAccent.opacity(0.3), lineWidth: 1)
                                    )
                            )
                            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        } else if viewModel.showConfirmButton {
                            Text("時間到！請點擊「確認」進入下一步")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.primaryText) // Pure white
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        }
                    }
                    
                    // Keywords Grid
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: BrandSpacing.md) {
                        ForEach(viewModel.availableKeywords, id: \.self) { keyword in
                            KeywordButton(
                                keyword: keyword,
                                isSelected: viewModel.selectedInterests.contains(keyword),
                                action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.selectInterest(keyword)
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    
                    // Selected Keywords
                    if !viewModel.selectedInterests.isEmpty {
                        VStack(spacing: BrandSpacing.md) {
                            Text("已選擇：\(viewModel.selectedInterests.count)個")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: BrandSpacing.sm) {
                                    ForEach(viewModel.selectedInterests, id: \.self) { interest in
                                        SelectedKeywordChip(keyword: interest)
                                    }
                                }
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            }
                        }
                        .padding(.top, BrandSpacing.lg)
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    }
                    
                    // Action Buttons
                    if viewModel.showConfirmButton || (!viewModel.isTimerActive && !viewModel.selectedInterests.isEmpty) {
                        HStack(spacing: BrandSpacing.md) {
                            // Reset Button
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.resetInterestSelection()
                                }
                            }) {
                                HStack(spacing: BrandSpacing.xs) {
                                    Image(systemName: "arrow.counterclockwise")
                                    Text("重新開始")
                                }
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.actionAccent) // Purple text
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(BrandColors.surface) // Dark charcoal
                                .cornerRadius(BrandRadius.large)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BrandRadius.large)
                                        .stroke(BrandColors.borderColor, lineWidth: 1)
                                )
                            }
                            .buttonStyle(.plain)
                            
                            // Confirm Button - White background, black text, NO glow
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.confirmInterestSelection()
                                }
                            }) {
                                HStack(spacing: BrandSpacing.sm) {
                                    Text("確認")
                                        .font(BrandTypography.headline)
                                        .fontWeight(.bold)
                                    Image(systemName: "checkmark.circle.fill")
                                        .font(.system(size: 16, weight: .bold))
                                }
                                .foregroundColor(BrandColors.invertedText) // Black text
                                .frame(maxWidth: .infinity)
                                .frame(height: 50)
                                .background(BrandColors.primaryText) // White background
                                .clipShape(Capsule()) // Pill shape
                            }
                            .buttonStyle(.plain)
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.top, BrandSpacing.lg)
                        .padding(.bottom, 100) // Space for fixed button if needed
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    }
                }
                .frame(maxWidth: .infinity)
            }
            
            // Fixed Bottom Button (if needed)
            if viewModel.showConfirmButton || (!viewModel.isTimerActive && !viewModel.selectedInterests.isEmpty) {
                // Buttons are already in ScrollView, no fixed button needed
            }
        }
    }
}

// MARK: - Keyword Button (Dark Mode Neon-Minimalist)
struct KeywordButton: View {
    let keyword: String
    let isSelected: Bool
    let action: () -> Void
    
    private var keywordColor: Color {
        let hash = keyword.hashValue
        let colors = BrandColors.keywordColors
        return colors[abs(hash) % colors.count]
    }
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(keyword)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(isSelected ? BrandColors.primaryText : BrandColors.primaryText) // Always white text
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.vertical, BrandSpacing.md)
                .background(
                    Group {
                        if isSelected {
                            // Selected: Purple background
                            BrandColors.actionAccent // #8B5CF6
                        } else {
                            // Unselected: Dark charcoal with subtle border
                            BrandColors.surface // #1C1C1E
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BrandRadius.large)
                        .stroke(
                            isSelected ? Color.clear : keywordColor.opacity(0.3),
                            lineWidth: isSelected ? 0 : 1
                        )
                )
                .cornerRadius(BrandRadius.large)
                // NO shadow, NO glow - clean and flat
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    InterestsSelectionView()
        .environmentObject(InitialScanViewModel())
}
