import SwiftUI

struct DeepeningExplorationView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("深化探索")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 32)
                    
                    Text("完成以下練習以獲得完整的個人化計劃")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 16) {
                        NavigationLink(destination: FlowDiaryView()) {
                            ExplorationStepCard(
                                title: "心流日記",
                                description: "記錄3個心流事件",
                                isCompleted: (dataService.userProfile?.flowDiaryEntries.filter { !$0.activity.isEmpty }.count ?? 0) >= 3,
                                isUnlocked: true
                            )
                        }
                        .buttonStyle(.plain)
                        
                        NavigationLink(destination: ValuesQuestionsView()) {
                            ExplorationStepCard(
                                title: "價值觀問題",
                                description: "回答深度價值觀探索問題",
                                isCompleted: dataService.userProfile?.valuesQuestions != nil,
                                isUnlocked: (dataService.userProfile?.flowDiaryEntries.filter { !$0.activity.isEmpty }.count ?? 0) >= 3
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled((dataService.userProfile?.flowDiaryEntries.filter { !$0.activity.isEmpty }.count ?? 0) < 3)
                        
                        NavigationLink(destination: ResourceInventoryView()) {
                            ExplorationStepCard(
                                title: "資源盤點",
                                description: "盤點時間、金錢、物品、人脈四大資源",
                                isCompleted: dataService.userProfile?.resourceInventory != nil,
                                isUnlocked: dataService.userProfile?.valuesQuestions != nil
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(dataService.userProfile?.valuesQuestions == nil)
                        
                        NavigationLink(destination: AcquiredStrengthsView()) {
                            ExplorationStepCard(
                                title: "後天強項",
                                description: "分析經驗、知識、技能、實績",
                                isCompleted: dataService.userProfile?.acquiredStrengths != nil,
                                isUnlocked: dataService.userProfile?.resourceInventory != nil
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(dataService.userProfile?.resourceInventory == nil)
                        
                        NavigationLink(destination: FeasibilityAssessmentView()) {
                            ExplorationStepCard(
                                title: "可行性評估",
                                description: "6大行動路徑評估",
                                isCompleted: dataService.userProfile?.feasibilityAssessment != nil,
                                isUnlocked: dataService.userProfile?.acquiredStrengths != nil
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(dataService.userProfile?.acquiredStrengths == nil)
                    }
                    .padding(.horizontal, 20)
                    
                    // Generate Action Plan button
                    if let profile = dataService.userProfile,
                       profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count >= 3,
                       profile.valuesQuestions != nil,
                       profile.resourceInventory != nil,
                       profile.acquiredStrengths != nil,
                       profile.feasibilityAssessment != nil,
                       profile.actionPlan == nil {
                        Button(action: {
                            generateActionPlan()
                        }) {
                            HStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "sparkles")
                                Text("生成行動計劃")
                            }
                            .font(BrandTypography.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, BrandSpacing.lg)
                            .background(
                                LinearGradient(
                                    colors: [BrandColors.success, BrandColors.success.opacity(0.8)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(BrandRadius.medium)
                            .shadow(color: BrandColors.success.opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, BrandSpacing.xl)
                    }
                }
                .padding(.bottom, 32)
            }
            .navigationTitle("深化探索")
        }
    }
    
    private func generateActionPlan() {
        guard let profile = dataService.userProfile else { return }
        
        Task {
            do {
                let plan = try await AIService.shared.generateActionPlan(profile: profile)
                await MainActor.run {
                    DataService.shared.updateUserProfile { profile in
                        profile.actionPlan = plan
                    }
                }
            } catch {
                print("Failed to generate action plan: \(error)")
            }
        }
    }
}

struct ExplorationStepCard: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else if isUnlocked {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    DeepeningExplorationView()
        .environmentObject(DataService.shared)
}
