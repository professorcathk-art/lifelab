import SwiftUI

struct InterestsSelectionView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var hasStarted = false
    
    var body: some View {
        if !hasStarted {
            // Welcome/Introduction Screen
            welcomeScreen
        } else {
            // Keywords Selection Screen
            keywordsSelectionScreen
        }
    }
    
    private var welcomeScreen: some View {
        VStack(spacing: 32) {
            Spacer()
            
            VStack(spacing: BrandSpacing.xxl) {
                Image(systemName: "heart.fill")
                    .font(.system(size: 60))
                    .foregroundColor(BrandColors.primaryBlue)
                
                VStack(spacing: BrandSpacing.lg) {
                    Text("我喜歡的事")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("接下來，我們會請您選擇感興趣的關鍵詞")
                        .font(BrandTypography.title3)
                        .foregroundColor(BrandColors.primaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.xxxl)
                    
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.md) {
                            Image(systemName: "1.circle.fill")
                                .foregroundColor(BrandColors.primaryBlue)
                            Text("點擊您感興趣的關鍵詞")
                                .font(BrandTypography.body)
                                .foregroundColor(BrandColors.primaryText)
                        }
                        
                        HStack(spacing: BrandSpacing.md) {
                            Image(systemName: "2.circle.fill")
                                .foregroundColor(BrandColors.primaryBlue)
                            Text("我們會根據您的選擇顯示相關詞語")
                                .font(BrandTypography.body)
                                .foregroundColor(BrandColors.primaryText)
                        }
                        
                        HStack(spacing: BrandSpacing.md) {
                            Image(systemName: "3.circle.fill")
                                .foregroundColor(BrandColors.primaryBlue)
                            Text("選擇越多，分析越準確")
                                .font(BrandTypography.body)
                                .foregroundColor(BrandColors.primaryText)
                        }
                    }
                    .padding(.horizontal, BrandSpacing.xxxl)
                    .padding(.top, BrandSpacing.sm)
                }
                
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.sm) {
                            Image(systemName: "timer")
                                .foregroundColor(BrandColors.warning)
                            Text("點擊「開始」後，計時器將開始倒數")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.warning)
                                .fontWeight(.semibold)
                        }
                        .padding(BrandSpacing.lg)
                        .background(BrandColors.warning.opacity(0.1))
                        .cornerRadius(BrandRadius.medium)
                        
                        Text("剩餘時間：\(viewModel.timeRemaining)秒")
                            .font(BrandTypography.title2)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.horizontal, BrandSpacing.xxxl)
            }
            
            Spacer()
            
            Button(action: {
                hasStarted = true
                viewModel.startInterestTimer()
            }) {
                HStack(spacing: BrandSpacing.sm) {
                    Text("開始")
                    Image(systemName: "play.fill")
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.lg)
                .background(BrandColors.primaryGradient)
                .cornerRadius(BrandRadius.medium)
                .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
            }
            .buttonStyle(.plain)
            .padding(.horizontal, BrandSpacing.xxxl)
            .padding(.bottom, 60)
        }
    }
    
    private var keywordsSelectionScreen: some View {
        VStack(spacing: BrandSpacing.xxl) {
            VStack(spacing: BrandSpacing.md) {
                Text("我喜歡的事")
                    .font(BrandTypography.largeTitle)
                    .foregroundColor(BrandColors.primaryText)
                
                if viewModel.isTimerActive {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "timer")
                            .foregroundColor(BrandColors.warning)
                        Text("剩餘時間：\(viewModel.timeRemaining)秒")
                            .font(BrandTypography.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(BrandColors.warning)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.warning.opacity(0.1))
                    .cornerRadius(BrandRadius.medium)
                } else if viewModel.showConfirmButton {
                    Text("時間到！請點擊「確認」進入下一步")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.warning)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.xxxl)
                }
            }
            .padding(.top, BrandSpacing.xxxl)
            
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: BrandSpacing.md) {
                    ForEach(viewModel.availableKeywords, id: \.self) { keyword in
                        KeywordButton(
                            keyword: keyword,
                            isSelected: false,
                            action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    viewModel.selectInterest(keyword)
                                }
                            }
                        )
                    }
                }
                .padding(.horizontal, BrandSpacing.xl)
            }
            
                    VStack(spacing: BrandSpacing.md) {
                        if !viewModel.selectedInterests.isEmpty {
                            Text("已選擇：\(viewModel.selectedInterests.count)個")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: BrandSpacing.sm) {
                                    ForEach(viewModel.selectedInterests, id: \.self) { interest in
                                        SelectedKeywordChip(keyword: interest)
                                    }
                                }
                                .padding(.horizontal, BrandSpacing.xl)
                            }
                        }
                        
                        // Action buttons
                        // Only show buttons when timer ends or user can confirm
                        if viewModel.showConfirmButton || (!viewModel.isTimerActive && !viewModel.selectedInterests.isEmpty) {
                            HStack(spacing: BrandSpacing.md) {
                                // Reset button - only show when timer ends
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
                                    .foregroundColor(BrandColors.primaryBlue)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, BrandSpacing.lg)
                                    .background(BrandColors.primaryBlue.opacity(0.1))
                                    .cornerRadius(BrandRadius.medium)
                                }
                                .buttonStyle(.plain)
                                
                                // Confirm button - show when timer ends or user can confirm anytime
                                Button(action: {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        viewModel.confirmInterestSelection()
                                    }
                                }) {
                                    HStack(spacing: BrandSpacing.sm) {
                                        Text("確認")
                                        Image(systemName: "checkmark.circle.fill")
                                    }
                                    .font(BrandTypography.headline)
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, BrandSpacing.lg)
                                    .background(BrandColors.primaryGradient)
                                    .cornerRadius(BrandRadius.medium)
                                    .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                                }
                                .buttonStyle(.plain)
                            }
                            .padding(.horizontal, BrandSpacing.xl)
                        }
                    }
                    .padding(.bottom, BrandSpacing.xxxl)
        }
    }
}

struct KeywordButton: View {
    let keyword: String
    let isSelected: Bool
    let action: () -> Void
    
    // Get color based on keyword hash
    private var keywordColor: Color {
        let hash = keyword.hashValue
        let colors = BrandColors.keywordColors
        return colors[abs(hash) % colors.count]
    }
    
    private var keywordGradient: LinearGradient {
        let gradients = BrandColors.colorfulGradients
        let hash = keyword.hashValue
        return gradients[abs(hash) % gradients.count]
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
                .foregroundColor(isSelected ? .white : BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.vertical, BrandSpacing.md)
                .background(
                    Group {
                        if isSelected {
                            keywordGradient
                        } else {
                            LinearGradient(
                                colors: [keywordColor.opacity(0.2), keywordColor.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        }
                    }
                )
                .overlay(
                    RoundedRectangle(cornerRadius: BrandRadius.large)
                        .stroke(isSelected ? Color.clear : keywordColor.opacity(0.3), lineWidth: 1.5)
                )
                .cornerRadius(BrandRadius.large)
                .shadow(
                    color: isSelected ? keywordColor.opacity(0.4) : BrandShadow.small.color,
                    radius: isSelected ? 8 : BrandShadow.small.radius,
                    x: 0,
                    y: isSelected ? 4 : BrandShadow.small.y
                )
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

struct SelectedKeywordChip: View {
    let keyword: String
    
    private var keywordColor: Color {
        let hash = keyword.hashValue
        let colors = BrandColors.keywordColors
        return colors[abs(hash) % colors.count]
    }
    
    var body: some View {
        HStack(spacing: BrandSpacing.xs) {
            Text(keyword)
                .font(BrandTypography.caption)
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
        }
        .foregroundColor(.white)
        .padding(.horizontal, BrandSpacing.md)
        .padding(.vertical, BrandSpacing.xs)
        .background(
            LinearGradient(
                colors: [keywordColor, keywordColor.opacity(0.8)],
                startPoint: .leading,
                endPoint: .trailing
            )
        )
        .cornerRadius(BrandRadius.large)
        .shadow(color: keywordColor.opacity(0.3), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    InterestsSelectionView()
        .environmentObject(InitialScanViewModel())
}
