import SwiftUI

struct AcquiredStrengthsView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = AcquiredStrengthsViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("後天強項")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("分析您的經驗、知識、技能、實績")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    
                    // Strength categories
                    VStack(spacing: 16) {
                        StrengthCategoryCard(
                            icon: "book.fill",
                            title: "經驗",
                            color: .blue,
                            description: "您過往的工作和生活經驗",
                            text: Binding(
                                get: { viewModel.strengths.experience ?? "" },
                                set: { viewModel.strengths.experience = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：5年產品設計經驗、創業失敗經驗..."
                        )
                        
                        StrengthCategoryCard(
                            icon: "brain.head.profile",
                            title: "知識",
                            color: .purple,
                            description: "您掌握的專業知識和理論",
                            text: Binding(
                                get: { viewModel.strengths.knowledge ?? "" },
                                set: { viewModel.strengths.knowledge = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：UX設計理論、市場營銷知識..."
                        )
                        
                        StrengthCategoryCard(
                            icon: "wrench.and.screwdriver.fill",
                            title: "技能",
                            color: .orange,
                            description: "您具備的實際操作技能",
                            text: Binding(
                                get: { viewModel.strengths.skills ?? "" },
                                set: { viewModel.strengths.skills = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：Figma、程式設計、影片剪輯..."
                        )
                        
                        StrengthCategoryCard(
                            icon: "trophy.fill",
                            title: "實績",
                            color: .yellow,
                            description: "您過往的成就和作品",
                            text: Binding(
                                get: { viewModel.strengths.achievements ?? "" },
                                set: { viewModel.strengths.achievements = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：獲獎作品、成功專案、客戶好評..."
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    // Complete button
                    if viewModel.isComplete {
                        Button(action: {
                            viewModel.completeAcquiredStrengths()
                            dismiss()
                        }) {
                            Text("完成後天強項分析")
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
            .navigationTitle("後天強項")
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

struct StrengthCategoryCard: View {
    let icon: String
    let title: String
    let color: Color
    let description: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !text.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "10b6cc"))
                }
            }
            
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...8)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    AcquiredStrengthsView()
}
