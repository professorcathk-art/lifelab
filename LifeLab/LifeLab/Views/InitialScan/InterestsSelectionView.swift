import SwiftUI

struct InterestsSelectionView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var hasStarted = false
    @State private var selectedCategory: InterestCategory? = nil
    @State private var showBottomSheet = false
    
    private let interestDictionary = InterestDictionary.shared
    
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
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .sheet(isPresented: $showBottomSheet) {
            if let category = selectedCategory {
                SubInterestsBottomSheet(
                    category: category,
                    onToggle: { subInterestId, label in
                        viewModel.toggleSubInterest(categoryId: category.id, subInterestId: subInterestId, label: label)
                        // Update selectedInterests array for backward compatibility
                        updateSelectedInterestsArray()
                    },
                    isSelected: { subInterestId in
                        viewModel.isSubInterestSelected(categoryId: category.id, subInterestId: subInterestId)
                    }
                )
                .presentationDetents([.medium, .large])
                .presentationDragIndicator(.visible)
            }
        }
    }
    
    private func updateSelectedInterestsArray() {
        // Sync selectedSubInterests to selectedInterests for backward compatibility
        let allLabels = viewModel.getAllSelectedSubInterestLabels()
        viewModel.selectedInterests = allLabels
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
                                    Text("點擊類別查看子選項")
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                }
                                
                                HStack(spacing: BrandSpacing.md) {
                                    Image(systemName: "2.circle.fill")
                                        .foregroundColor(BrandColors.actionAccent) // Purple
                                        .font(.system(size: 20))
                                    Text("在底部抽屜中選擇您感興趣的子項目")
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
                    .foregroundColor(
                        // CRITICAL: Ensure proper contrast
                        // Dark mode: White background → Black text
                        // Light mode: Dark charcoal background → White text
                        themeManager.isDarkMode ? Color.black : Color.white
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 50) // Fixed height
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
                    
                    // Level 1 Categories Grid - Dense 2-3 column grid
                    let columns = ResponsiveLayout.getGridColumns(minWidth: 140, maxColumns: 3)
                    LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                        ForEach(interestDictionary.categories) { category in
                            CategoryPillButton(
                                category: category,
                                selectedCount: viewModel.getSelectedCount(for: category.id),
                                action: {
                                    selectedCategory = category
                                    showBottomSheet = true
                                }
                            )
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    
                    // Selected Count Summary
                    let totalSelected = viewModel.selectedInterests.count
                    if totalSelected > 0 {
                        VStack(spacing: BrandSpacing.md) {
                            Text("已選擇：\(totalSelected)個")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            // Show selected sub-interests in a scrollable horizontal list
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
                    if viewModel.showConfirmButton || (!viewModel.isTimerActive && totalSelected > 0) {
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
                                // Update selectedInterests array before confirming
                                updateSelectedInterestsArray()
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
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.top, BrandSpacing.lg)
                        .padding(.bottom, 100) // Space for fixed button if needed
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    }
                }
                .frame(maxWidth: .infinity)
            }
        }
    }
}

// MARK: - Category Pill Button (Level 1)
struct CategoryPillButton: View {
    let category: InterestCategory
    let selectedCount: Int
    let action: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: BrandSpacing.sm) {
                Text(category.title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(BrandColors.primaryText)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                // Badge showing selected count
                if selectedCount > 0 {
                    Text("+\(selectedCount)")
                        .font(BrandTypography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.invertedText)
                        .padding(.horizontal, BrandSpacing.xs)
                        .padding(.vertical, 2)
                        .background(BrandColors.actionAccent)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if selectedCount > 0 {
                        // Has selections: Glowing purple border
                        BrandColors.surface
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandRadius.large)
                                    .stroke(
                                        BrandColors.actionAccent,
                                        lineWidth: 2
                                    )
                                    .shadow(color: BrandColors.actionAccent.opacity(0.5), radius: 4)
                            )
                    } else {
                        // No selections: Dark charcoal with subtle border
                        BrandColors.surface
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.large)
                    .stroke(
                        selectedCount > 0 ? Color.clear : BrandColors.borderColor,
                        lineWidth: selectedCount > 0 ? 0 : 1
                    )
            )
            .cornerRadius(BrandRadius.large)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Sub Interests Bottom Sheet
struct SubInterestsBottomSheet: View {
    let category: InterestCategory
    let onToggle: (String, String) -> Void
    let isSelected: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                VStack(spacing: BrandSpacing.md) {
                    Text(category.title)
                        .font(BrandTypography.title2)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("你最享受哪種過程？")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                }
                .padding(.top, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.md)
                
                Divider()
                    .background(BrandColors.borderColor)
                
                // Sub-interests Grid (3 columns, flex-wrap style)
                ScrollView {
                    let columns = ResponsiveLayout.getGridColumns(minWidth: 100, maxColumns: 3)
                    LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                        ForEach(category.subInterests) { subInterest in
                            SubInterestPillButton(
                                subInterest: subInterest,
                                isSelected: isSelected(subInterest.id),
                                action: {
                                    onToggle(subInterest.id, subInterest.label)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .padding(.vertical, BrandSpacing.lg)
                }
                
                Spacer()
            }
            .background(BrandColors.background)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(BrandColors.actionAccent)
                    .font(BrandTypography.headline)
                }
            }
        }
    }
}

// MARK: - Sub Interest Pill Button (Level 2)
struct SubInterestPillButton: View {
    let subInterest: SubInterest
    let isSelected: Bool
    let action: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(subInterest.label)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.md)
                .padding(.vertical, BrandSpacing.sm)
                .frame(maxWidth: .infinity)
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
                    RoundedRectangle(cornerRadius: BrandRadius.medium)
                        .stroke(
                            isSelected ? Color.clear : BrandColors.borderColor,
                            lineWidth: isSelected ? 0 : 1
                        )
                )
                .cornerRadius(BrandRadius.medium)
                .scaleEffect(isSelected ? 1.05 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// Note: SelectedKeywordChip is defined in StrengthsQuestionnaireView.swift and reused here

// MARK: - Responsive Layout Extension
extension ResponsiveLayout {
    static func getGridColumns(minWidth: CGFloat, maxColumns: Int) -> [GridItem] {
        let screenWidth = UIScreen.main.bounds.width
        let hPadding = horizontalPadding() * 2
        let availableWidth = screenWidth - hPadding
        let spacing: CGFloat = BrandSpacing.md
        
        // Calculate optimal number of columns
        // iPad: Use more columns (up to maxColumns)
        // iPhone: Use 2-3 columns based on screen width
        let isIPad = isIPad()
        let baseColumns = isIPad ? maxColumns : min(maxColumns, 3)
        
        // Calculate how many columns can fit
        let columns = min(baseColumns, max(2, Int(availableWidth / (minWidth + spacing))))
        
        return Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)
    }
}

#Preview {
    InterestsSelectionView()
        .environmentObject(InitialScanViewModel())
}
