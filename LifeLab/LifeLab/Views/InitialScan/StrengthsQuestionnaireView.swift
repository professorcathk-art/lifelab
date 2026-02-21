import SwiftUI

struct StrengthsQuestionnaireView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var currentQuestionIndex = 0
    @FocusState private var isAnswerFocused: Bool
    
    private var currentQuestion: StrengthsQuestion? {
        let questions = StrengthsQuestions.shared.questions
        guard currentQuestionIndex < questions.count else { return nil }
        return questions[currentQuestionIndex]
    }
    
    private var currentResponse: StrengthResponse? {
        guard let question = currentQuestion else { return nil }
        return viewModel.strengths.first { $0.questionId == question.id }
    }
    
    var body: some View {
        ZStack {
            // Pure black background - NO gradients
            BrandColors.background
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: BrandSpacing.xl) {
                        // Progress indicator
                        VStack(spacing: BrandSpacing.sm) {
                            HStack {
                                Text("問題 \(currentQuestionIndex + 1)/5")
                                    .font(BrandTypography.subheadline)
                                    .foregroundColor(BrandColors.secondaryText)
                                Spacer()
                                Text("\(Int((Double(currentQuestionIndex + 1) / 5.0) * 100))%")
                                    .font(BrandTypography.subheadline)
                                    .foregroundColor(BrandColors.actionAccent) // Purple
                            }
                            
                            GeometryReader { geometry in
                                ZStack(alignment: .leading) {
                                    // Track
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(BrandColors.surface) // #1C1C1E
                                        .frame(height: 6)
                                    
                                    // Progress fill
                                    RoundedRectangle(cornerRadius: 4)
                                        .fill(BrandColors.actionAccent) // Purple #8B5CF6
                                        .frame(width: geometry.size.width * CGFloat(currentQuestionIndex + 1) / 5.0, height: 6)
                                }
                            }
                            .frame(height: 6)
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.top, BrandSpacing.lg)
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                        
                        if let question = currentQuestion {
                            VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                                // Question card - Dark charcoal, no shadow
                                VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                    Text(question.question)
                                        .font(BrandTypography.title)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                        .lineSpacing(4)
                                }
                                .padding(BrandSpacing.lg)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(BrandColors.surface) // #1C1C1E
                                )
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                
                                // Example answer card - Dark charcoal, yellow icon, white text
                                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                    HStack(spacing: BrandSpacing.sm) {
                                        Image(systemName: "lightbulb.fill")
                                            .foregroundColor(BrandColors.brandAccent) // Golden yellow #FFC107
                                            .font(.system(size: 16))
                                        Text("範例答案")
                                            .font(BrandTypography.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(BrandColors.primaryText) // Pure white
                                    }
                                    
                                    Text(question.exampleAnswer)
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                        .lineSpacing(4)
                                        .padding(BrandSpacing.lg)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                }
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                
                                // User answer field - Dark charcoal, thin border, placeholder #8E8E93
                                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                    HStack(spacing: BrandSpacing.sm) {
                                        Image(systemName: "pencil.and.outline")
                                            .foregroundColor(BrandColors.actionAccent) // Purple
                                            .font(.system(size: 16))
                                        Text("您的答案")
                                            .font(BrandTypography.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(BrandColors.primaryText) // Pure white
                                    }
                                    
                                    ZStack(alignment: .topLeading) {
                                        // Background with border (Theme-aware)
                                        RoundedRectangle(cornerRadius: 12)
                                            .fill(
                                                ThemeManager.shared.isDarkMode 
                                                    ? BrandColors.surface
                                                    : BrandColors.dayModeInputBackground
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .stroke(
                                                        isAnswerFocused 
                                                            ? BrandColors.actionAccent.opacity(0.5) 
                                                            : BrandColors.borderColor,
                                                        lineWidth: 1
                                                    )
                                            )
                                            .frame(minHeight: 120)
                                        
                                        // Placeholder
                                        if (currentResponse?.userAnswer ?? "").isEmpty {
                                            Text("請參考範例答案，寫下您的答案")
                                                .font(BrandTypography.body)
                                                .foregroundColor(BrandColors.secondaryText)
                                                .padding(BrandSpacing.md)
                                                .allowsHitTesting(false)
                                        }
                                        
                                        TextEditor(text: Binding(
                                            get: { currentResponse?.userAnswer ?? "" },
                                            set: { newValue in
                                                if let index = viewModel.strengths.firstIndex(where: { $0.questionId == question.id }) {
                                                    viewModel.strengths[index].userAnswer = newValue.isEmpty ? nil : newValue
                                                }
                                            }
                                        ))
                                        .font(BrandTypography.body)
                                        .foregroundColor(BrandColors.primaryText)
                                        .focused($isAnswerFocused)
                                        .scrollContentBackground(.hidden)
                                        .padding(BrandSpacing.md)
                                        .frame(minHeight: 120)
                                    }
                                }
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                
                                // Hints card - Dark charcoal, purple icon, white text
                                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                    HStack(spacing: BrandSpacing.sm) {
                                        Image(systemName: "info.circle.fill")
                                            .foregroundColor(BrandColors.actionAccent) // Purple #8B5CF6
                                            .font(.system(size: 16))
                                        Text("提示")
                                            .font(BrandTypography.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(BrandColors.primaryText) // Pure white
                                    }
                                    
                                    VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                                        ForEach(question.hints, id: \.self) { hint in
                                            HStack(alignment: .top, spacing: BrandSpacing.sm) {
                                                Circle()
                                                    .fill(BrandColors.actionAccent.opacity(0.5)) // Purple dot
                                                    .frame(width: 6, height: 6)
                                                    .padding(.top, 6)
                                                Text(hint)
                                                    .font(BrandTypography.body)
                                                    .foregroundColor(BrandColors.primaryText) // Pure white
                                                    .lineSpacing(2)
                                            }
                                        }
                                    }
                                    .padding(BrandSpacing.lg)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .background(
                                        RoundedRectangle(cornerRadius: 16)
                                            .fill(BrandColors.surface) // #1C1C1E
                                    )
                                }
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                
                                // Keywords selection section
                                VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                    HStack(spacing: BrandSpacing.sm) {
                                        Image(systemName: "tag.fill")
                                            .foregroundColor(BrandColors.actionAccent) // Purple
                                            .font(.system(size: 16))
                                        Text("選擇最接近的關鍵詞")
                                            .font(BrandTypography.subheadline)
                                            .fontWeight(.semibold)
                                            .foregroundColor(BrandColors.primaryText) // Pure white
                                    }
                                    
                                    // Instruction for hierarchical selection
                                    if let response = currentResponse {
                                        let firstLevelKeywords = Array(question.keywordHierarchy.keys)
                                        let selectedFirstLevel = response.selectedKeywords.filter { firstLevelKeywords.contains($0) }
                                        
                                        if selectedFirstLevel.isEmpty {
                                            HStack(spacing: BrandSpacing.sm) {
                                                Image(systemName: "info.circle")
                                                    .foregroundColor(BrandColors.actionAccent) // Purple
                                                    .font(.system(size: 14))
                                                Text("請先選擇第一層關鍵詞，我們會根據您的選擇顯示相關詞語")
                                                    .font(BrandTypography.caption)
                                                    .foregroundColor(BrandColors.secondaryText)
                                            }
                                            .padding(BrandSpacing.md)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(BrandColors.surface) // #1C1C1E
                                            )
                                        } else {
                                            HStack(spacing: BrandSpacing.sm) {
                                                Image(systemName: "checkmark.circle.fill")
                                                    .foregroundColor(BrandColors.brandAccent) // Golden yellow
                                                    .font(.system(size: 14))
                                                Text("已選擇第一層關鍵詞，以下是相關的關鍵詞：")
                                                    .font(BrandTypography.caption)
                                                    .foregroundColor(BrandColors.secondaryText)
                                            }
                                            .padding(BrandSpacing.md)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 12)
                                                    .fill(BrandColors.surface) // #1C1C1E
                                            )
                                        }
                                    }
                                    
                                    // Keywords grid - spacing: 12
                                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                        ForEach(viewModel.getAvailableKeywords(for: question.id), id: \.self) { keyword in
                                            let isSelected = currentResponse?.selectedKeywords.contains(keyword) ?? false
                                            let firstLevelKeywords = Array(question.keywordHierarchy.keys)
                                            let isFirstLevel = firstLevelKeywords.contains(keyword)
                                            
                                            KeywordChip(
                                                keyword: keyword,
                                                isSelected: isSelected,
                                                isFirstLevel: isFirstLevel,
                                                action: {
                                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                                        if isSelected {
                                                            viewModel.removeStrengthKeyword(keyword, from: question.id)
                                                        } else {
                                                            viewModel.selectStrengthKeyword(keyword, for: question.id)
                                                        }
                                                    }
                                                }
                                            )
                                        }
                                    }
                                    
                                    // Selected keywords tracker - Floating block
                                    if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                            Text("已選擇：\(response.selectedKeywords.count)個")
                                                .font(BrandTypography.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(BrandColors.secondaryText)
                                            
                                            ScrollView(.horizontal, showsIndicators: false) {
                                                HStack(spacing: BrandSpacing.sm) {
                                                    ForEach(response.selectedKeywords, id: \.self) { keyword in
                                                        SelectedKeywordChip(keyword: keyword)
                                                    }
                                                }
                                                .padding(.horizontal, BrandSpacing.xs)
                                            }
                                        }
                                        .padding(BrandSpacing.lg)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 16)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                    }
                                }
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                                
                                // Bottom spacing for fixed navigation
                                Spacer()
                                    .frame(height: 100)
                            }
                        }
                    }
                    .frame(maxWidth: .infinity)
                }
                
                // Fixed Bottom Navigation Bar - Pure black background, NO gradient
                VStack(spacing: 0) {
                    Divider()
                        .background(BrandColors.borderColor)
                    
                    HStack(spacing: BrandSpacing.md) {
                        // Previous button - Text button style
                        if currentQuestionIndex > 0 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentQuestionIndex -= 1
                                }
                            }) {
                                HStack(spacing: BrandSpacing.xs) {
                                    Image(systemName: "arrow.left")
                                        .font(.system(size: 14, weight: .medium))
                                    Text("上一題")
                                        .font(BrandTypography.subheadline)
                                }
                                .foregroundColor(BrandColors.secondaryText)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Spacer()
                        
                        // Next button - Primary action (Theme-aware)
                        Button(action: {
                            if currentQuestionIndex < 4 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentQuestionIndex += 1
                                }
                            } else {
                                viewModel.moveToNextStep()
                            }
                        }) {
                            HStack(spacing: BrandSpacing.sm) {
                                Text(currentQuestionIndex < 4 ? "下一題" : "完成")
                                    .font(BrandTypography.headline)
                                    .fontWeight(.bold)
                                Image(systemName: "arrow.right")
                                    .font(.system(size: 16, weight: .bold))
                            }
                            .foregroundColor(BrandColors.invertedText)
                            .frame(height: 50)
                            .padding(.horizontal, BrandSpacing.xl)
                            .background(
                                ThemeManager.shared.isDarkMode 
                                    ? BrandColors.primaryText
                                    : BrandColors.actionAccent
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: BrandColors.buttonShadow.color,
                                radius: BrandColors.buttonShadow.radius,
                                x: BrandColors.buttonShadow.x,
                                y: BrandColors.buttonShadow.y
                            )
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .padding(.vertical, BrandSpacing.md)
                    .background(BrandColors.background) // Pure black background
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
            }
        }
        .preferredColorScheme(ThemeManager.shared.isDarkMode ? .dark : .light)
    }
}

// MARK: - Keyword Chip Component (Theme-Aware)
struct KeywordChip: View {
    let keyword: String
    let isSelected: Bool
    var isFirstLevel: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            HStack(spacing: BrandSpacing.xs) {
                Text(keyword)
                    .font(BrandTypography.subheadline)
                    .fontWeight(isSelected ? .semibold : .medium)
                
                if isFirstLevel {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(
                            isSelected 
                                ? BrandColors.brandAccent // Golden yellow (dark) or Dawn gold (day)
                                : BrandColors.secondaryText // Light gray
                        )
                }
            }
            .foregroundColor(
                isSelected 
                    ? BrandColors.invertedText // White text when selected
                    : BrandColors.primaryText // Theme-aware text when unselected
            )
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            .background(
                Group {
                    if isSelected {
                        // Selected: Purple background
                        BrandColors.actionAccent
                    } else {
                        // Unselected: Theme-aware background
                        ThemeManager.shared.isDarkMode 
                            ? BrandColors.surface // Dark charcoal in dark mode
                            : BrandColors.surface // Pure white in day mode
                    }
                }
            )
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.large)
                    .stroke(
                        isSelected 
                            ? Color.clear 
                            : BrandColors.borderColor, // Theme-aware border
                        lineWidth: isSelected ? 0 : 1
                    )
            )
            .cornerRadius(BrandRadius.large)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Selected Keyword Chip (For tracker)
struct SelectedKeywordChip: View {
    let keyword: String
    
    var body: some View {
        HStack(spacing: BrandSpacing.xs) {
            Text(keyword)
                .font(BrandTypography.caption)
                .fontWeight(.semibold)
            Image(systemName: "checkmark.circle.fill")
                .font(.caption2)
        }
        .foregroundColor(BrandColors.invertedText) // White text (was primaryText, but invertedText ensures white in both themes)
        .padding(.horizontal, BrandSpacing.md)
        .padding(.vertical, BrandSpacing.xs)
        .background(BrandColors.actionAccent) // Purple background (selected state)
        .cornerRadius(BrandRadius.large)
        // NO shadow - clean and flat
    }
}

#Preview {
    StrengthsQuestionnaireView()
        .environmentObject(InitialScanViewModel())
}
