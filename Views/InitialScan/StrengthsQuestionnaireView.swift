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
                    
                    HStack(spacing: 16) {
                        if currentQuestionIndex > 0 {
                            Button(action: {
                                withAnimation {
                                    currentQuestionIndex -= 1
                                }
                            }) {
                                Text("上一題")
                                    .font(.headline)
                                    .foregroundColor(.blue)
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.blue.opacity(0.1))
                                    .cornerRadius(12)
                            }
                        }
                        
                        Button(action: {
                            if currentQuestionIndex < 4 {
                                withAnimation {
                                    currentQuestionIndex += 1
                                }
                            } else {
                                viewModel.moveToNextStep()
                            }
                        }) {
                            Text(currentQuestionIndex < 4 ? "下一題" : "完成")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
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
                .font(.subheadline)
                .foregroundColor(isSelected ? .white : .primary)
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(isSelected ? Color.blue : Color(.systemGray6))
                .cornerRadius(20)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    StrengthsQuestionnaireView()
        .environmentObject(InitialScanViewModel())
}
