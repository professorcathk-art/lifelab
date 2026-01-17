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
                            
                            LazyVGrid(columns: [GridItem(.adaptive(minimum: 100))], spacing: 12) {
                                ForEach(question.suggestedKeywords, id: \.self) { keyword in
                                    let isSelected = currentResponse?.selectedKeywords.contains(keyword) ?? false
                                    KeywordSelectionButton(
                                        keyword: keyword,
                                        isSelected: isSelected,
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
                    
                    // Navigation handled by progress dots - no buttons needed
                }
            }
        }
    }
}

struct KeywordSelectionButton: View {
    let keyword: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(keyword)
                .font(BrandTypography.subheadline)
                .foregroundColor(isSelected ? .white : BrandColors.primaryText)
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.vertical, BrandSpacing.md)
                .background(isSelected ? BrandColors.primaryBlue : BrandColors.secondaryBackground)
                .cornerRadius(BrandRadius.large)
                .shadow(color: isSelected ? BrandColors.primaryBlue.opacity(0.3) : BrandShadow.small.color, 
                       radius: isSelected ? 4 : BrandShadow.small.radius, 
                       x: 0, 
                       y: isSelected ? 2 : BrandShadow.small.y)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    StrengthsQuestionnaireView()
        .environmentObject(InitialScanViewModel())
}
