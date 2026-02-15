import SwiftUI

struct ValuesQuestionsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ValuesQuestionsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("價值觀問題")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("回答深度價值觀探索問題，幫助您更深入了解自己")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(Array(0..<viewModel.totalQuestions), id: \.self) { index in
                            Circle()
                                .fill(index < viewModel.answeredQuestions ? Color(hex: "10b6cc") : Color.gray.opacity(0.3))
                                .frame(width: 10, height: 10)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Text("已回答 \(viewModel.answeredQuestions)/\(viewModel.totalQuestions) 題")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Table 1: Quick Questions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("表一：快速探索")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        QuickQuestionCard(
                            title: "您最敬佩的人是誰？",
                            placeholder: "描述這個人的特質和您敬佩的原因",
                            text: Binding(
                                get: { viewModel.valuesQuestions.admiredPeople ?? "" },
                                set: { viewModel.valuesQuestions.admiredPeople = $0.isEmpty ? nil : $0 }
                            )
                        )
                        
                        QuickQuestionCard(
                            title: "您最喜歡的虛構角色是誰？",
                            placeholder: "描述這個角色的特質和吸引您的地方",
                            text: Binding(
                                get: { viewModel.valuesQuestions.favoriteCharacters ?? "" },
                                set: { viewModel.valuesQuestions.favoriteCharacters = $0.isEmpty ? nil : $0 }
                            )
                        )
                        
                        QuickQuestionCard(
                            title: "您希望孩子成為什麼樣的人？",
                            placeholder: "描述您希望培養的特質和價值觀",
                            text: Binding(
                                get: { viewModel.valuesQuestions.idealChild ?? "" },
                                set: { viewModel.valuesQuestions.idealChild = $0.isEmpty ? nil : $0 }
                            )
                        )
                        
                        QuickQuestionCard(
                            title: "您希望留下什麼樣的遺產？",
                            placeholder: "描述您希望被記住的方式",
                            text: Binding(
                                get: { viewModel.valuesQuestions.legacyDescription ?? "" },
                                set: { viewModel.valuesQuestions.legacyDescription = $0.isEmpty ? nil : $0 }
                            )
                        )
                    }
                    .padding(.bottom, 16)
                    
                    // Table 2: Deep Reflection Questions
                    VStack(alignment: .leading, spacing: 16) {
                        Text("表二：深度反思")
                            .font(.headline)
                            .padding(.horizontal, 20)
                        
                        ForEach(viewModel.reflectionAnswers) { answer in
                            ReflectionQuestionCard(
                                question: answer.question,
                                answer: Binding(
                                    get: { answer.answer },
                                    set: { newValue in
                                        if let index = viewModel.reflectionAnswers.firstIndex(where: { $0.id == answer.id }) {
                                            viewModel.reflectionAnswers[index].answer = newValue
                                        }
                                    }
                                ),
                                purpose: ReflectionQuestions.shared.questions.first(where: { $0.id == answer.questionId })?.purpose ?? "",
                                example: ReflectionQuestions.shared.questions.first(where: { $0.id == answer.questionId })?.exampleAnswer ?? ""
                            )
                        }
                    }
                    .padding(.bottom, 32)
                    
                    // Complete button
                    if viewModel.isComplete {
                        Button(action: {
                            viewModel.completeValuesQuestions()
                            dismiss()
                        }) {
                            Text("完成價值觀問題")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "10b6cc"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("價值觀問題")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        viewModel.saveProgress()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct QuickQuestionCard: View {
    let title: String
    let placeholder: String
    @Binding var text: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.subheadline)
                .fontWeight(.semibold)
                .foregroundColor(.primary)
            
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

struct ReflectionQuestionCard: View {
    let question: String
    @Binding var answer: String
    let purpose: String
    let example: String
    
    @State private var showExample = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question)
                .font(.body)
                .fontWeight(.medium)
            
            Text(purpose)
                .font(.caption)
                .foregroundColor(.secondary)
                .italic()
            
            TextField("請詳細回答這個問題...", text: $answer, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(5...10)
            
            Button(action: {
                showExample.toggle()
            }) {
                HStack {
                    Text(showExample ? "隱藏範例" : "查看範例答案")
                        .font(.caption)
                    Image(systemName: showExample ? "chevron.up" : "chevron.down")
                        .font(.caption)
                }
                .foregroundColor(.blue)
            }
            
            if showExample {
                VStack(alignment: .leading, spacing: 4) {
                    Text("範例：")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                    Text(example)
                        .font(.caption)
                        .foregroundColor(.secondary)
                        .padding(8)
                        .background(Color(.systemGray5))
                        .cornerRadius(8)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .padding(.horizontal, 20)
    }
}

#Preview {
    ValuesQuestionsView()
}
