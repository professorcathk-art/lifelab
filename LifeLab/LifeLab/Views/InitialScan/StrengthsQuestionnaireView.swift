import SwiftUI

struct StrengthsQuestionnaireView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var currentQuestionIndex = 0
    @FocusState private var isAnswerFocused: Bool
    // Bottom Sheet state for Question 1
    // Bottom Sheet state for Question 1
    @State private var selectedTalentCategory: TalentCategory? = nil
    // Bottom Sheet state for Question 2
    @State private var selectedEnergyCategory: EnergyCategory? = nil
    // Bottom Sheet state for Question 3
    @State private var selectedPraiseCategory: PraiseCategory? = nil
    // Bottom Sheet state for Question 4
    @State private var selectedLearningCategory: LearningCategory? = nil
    // Bottom Sheet state for Question 5
    @State private var selectedFulfillmentCategory: FulfillmentCategory? = nil
    
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
                                // CRITICAL: Questions 1-2 use Bottom Sheet pattern, Questions 3-5 use inline pattern
                                if question.id == 1, let talentCategories = question.talentCategories {
                                    // Question 1: Bottom Sheet Pattern
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
                                        
                                        // Instruction for Bottom Sheet
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "info.circle")
                                                .foregroundColor(BrandColors.actionAccent) // Purple
                                                .font(.system(size: 14))
                                            Text("點擊類別查看子選項，在底部抽屜中選擇您感興趣的項目")
                                                .font(BrandTypography.caption)
                                                .foregroundColor(BrandColors.secondaryText)
                                        }
                                        .padding(BrandSpacing.md)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                        
                                        // Level 1 Talent Categories Grid - Dense 2-3 column grid
                                        let columns = ResponsiveLayout.getGridColumns(minWidth: 140, maxColumns: 3)
                                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                                            ForEach(talentCategories) { category in
                                                TalentCategoryPillButton(
                                                    category: category,
                                                    selectedCount: viewModel.getSelectedTalentCount(for: category.id),
                                                    action: {
                                                        selectedTalentCategory = category
                                                    }
                                                )
                                            }
                                        }
                                        
                                        // Selected Count Summary
                                        if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                                Text("已選擇：\(response.selectedKeywords.count)個")
                                                    .font(BrandTypography.subheadline)
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
                                } else if question.id == 2, let energyCategories = question.energyCategories {
                                    // Question 2: Bottom Sheet Pattern (Energy/Vitality Theme)
                                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "bolt.fill")
                                                .foregroundColor(BrandColors.brandAccent) // Golden yellow for energy
                                                .font(.system(size: 16))
                                            Text("選擇最接近的關鍵詞")
                                                .font(BrandTypography.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(BrandColors.primaryText) // Pure white
                                        }
                                        
                                        // Instruction for Bottom Sheet (Energy theme)
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "sparkles")
                                                .foregroundColor(BrandColors.brandAccent) // Golden yellow
                                                .font(.system(size: 14))
                                            Text("點擊類別查看子選項，在底部抽屜中選擇讓您充滿活力的項目")
                                                .font(BrandTypography.caption)
                                                .foregroundColor(BrandColors.secondaryText)
                                        }
                                        .padding(BrandSpacing.md)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                        
                                        // Level 1 Energy Categories Grid - Dense 2-3 column grid
                                        let columns = ResponsiveLayout.getGridColumns(minWidth: 140, maxColumns: 3)
                                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                                            ForEach(energyCategories) { category in
                                                EnergyCategoryPillButton(
                                                    category: category,
                                                    selectedCount: viewModel.getSelectedEnergyCount(for: category.id),
                                                    action: {
                                                        selectedEnergyCategory = category
                                                    }
                                                )
                                            }
                                        }
                                        
                                        // Selected Count Summary
                                        if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                                Text("已選擇：\(response.selectedKeywords.count)個")
                                                    .font(BrandTypography.subheadline)
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
                                } else if question.id == 3, let praiseCategories = question.praiseCategories {
                                    // Question 3: Bottom Sheet Pattern (Praise/Recognition Theme - Warm Colors)
                                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "heart.fill")
                                                .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.0)) // Amber/Orange for warmth
                                                .font(.system(size: 16))
                                            Text("選擇最接近的關鍵詞")
                                                .font(BrandTypography.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(BrandColors.primaryText) // Pure white
                                        }
                                        
                                        // Instruction for Bottom Sheet (Praise theme - warm)
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(Color(red: 1.0, green: 0.65, blue: 0.0)) // Amber
                                                .font(.system(size: 14))
                                            Text("點擊類別查看子選項，在底部抽屜中選擇別人稱讚你的方面")
                                                .font(BrandTypography.caption)
                                                .foregroundColor(BrandColors.secondaryText)
                                        }
                                        .padding(BrandSpacing.md)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                        
                                        // Level 1 Praise Categories Grid - Dense 2-3 column grid
                                        let columns = ResponsiveLayout.getGridColumns(minWidth: 140, maxColumns: 3)
                                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                                            ForEach(praiseCategories) { category in
                                                PraiseCategoryPillButton(
                                                    category: category,
                                                    selectedCount: viewModel.getSelectedPraiseCount(for: category.id),
                                                    action: {
                                                        selectedPraiseCategory = category
                                                    }
                                                )
                                            }
                                        }
                                        
                                        // Selected Count Summary
                                        if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                                Text("已選擇：\(response.selectedKeywords.count)個")
                                                    .font(BrandTypography.subheadline)
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
                                } else if question.id == 4, let learningCategories = question.learningCategories {
                                    // Question 4: Bottom Sheet Pattern (Fast Learning Theme)
                                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "brain.head.profile")
                                                .foregroundColor(BrandColors.actionAccent) // Purple for learning
                                                .font(.system(size: 16))
                                            Text("選擇最接近的關鍵詞")
                                                .font(BrandTypography.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(BrandColors.primaryText) // Pure white
                                        }
                                        
                                        // Instruction for Bottom Sheet (Learning theme)
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "lightbulb.fill")
                                                .foregroundColor(BrandColors.actionAccent) // Purple
                                                .font(.system(size: 14))
                                            Text("點擊類別查看子選項，在底部抽屜中選擇你學習特別快的項目")
                                                .font(BrandTypography.caption)
                                                .foregroundColor(BrandColors.secondaryText)
                                        }
                                        .padding(BrandSpacing.md)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                        
                                        // Level 1 Learning Categories Grid - Dense 2-3 column grid
                                        let columns = ResponsiveLayout.getGridColumns(minWidth: 140, maxColumns: 3)
                                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                                            ForEach(learningCategories) { category in
                                                LearningCategoryPillButton(
                                                    category: category,
                                                    selectedCount: viewModel.getSelectedLearningCount(for: category.id),
                                                    action: {
                                                        selectedLearningCategory = category
                                                    }
                                                )
                                            }
                                        }
                                        
                                        // Selected Count Summary
                                        if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                                Text("已選擇：\(response.selectedKeywords.count)個")
                                                    .font(BrandTypography.subheadline)
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
                                } else if question.id == 5, let fulfillmentCategories = question.fulfillmentCategories {
                                    // Question 5: Bottom Sheet Pattern (Fulfillment/Meaning Theme - Elegant Colors)
                                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "star.fill")
                                                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Gold for fulfillment
                                                .font(.system(size: 16))
                                            Text("選擇最接近的關鍵詞")
                                                .font(BrandTypography.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(BrandColors.primaryText) // Pure white
                                        }
                                        
                                        // Instruction for Bottom Sheet (Fulfillment theme - elegant)
                                        HStack(spacing: BrandSpacing.sm) {
                                            Image(systemName: "sparkles")
                                                .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0)) // Gold
                                                .font(.system(size: 14))
                                            Text("點擊類別查看子選項，在底部抽屜中選擇讓你感到最有成就感的項目")
                                                .font(BrandTypography.caption)
                                                .foregroundColor(BrandColors.secondaryText)
                                        }
                                        .padding(BrandSpacing.md)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(BrandColors.surface) // #1C1C1E
                                        )
                                        
                                        // Level 1 Fulfillment Categories Grid - Dense 2-3 column grid
                                        let columns = ResponsiveLayout.getGridColumns(minWidth: 140, maxColumns: 3)
                                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                                            ForEach(fulfillmentCategories) { category in
                                                FulfillmentCategoryPillButton(
                                                    category: category,
                                                    selectedCount: viewModel.getSelectedFulfillmentCount(for: category.id),
                                                    action: {
                                                        selectedFulfillmentCategory = category
                                                    }
                                                )
                                            }
                                        }
                                        
                                        // Selected Count Summary
                                        if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                                Text("已選擇：\(response.selectedKeywords.count)個")
                                                    .font(BrandTypography.subheadline)
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
                                } else {
                                    // Fallback: Should not reach here for Questions 1-5
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
                                }
                                
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
                            .foregroundColor(
                                // CRITICAL: Ensure proper contrast
                                // Dark mode: White background → Black text
                                // Light mode: Purple background → White text
                                themeManager.isDarkMode ? Color.black : Color.white
                            )
                            .frame(height: 50)
                            .padding(.horizontal, BrandSpacing.xl)
                            .background(
                                // CRITICAL: Ensure proper contrast
                                // Dark mode: White background
                                // Light mode: Purple background
                                themeManager.isDarkMode ? Color.white : BrandColors.actionAccent
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
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .sheet(item: $selectedTalentCategory) { category in
            // Use currentQuestionIndex + 1 as questionId (since questions are 1-indexed)
            let questionId = currentQuestionIndex + 1 // Questions are 1-indexed
            TalentsBottomSheet(
                category: category,
                questionId: questionId,
                onToggle: { talentId, label in
                    viewModel.toggleTalent(categoryId: category.id, talentId: talentId, label: label, questionId: questionId)
                },
                isSelected: { talentId in
                    viewModel.isTalentSelected(categoryId: category.id, talentId: talentId)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedEnergyCategory) { category in
            // Use currentQuestionIndex + 1 as questionId (since questions are 1-indexed)
            let questionId = currentQuestionIndex + 1 // Questions are 1-indexed
            EnergiesBottomSheet(
                category: category,
                questionId: questionId,
                onToggle: { energyId, label in
                    viewModel.toggleEnergy(categoryId: category.id, energyId: energyId, label: label, questionId: questionId)
                },
                isSelected: { energyId in
                    viewModel.isEnergySelected(categoryId: category.id, energyId: energyId)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedPraiseCategory) { category in
            // Use currentQuestionIndex + 1 as questionId (since questions are 1-indexed)
            let questionId = currentQuestionIndex + 1 // Questions are 1-indexed
            PraisesBottomSheet(
                category: category,
                questionId: questionId,
                onToggle: { praiseId, label in
                    viewModel.togglePraise(categoryId: category.id, praiseId: praiseId, label: label, questionId: questionId)
                },
                isSelected: { praiseId in
                    viewModel.isPraiseSelected(categoryId: category.id, praiseId: praiseId)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedLearningCategory) { category in
            // Use currentQuestionIndex + 1 as questionId (since questions are 1-indexed)
            let questionId = currentQuestionIndex + 1 // Questions are 1-indexed
            LearningsBottomSheet(
                category: category,
                questionId: questionId,
                onToggle: { learningId, label in
                    viewModel.toggleLearning(categoryId: category.id, learningId: learningId, label: label, questionId: questionId)
                },
                isSelected: { learningId in
                    viewModel.isLearningSelected(categoryId: category.id, learningId: learningId)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
        .sheet(item: $selectedFulfillmentCategory) { category in
            // Use currentQuestionIndex + 1 as questionId (since questions are 1-indexed)
            let questionId = currentQuestionIndex + 1 // Questions are 1-indexed
            FulfillmentsBottomSheet(
                category: category,
                questionId: questionId,
                onToggle: { fulfillmentId, label in
                    viewModel.toggleFulfillment(categoryId: category.id, fulfillmentId: fulfillmentId, label: label, questionId: questionId)
                },
                isSelected: { fulfillmentId in
                    viewModel.isFulfillmentSelected(categoryId: category.id, fulfillmentId: fulfillmentId)
                }
            )
            .presentationDetents([.medium, .large])
            .presentationDragIndicator(.visible)
        }
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
        .foregroundColor(Color.white) // CRITICAL: White text on purple background for proper contrast
        .padding(.horizontal, BrandSpacing.md)
        .padding(.vertical, BrandSpacing.xs)
        .background(BrandColors.actionAccent) // Purple background (selected state)
        .cornerRadius(BrandRadius.large)
        // NO shadow - clean and flat
    }
}

// MARK: - Talent Category Pill Button (Level 1) - For Question 1
struct TalentCategoryPillButton: View {
    let category: TalentCategory
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

// MARK: - Talents Bottom Sheet - For Question 1
struct TalentsBottomSheet: View {
    let category: TalentCategory
    let questionId: Int
    let onToggle: (String, String) -> Void
    let isSelected: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // CRITICAL: Ensure background is set immediately to prevent black screen
                BrandColors.background
                    .ignoresSafeArea()
                
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
                    
                    // Sub-talents Grid (3-4 columns for 4-character labels)
                    ScrollView {
                        let columns = ResponsiveLayout.getGridColumns(minWidth: 80, maxColumns: 4)
                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                            ForEach(category.subTalents) { talent in
                                SubTalentPillButton(
                                    talent: talent,
                                    isSelected: isSelected(talent.id),
                                    action: {
                                        onToggle(talent.id, talent.label)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.vertical, BrandSpacing.lg)
                    }
                    
                    Spacer()
                }
            }
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
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - Sub Talent Pill Button (Level 2) - 4-character labels
struct SubTalentPillButton: View {
    let talent: SubTalent
    let isSelected: Bool
    let action: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(talent.label)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.sm)
                .padding(.vertical, BrandSpacing.xs)
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

// MARK: - Energy Category Pill Button (Level 1) - For Question 2 (Energy/Vitality Theme)
struct EnergyCategoryPillButton: View {
    let category: EnergyCategory
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
                        .background(BrandColors.brandAccent) // Golden yellow for energy
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if selectedCount > 0 {
                        // Has selections: Glowing golden border with energy effect
                        BrandColors.surface
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandRadius.large)
                                    .stroke(
                                        BrandColors.brandAccent, // Golden yellow
                                        lineWidth: 2
                                    )
                                    .shadow(color: BrandColors.brandAccent.opacity(0.6), radius: 6) // Stronger glow for energy
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

// MARK: - Energies Bottom Sheet - For Question 2 (Energy/Vitality Theme)
struct EnergiesBottomSheet: View {
    let category: EnergyCategory
    let questionId: Int
    let onToggle: (String, String) -> Void
    let isSelected: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        NavigationStack {
            ZStack {
                // CRITICAL: Ensure background is set immediately to prevent black screen
                BrandColors.background
                    .ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // Header with energy theme
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.sm) {
                            Image(systemName: "bolt.fill")
                                .foregroundColor(BrandColors.brandAccent) // Golden yellow
                                .font(.system(size: 20))
                            Text(category.title)
                                .font(BrandTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(BrandColors.primaryText)
                        }
                        
                        Text("你最享受哪種過程？")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.top, BrandSpacing.lg)
                    .padding(.bottom, BrandSpacing.md)
                    
                    Divider()
                        .background(BrandColors.borderColor)
                    
                    // Sub-energies Grid (3-4 columns for 4-character labels)
                    ScrollView {
                        let columns = ResponsiveLayout.getGridColumns(minWidth: 80, maxColumns: 4)
                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                            ForEach(category.subEnergies) { energy in
                                SubEnergyPillButton(
                                    energy: energy,
                                    isSelected: isSelected(energy.id),
                                    action: {
                                        onToggle(energy.id, energy.label)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.vertical, BrandSpacing.lg)
                    }
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(BrandColors.brandAccent) // Golden yellow for energy theme
                    .font(BrandTypography.headline)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - Sub Energy Pill Button (Level 2) - 4-character labels with Energy Glow Effect
struct SubEnergyPillButton: View {
    let energy: SubEnergy
    let isSelected: Bool
    let action: () -> Void
    
    @ObservedObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(energy.label)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.sm)
                .padding(.vertical, BrandSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isSelected {
                            // Selected: Golden yellow background with glow effect (Energy/Vitality theme)
                            BrandColors.brandAccent // #FFC107
                                .shadow(color: BrandColors.brandAccent.opacity(0.5), radius: 4) // Glow effect
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
                .shadow(
                    color: isSelected ? BrandColors.brandAccent.opacity(0.4) : Color.clear,
                    radius: isSelected ? 6 : 0
                ) // Additional glow shadow when selected
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Praise Category Pill Button (Level 1) - Warm Theme (Amber/Pink)
struct PraiseCategoryPillButton: View {
    let category: PraiseCategory
    let selectedCount: Int
    let action: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Warm color palette for praise theme (Amber/Orange)
    private let warmAccent = Color(red: 1.0, green: 0.65, blue: 0.0) // Amber/Orange
    private let warmPink = Color(red: 1.0, green: 0.5, blue: 0.7) // Subtle pink

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

                // Badge showing selected count (warm accent)
                if selectedCount > 0 {
                    Text("+\(selectedCount)")
                        .font(BrandTypography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.invertedText)
                        .padding(.horizontal, BrandSpacing.xs)
                        .padding(.vertical, 2)
                        .background(warmAccent)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if selectedCount > 0 {
                        // Has selections: Warm glowing border (amber/orange with subtle pink)
                        BrandColors.surface
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandRadius.large)
                                    .stroke(
                                        LinearGradient(
                                            colors: [warmAccent, warmPink],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .shadow(color: warmAccent.opacity(0.6), radius: 6) // Warmer glow
                            )
                    } else {
                        // No selections: Dark charcoal with subtle border
                        BrandColors.surface // #1C1C1E
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
            .scaleEffect(selectedCount > 0 ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Praises Bottom Sheet (Question 3) - Warm Theme
struct PraisesBottomSheet: View {
    let category: PraiseCategory
    let questionId: Int
    let onToggle: (String, String) -> Void
    let isSelected: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Warm color palette for praise theme
    private let warmAccent = Color(red: 1.0, green: 0.65, blue: 0.0) // Amber/Orange
    private let warmPink = Color(red: 1.0, green: 0.5, blue: 0.7) // Subtle pink

    var body: some View {
        NavigationStack {
            ZStack {
                // CRITICAL: Ensure background is set immediately to prevent black screen
                BrandColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with warm praise theme
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.sm) {
                            Image(systemName: "heart.fill")
                                .foregroundColor(warmAccent) // Amber/Orange
                                .font(.system(size: 20))
                            Text(category.title)
                                .font(BrandTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(BrandColors.primaryText)
                        }
                        
                        Text("別人稱讚你的哪些方面？")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.top, BrandSpacing.lg)
                    .padding(.bottom, BrandSpacing.md)

                    Divider()
                        .background(BrandColors.borderColor)

                    // Sub-praises Grid (3-4 columns for 4-character labels)
                    ScrollView {
                        let columns = ResponsiveLayout.getGridColumns(minWidth: 80, maxColumns: 4)
                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                            ForEach(category.subPraises) { praise in
                                SubPraisePillButton(
                                    praise: praise,
                                    isSelected: isSelected(praise.id),
                                    action: {
                                        onToggle(praise.id, praise.label)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.vertical, BrandSpacing.lg)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(warmAccent) // Warm accent color
                    .font(BrandTypography.headline)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - Sub Praise Pill Button (Level 2) - 4-character labels - Warm Theme
struct SubPraisePillButton: View {
    let praise: SubPraise
    let isSelected: Bool
    let action: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Warm color palette for praise theme
    private let warmAccent = Color(red: 1.0, green: 0.65, blue: 0.0) // Amber/Orange
    private let warmPink = Color(red: 1.0, green: 0.5, blue: 0.7) // Subtle pink

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(praise.label)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.sm)
                .padding(.vertical, BrandSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isSelected {
                            // Selected: Warm gradient background (amber to pink) with glow effect
                            LinearGradient(
                                colors: [warmAccent, warmPink],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .shadow(color: warmAccent.opacity(0.6), radius: 6) // Warm glow effect
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
                .shadow(
                    color: isSelected ? warmAccent.opacity(0.5) : Color.clear,
                    radius: isSelected ? 8 : 0
                ) // Additional warm glow shadow when selected
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Learning Category Pill Button (Level 1) - Learning Theme
struct LearningCategoryPillButton: View {
    let category: LearningCategory
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
                        // Has selections: Glowing purple border (Learning theme)
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
                        BrandColors.surface // #1C1C1E
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
            .scaleEffect(selectedCount > 0 ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Learnings Bottom Sheet (Question 4) - Learning Theme
struct LearningsBottomSheet: View {
    let category: LearningCategory
    let questionId: Int
    let onToggle: (String, String) -> Void
    let isSelected: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        NavigationStack {
            ZStack {
                // CRITICAL: Ensure background is set immediately to prevent black screen
                BrandColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with learning theme
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.sm) {
                            Image(systemName: "brain.head.profile")
                                .foregroundColor(BrandColors.actionAccent) // Purple for learning
                                .font(.system(size: 20))
                            Text(category.title)
                                .font(BrandTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(BrandColors.primaryText)
                        }
                        
                        Text("你學習什麼類型的事物特別快？")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.top, BrandSpacing.lg)
                    .padding(.bottom, BrandSpacing.md)

                    Divider()
                        .background(BrandColors.borderColor)

                    // Sub-learnings Grid (3-4 columns for 4-character labels)
                    ScrollView {
                        let columns = ResponsiveLayout.getGridColumns(minWidth: 80, maxColumns: 4)
                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                            ForEach(category.subLearning) { learning in
                                SubLearningPillButton(
                                    learning: learning,
                                    isSelected: isSelected(learning.id),
                                    action: {
                                        onToggle(learning.id, learning.label)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.vertical, BrandSpacing.lg)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(BrandColors.actionAccent) // Purple accent color
                    .font(BrandTypography.headline)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - Sub Learning Pill Button (Level 2) - 4-character labels - Learning Theme
struct SubLearningPillButton: View {
    let learning: SubLearning
    let isSelected: Bool
    let action: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(learning.label)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.sm)
                .padding(.vertical, BrandSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isSelected {
                            // Selected: Purple background with glow effect (Learning theme)
                            BrandColors.actionAccent // Purple
                                .shadow(color: BrandColors.actionAccent.opacity(0.5), radius: 4) // Glow effect
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
                .shadow(
                    color: isSelected ? BrandColors.actionAccent.opacity(0.4) : Color.clear,
                    radius: isSelected ? 6 : 0
                ) // Additional glow shadow when selected
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fulfillment Category Pill Button (Level 1) - Elegant Theme (Gold/Amber/Deep Purple)
struct FulfillmentCategoryPillButton: View {
    let category: FulfillmentCategory
    let selectedCount: Int
    let action: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Elegant color palette for fulfillment theme (Gold/Amber/Deep Purple)
    private let goldAccent = Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
    private let amberAccent = Color(red: 1.0, green: 0.65, blue: 0.0) // Amber
    private let deepPurple = Color(red: 0.5, green: 0.0, blue: 0.5) // Deep Purple

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

                // Badge showing selected count (elegant gold)
                if selectedCount > 0 {
                    Text("+\(selectedCount)")
                        .font(BrandTypography.caption)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.invertedText)
                        .padding(.horizontal, BrandSpacing.xs)
                        .padding(.vertical, 2)
                        .background(goldAccent)
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, BrandSpacing.md)
            .padding(.vertical, BrandSpacing.sm)
            .frame(maxWidth: .infinity)
            .background(
                Group {
                    if selectedCount > 0 {
                        // Has selections: Elegant glowing border (gold/amber gradient with deep purple accent)
                        BrandColors.surface
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandRadius.large)
                                    .stroke(
                                        LinearGradient(
                                            colors: [goldAccent, amberAccent, deepPurple],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        ),
                                        lineWidth: 2
                                    )
                                    .shadow(color: goldAccent.opacity(0.7), radius: 8) // Elegant warm glow
                            )
                    } else {
                        // No selections: Dark charcoal with subtle border
                        BrandColors.surface // #1C1C1E
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
            .scaleEffect(selectedCount > 0 ? 1.02 : 1.0)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Fulfillments Bottom Sheet (Question 5) - Elegant Theme
struct FulfillmentsBottomSheet: View {
    let category: FulfillmentCategory
    let questionId: Int
    let onToggle: (String, String) -> Void
    let isSelected: (String) -> Bool
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Elegant color palette for fulfillment theme
    private let goldAccent = Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
    private let amberAccent = Color(red: 1.0, green: 0.65, blue: 0.0) // Amber
    private let deepPurple = Color(red: 0.5, green: 0.0, blue: 0.5) // Deep Purple

    var body: some View {
        NavigationStack {
            ZStack {
                // CRITICAL: Ensure background is set immediately to prevent black screen
                BrandColors.background
                    .ignoresSafeArea()

                VStack(spacing: 0) {
                    // Header with elegant fulfillment theme
                    VStack(spacing: BrandSpacing.md) {
                        HStack(spacing: BrandSpacing.sm) {
                            Image(systemName: "star.fill")
                                .foregroundColor(goldAccent) // Gold
                                .font(.system(size: 20))
                            Text(category.title)
                                .font(BrandTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(BrandColors.primaryText)
                        }
                        
                        Text("這些經歷有什麼共同特質？")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.top, BrandSpacing.lg)
                    .padding(.bottom, BrandSpacing.md)

                    Divider()
                        .background(BrandColors.borderColor)

                    // Sub-fulfillments Grid (3-4 columns for 4-character labels)
                    ScrollView {
                        let columns = ResponsiveLayout.getGridColumns(minWidth: 80, maxColumns: 4)
                        LazyVGrid(columns: columns, spacing: BrandSpacing.md) {
                            ForEach(category.subFulfillment) { fulfillment in
                                SubFulfillmentPillButton(
                                    fulfillment: fulfillment,
                                    isSelected: isSelected(fulfillment.id),
                                    action: {
                                        onToggle(fulfillment.id, fulfillment.label)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.vertical, BrandSpacing.lg)
                    }

                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(goldAccent) // Elegant gold accent color
                    .font(BrandTypography.headline)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

// MARK: - Sub Fulfillment Pill Button (Level 2) - 4-character labels - Elegant Theme
struct SubFulfillmentPillButton: View {
    let fulfillment: SubFulfillment
    let isSelected: Bool
    let action: () -> Void

    @ObservedObject private var themeManager = ThemeManager.shared
    
    // Elegant color palette for fulfillment theme
    private let goldAccent = Color(red: 1.0, green: 0.84, blue: 0.0) // Gold
    private let amberAccent = Color(red: 1.0, green: 0.65, blue: 0.0) // Amber
    private let deepPurple = Color(red: 0.5, green: 0.0, blue: 0.5) // Deep Purple

    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            Text(fulfillment.label)
                .font(BrandTypography.subheadline)
                .fontWeight(.medium)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.sm)
                .padding(.vertical, BrandSpacing.xs)
                .frame(maxWidth: .infinity)
                .background(
                    Group {
                        if isSelected {
                            // Selected: Elegant gradient background (gold to amber to deep purple) with glow effect
                            LinearGradient(
                                colors: [goldAccent, amberAccent, deepPurple],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                            .shadow(color: goldAccent.opacity(0.7), radius: 8) // Elegant warm glow effect
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
                .shadow(
                    color: isSelected ? goldAccent.opacity(0.6) : Color.clear,
                    radius: isSelected ? 10 : 0
                ) // Additional elegant glow shadow when selected
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StrengthsQuestionnaireView()
        .environmentObject(InitialScanViewModel())
}
