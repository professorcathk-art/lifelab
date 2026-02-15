import SwiftUI

struct ActionPlanReviewView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var dataService: DataService
    @StateObject private var viewModel = ActionPlanViewModel()
    @State private var isEditing = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                if viewModel.isLoading {
                    ProgressView("正在生成行動計劃...")
                        .padding(.vertical, 60)
                } else if let actionPlan = viewModel.actionPlan {
                    VStack(spacing: 24) {
                        // Header
                        VStack(spacing: 12) {
                            Text("您的行動計劃")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Text("基於您的探索結果，AI為您生成的個人化行動計劃")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, 32)
                        }
                        .padding(.top, 32)
                        
                        // Short Term
                        if !actionPlan.shortTerm.isEmpty {
                            TaskSection(title: "短期目標（1-3個月）", items: actionPlan.shortTerm, sectionType: .shortTerm)
                        }
                        
                        // Mid Term
                        if !actionPlan.midTerm.isEmpty {
                            TaskSection(title: "中期目標（3-6個月）", items: actionPlan.midTerm, sectionType: .midTerm)
                        }
                        
                        // Long Term
                        if !actionPlan.longTerm.isEmpty {
                            TaskSection(title: "長期目標（6-12個月）", items: actionPlan.longTerm, sectionType: .longTerm)
                        }
                        
                        // Milestones
                        if !actionPlan.milestones.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("關鍵里程碑")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, 20)
                                
                                ForEach(actionPlan.milestones) { milestone in
                                    MilestoneCard(milestone: milestone)
                                        .padding(.horizontal, 20)
                                }
                            }
                        }
                    }
                    .padding(.bottom, 32)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "doc.text")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("尚未生成行動計劃")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("完成所有深化探索步驟後，AI將自動為您生成行動計劃")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.top, 100)
                }
            }
            .navigationTitle("行動計劃")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if viewModel.actionPlan != nil {
                        Button(isEditing ? "完成" : "編輯") {
                            isEditing.toggle()
                        }
                    }
                }
            }
        }
        .onAppear {
            viewModel.loadActionPlan()
            viewModel.generateActionPlan()
        }
    }
}

struct ActionPlanEditableTaskCard: View {
    @EnvironmentObject var dataService: DataService
    @Binding var item: ActionItem
    let isEditing: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Button(action: {
                    item.isCompleted.toggle()
                }) {
                    Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(item.isCompleted ? Color(hex: "10b6cc") : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
                
                if isEditing {
                    TextField("標題", text: $item.title)
                        .textFieldStyle(.roundedBorder)
                } else {
                    Text(item.title)
                        .font(.headline)
                        .strikethrough(item.isCompleted)
                }
            }
            
            if isEditing {
                TextField("描述", text: $item.description, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(2...4)
            } else {
                Text(item.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            if let dueDate = item.dueDate {
                Text("截止日期：\(dueDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ActionPlanReviewView()
        .environmentObject(DataService.shared)
}
