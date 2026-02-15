import SwiftUI

struct FeasibilityAssessmentView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FeasibilityAssessmentViewModel()
    
    let pathTitles = [
        "路徑一：直接轉換",
        "路徑二：漸進轉換",
        "路徑三：副業探索",
        "路徑四：學習準備",
        "路徑五：創業冒險",
        "路徑六：自由職業"
    ]
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("可行性評估")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("評估6大行動路徑的可行性")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    
                    // Path assessments
                    VStack(spacing: 16) {
                        ForEach(0..<6) { index in
                            PathAssessmentCard(
                                title: pathTitles[index],
                                description: getPathDescription(index: index),
                                text: Binding(
                                    get: { 
                                        switch index {
                                        case 0: return viewModel.assessment.path1 ?? ""
                                        case 1: return viewModel.assessment.path2 ?? ""
                                        case 2: return viewModel.assessment.path3 ?? ""
                                        case 3: return viewModel.assessment.path4 ?? ""
                                        case 4: return viewModel.assessment.path5 ?? ""
                                        case 5: return viewModel.assessment.path6 ?? ""
                                        default: return ""
                                        }
                                    },
                                    set: { newValue in
                                        let finalValue = newValue.isEmpty ? nil : newValue
                                        switch index {
                                        case 0: viewModel.assessment.path1 = finalValue
                                        case 1: viewModel.assessment.path2 = finalValue
                                        case 2: viewModel.assessment.path3 = finalValue
                                        case 3: viewModel.assessment.path4 = finalValue
                                        case 4: viewModel.assessment.path5 = finalValue
                                        case 5: viewModel.assessment.path6 = finalValue
                                        default: break
                                        }
                                    }
                                ),
                                placeholder: "評估這個路徑的可行性、優勢、挑戰..."
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    // Complete button
                    if viewModel.isComplete {
                        Button(action: {
                            viewModel.completeFeasibilityAssessment()
                            dismiss()
                        }) {
                            Text("完成可行性評估")
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
            .navigationTitle("可行性評估")
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
    
    private func getPathDescription(index: Int) -> String {
        switch index {
        case 0: return "直接從現有工作轉換到目標領域"
        case 1: return "逐步調整工作內容，漸進式轉換"
        case 2: return "保持現有工作，同時發展副業"
        case 3: return "先學習準備，再進行轉換"
        case 4: return "創立自己的事業或專案"
        case 5: return "成為自由職業者或顧問"
        default: return ""
        }
    }
}

struct PathAssessmentCard: View {
    let title: String
    let description: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.headline)
                
                Text(description)
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(4...8)
            
            if !text.isEmpty {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "10b6cc"))
                        .font(.caption)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}


#Preview {
    FeasibilityAssessmentView()
}
