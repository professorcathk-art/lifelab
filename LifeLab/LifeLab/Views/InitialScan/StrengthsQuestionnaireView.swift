import SwiftUI

struct StrengthsQuestionnaireView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var currentQuestionIndex = 0
    
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
        ScrollView {
            VStack(spacing: 24) {
                if let question = currentQuestion {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("問題 \(currentQuestionIndex + 1)/5")
                            .font(.caption)
                            .foregroundColor(.secondary)
                        
                        Text(question.question)
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("範例答案：")
                                .font(.headline)
                            Text(question.exampleAnswer)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .padding()
                                .background(Color(.systemGray6))
                                .cornerRadius(8)
                            
                            Text("您的答案：")
                                .font(.headline)
                                .padding(.top, 8)
                            
                            TextField("請參考範例答案，寫下您的答案", text: Binding(
                                get: { currentResponse?.userAnswer ?? "" },
                                set: { newValue in
                                    if let index = viewModel.strengths.firstIndex(where: { $0.questionId == question.id }) {
                                        viewModel.strengths[index].userAnswer = newValue.isEmpty ? nil : newValue
                                    }
                                }
                            ), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...8)
                            .autocorrectionDisabled(false)
                            .textInputAutocapitalization(.sentences)
                            .keyboardType(.default)
                            .padding(.top, 4)
                        }
                        
                        VStack(alignment: .leading, spacing: 8) {
                            Text("提示：")
                                .font(.headline)
                            ForEach(question.hints, id: \.self) { hint in
                                HStack(alignment: .top, spacing: 8) {
                                    Text("•")
                                    Text(hint)
                                        .font(.subheadline)
                                }
                                .foregroundColor(.secondary)
                            }
                        }
                        
                        Divider()
                        
                        VStack(alignment: .leading, spacing: 12) {
                            Text("選擇最接近的關鍵詞：")
                                .font(.headline)
                            
                            // Show instruction for hierarchical selection
                            if let response = currentResponse {
                                let firstLevelKeywords = Array(question.keywordHierarchy.keys)
                                let selectedFirstLevel = response.selectedKeywords.filter { firstLevelKeywords.contains($0) }
                                
                                if selectedFirstLevel.isEmpty {
                                    Text("請先選擇第一層關鍵詞，我們會根據您的選擇顯示相關詞語")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 8)
                                } else {
                                    Text("已選擇第一層關鍵詞，以下是相關的關鍵詞：")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                        .padding(.bottom, 8)
                                }
                            }
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(viewModel.getAvailableKeywords(for: question.id), id: \.self) { keyword in
                                    let isSelected = currentResponse?.selectedKeywords.contains(keyword) ?? false
                                    let firstLevelKeywords = Array(question.keywordHierarchy.keys)
                                    let isFirstLevel = firstLevelKeywords.contains(keyword)
                                    
                                    KeywordSelectionButton(
                                        keyword: keyword,
                                        isSelected: isSelected,
                                        isFirstLevel: isFirstLevel,
                                        action: {
                                            if isSelected {
                                                viewModel.removeStrengthKeyword(keyword, from: question.id)
                                            } else {
                                                viewModel.selectStrengthKeyword(keyword, for: question.id)
                                            }
                                        }
                                    )
                                }
                            }
                            
                            if let response = currentResponse, !response.selectedKeywords.isEmpty {
                                VStack(alignment: .leading, spacing: 8) {
                                    Text("已選擇：")
                                        .font(.subheadline)
                                        .foregroundColor(.secondary)
                                    
                                    ScrollView(.horizontal, showsIndicators: false) {
                                        HStack(spacing: 8) {
                                            ForEach(response.selectedKeywords, id: \.self) { keyword in
                                                SelectedKeywordChip(keyword: keyword)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .padding(20)
                    
                    // Next button
                    HStack(spacing: BrandSpacing.md) {
                        if currentQuestionIndex > 0 {
                            Button(action: {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentQuestionIndex -= 1
                                }
                            }) {
                                HStack(spacing: BrandSpacing.xs) {
                                    Image(systemName: "arrow.left")
                                    Text("上一題")
                                }
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BrandSpacing.lg)
                                .background(BrandColors.primaryBlue.opacity(0.1))
                                .cornerRadius(BrandRadius.medium)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        Button(action: {
                            if currentQuestionIndex < 4 {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    currentQuestionIndex += 1
                                }
                            } else {
                                viewModel.moveToNextStep()
                            }
                        }) {
                            HStack(spacing: BrandSpacing.xs) {
                                Text(currentQuestionIndex < 4 ? "下一題" : "完成")
                                Image(systemName: "arrow.right")
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
                    .padding(.bottom, BrandSpacing.xxxl)
                }
            }
        }
    }
}

struct KeywordSelectionButton: View {
    let keyword: String
    let isSelected: Bool
    var isFirstLevel: Bool = false
    let action: () -> Void
    
    // Get a consistent color for each keyword based on its hash
    private var keywordColor: Color {
        let colors: [Color] = [
            Color(hex: "10b6cc"), // Sky blue
            Color(hex: "2B8A8F"), // Teal
            Color(hex: "F5B861"), // Gold
            Color(hex: "FF7B54"), // Coral
            Color(hex: "E8B4FF"), // Purple
            Color(hex: "FF6B6B"), // Pink
            Color(hex: "4CAF50"), // Green
            Color(hex: "00BCD4"), // Cyan
            Color(hex: "8BC34A"), // Light green
            Color(hex: "FFC107"), // Amber
            Color(hex: "FF9800"), // Orange
            Color(hex: "9C27B0"), // Deep purple
        ]
        let index = abs(keyword.hashValue) % colors.count
        return colors[index]
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: BrandSpacing.xs) {
                Text(keyword)
                    .font(BrandTypography.subheadline)
                    .fontWeight(.medium)
                
                if isFirstLevel {
                    Image(systemName: "star.fill")
                        .font(.caption2)
                }
            }
            .foregroundColor(isSelected ? .white : keywordColor)
            .padding(.horizontal, BrandSpacing.lg)
            .padding(.vertical, BrandSpacing.md)
            .background(
                isSelected 
                    ? LinearGradient(colors: [keywordColor, keywordColor.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing)
                    : LinearGradient(colors: [keywordColor.opacity(0.15), keywordColor.opacity(0.1)], startPoint: .topLeading, endPoint: .bottomTrailing)
            )
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.large)
                    .stroke(keywordColor.opacity(isSelected ? 0.5 : (isFirstLevel ? 0.5 : 0.3)), lineWidth: isSelected ? 2 : (isFirstLevel ? 1.5 : 1))
            )
            .cornerRadius(BrandRadius.large)
            .shadow(color: keywordColor.opacity(isSelected ? 0.4 : (isFirstLevel ? 0.3 : 0.2)), 
                   radius: isSelected ? 6 : (isFirstLevel ? 4 : 3), 
                   x: 0, 
                   y: isSelected ? 3 : (isFirstLevel ? 2 : 1))
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StrengthsQuestionnaireView()
        .environmentObject(InitialScanViewModel())
}
