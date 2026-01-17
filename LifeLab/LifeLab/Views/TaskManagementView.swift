import SwiftUI

struct TaskManagementView: View {
    @EnvironmentObject var dataService: DataService
    @State private var selectedTab = 0
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("今日任務").tag(0)
                    Text("所有任務").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                
                if let actionPlan = dataService.userProfile?.actionPlan {
                    ScrollView {
                        VStack(spacing: 24) {
                            if selectedTab == 0 {
                                TaskSection(title: "短期目標（1-3個月）", items: actionPlan.shortTerm)
                            } else {
                                TaskSection(title: "短期目標（1-3個月）", items: actionPlan.shortTerm)
                                TaskSection(title: "中期目標（3-6個月）", items: actionPlan.midTerm)
                                TaskSection(title: "長期目標（6-12個月）", items: actionPlan.longTerm)
                                
                                if !actionPlan.milestones.isEmpty {
                                    VStack(alignment: .leading, spacing: 16) {
                                        Text("關鍵里程碑")
                                            .font(.title2)
                                            .fontWeight(.semibold)
                                        
                                        ForEach(actionPlan.milestones) { milestone in
                                            MilestoneCard(milestone: milestone)
                                        }
                                    }
                                    .padding()
                                }
                            }
                        }
                        .padding(.vertical)
                    }
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "checklist")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("尚未生成行動計劃")
                            .font(.headline)
                            .foregroundColor(.secondary)
                        Text("完成深化探索後，AI將為您生成個人化行動計劃")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
            .navigationTitle("任務管理")
        }
    }
}

struct TaskSection: View {
    let title: String
    let items: [ActionItem]
    var isEditing: Bool = false
    var onUpdate: (([ActionItem]) -> Void)? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            ForEach(items) { item in
                TaskCard(item: item)
                    .padding(.horizontal, 20)
            }
        }
    }
}

struct TaskCard: View {
    @EnvironmentObject var dataService: DataService
    let item: ActionItem
    
    var body: some View {
        HStack(spacing: BrandSpacing.md) {
            Button(action: {
                toggleTaskCompletion(item)
            }) {
                Image(systemName: item.isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(item.isCompleted ? BrandColors.success : BrandColors.tertiaryText)
                    .font(.title3)
            }
            .buttonStyle(.plain)
            
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text(item.title)
                    .font(BrandTypography.headline)
                    .foregroundColor(BrandColors.primaryText)
                    .strikethrough(item.isCompleted)
                Text(item.description)
                    .font(BrandTypography.subheadline)
                    .foregroundColor(BrandColors.secondaryText)
                if let dueDate = item.dueDate {
                    HStack(spacing: BrandSpacing.xs) {
                        Image(systemName: "calendar")
                            .font(.caption2)
                        Text("截止日期：\(dueDate.formatted(date: .abbreviated, time: .omitted))")
                            .font(BrandTypography.caption)
                    }
                    .foregroundColor(BrandColors.secondaryText)
                }
            }
            
            Spacer()
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
    }
    
    private func toggleTaskCompletion(_ item: ActionItem) {
        DataService.shared.updateUserProfile { profile in
            guard var actionPlan = profile.actionPlan else { return }
            
            // Find and toggle in shortTerm
            if let index = actionPlan.shortTerm.firstIndex(where: { $0.id == item.id }) {
                actionPlan.shortTerm[index].isCompleted.toggle()
            }
            // Find and toggle in midTerm
            else if let index = actionPlan.midTerm.firstIndex(where: { $0.id == item.id }) {
                actionPlan.midTerm[index].isCompleted.toggle()
            }
            // Find and toggle in longTerm
            else if let index = actionPlan.longTerm.firstIndex(where: { $0.id == item.id }) {
                actionPlan.longTerm[index].isCompleted.toggle()
            }
            
            profile.actionPlan = actionPlan
        }
    }
}

struct MilestoneCard: View {
    @EnvironmentObject var dataService: DataService
    let milestone: Milestone
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(milestone.title)
                    .font(.headline)
                Spacer()
                Button(action: {
                    toggleMilestoneCompletion(milestone)
                }) {
                    Image(systemName: milestone.isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundColor(milestone.isCompleted ? .green : .gray)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(milestone.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
            
            if let targetDate = milestone.targetDate {
                Text("目標日期：\(targetDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            
            if !milestone.successIndicators.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("成功指標：")
                        .font(.caption)
                        .fontWeight(.semibold)
                    ForEach(milestone.successIndicators, id: \.self) { indicator in
                        HStack(spacing: 4) {
                            Text("•")
                            Text(indicator)
                                .font(.caption)
                        }
                        .foregroundColor(.secondary)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
    
    private func toggleMilestoneCompletion(_ milestone: Milestone) {
        DataService.shared.updateUserProfile { profile in
            guard var actionPlan = profile.actionPlan else { return }
            
            if let index = actionPlan.milestones.firstIndex(where: { $0.id == milestone.id }) {
                actionPlan.milestones[index].isCompleted.toggle()
                profile.actionPlan = actionPlan
            }
        }
    }
}

#Preview {
    TaskManagementView()
        .environmentObject(DataService.shared)
}
