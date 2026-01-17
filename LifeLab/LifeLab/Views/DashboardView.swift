import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataService: DataService
    
    private func calculateInitialScanProgress() -> Double {
        guard let profile = dataService.userProfile else { return 0.0 }
        var steps = 0.0
        if !profile.interests.isEmpty { steps += 1 }
        if !profile.strengths.isEmpty { steps += 1 }
        if !profile.values.isEmpty { steps += 1 }
        if profile.lifeBlueprint != nil { steps += 1 }
        return steps / 4.0
    }
    
    private func calculateDeepeningProgress() -> Double {
        guard let profile = dataService.userProfile else { return 0.0 }
        var steps = 0.0
        let totalSteps = 5.0
        
        if profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count == 3 { steps += 1 }
        if profile.valuesQuestions != nil { steps += 1 }
        if profile.resourceInventory != nil { steps += 1 }
        if profile.acquiredStrengths != nil { steps += 1 }
        if profile.feasibilityAssessment != nil { steps += 1 }
        
        return steps / totalSteps
    }
    
    private func isDeepeningExplorationComplete() -> Bool {
        guard let profile = dataService.userProfile else { return false }
        return profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count == 3 &&
               profile.valuesQuestions != nil &&
               profile.resourceInventory != nil &&
               profile.acquiredStrengths != nil &&
               profile.feasibilityAssessment != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BrandSpacing.xxl) {
                    // Header with gradient
                    VStack(spacing: BrandSpacing.sm) {
                        Text("歡迎回來")
                            .font(BrandTypography.title)
                            .foregroundColor(BrandColors.primaryText)
                        
                        Text("繼續您的天職探索之旅")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.xl)
                    .background(BrandColors.primaryGradient.opacity(0.1))
                    
                    if let blueprint = dataService.userProfile?.lifeBlueprint {
                        VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(BrandColors.primaryBlue)
                                Text("您的生命藍圖")
                                    .font(BrandTypography.title2)
                                    .foregroundColor(BrandColors.primaryText)
                            }
                            
                            ForEach(blueprint.vocationDirections.prefix(2)) { direction in
                                VocationDirectionCard(direction: direction)
                            }
                        }
                        .brandCard()
                        .padding(.horizontal, BrandSpacing.lg)
                    }
                    
                    VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                        HStack {
                            Text("進度")
                                .font(BrandTypography.title2)
                                .foregroundColor(BrandColors.primaryText)
                            
                            Spacer()
                            
                            if dataService.userProfile?.lifeBlueprint != nil {
                                NavigationLink(destination: ReviewInitialScanView()) {
                                    HStack(spacing: BrandSpacing.xs) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("重新檢視")
                                    }
                                    .font(BrandTypography.subheadline)
                                    .foregroundColor(BrandColors.primaryBlue)
                                }
                            }
                        }
                        
                        ProgressCard(
                            title: "初步掃描",
                            isCompleted: dataService.userProfile?.lifeBlueprint != nil,
                            progress: calculateInitialScanProgress()
                        )
                        
                        ProgressCard(
                            title: "深化探索",
                            isCompleted: isDeepeningExplorationComplete(),
                            progress: calculateDeepeningProgress()
                        )
                        
                        if dataService.userProfile?.actionPlan != nil {
                            NavigationLink(destination: ActionPlanReviewView()) {
                                ProgressCard(
                                    title: "行動計劃",
                                    isCompleted: true,
                                    progress: 1.0
                                )
                            }
                            .buttonStyle(.plain)
                        } else {
                            ProgressCard(
                                title: "行動計劃",
                                isCompleted: false,
                                progress: 0.0
                            )
                        }
                    }
                    .brandCard()
                    .padding(.horizontal, BrandSpacing.lg)
                }
                .padding(.vertical, BrandSpacing.lg)
            }
            .background(BrandColors.background)
            .navigationTitle("首頁")
        }
    }
}

struct ProgressCard: View {
    let title: String
    let isCompleted: Bool
    let progress: Double
    
    init(title: String, isCompleted: Bool, progress: Double = 0.0) {
        self.title = title
        self.isCompleted = isCompleted
        self.progress = progress
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            HStack {
                Text(title)
                    .font(BrandTypography.headline)
                    .foregroundColor(BrandColors.primaryText)
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? BrandColors.success : BrandColors.tertiaryText)
                    .font(.title3)
            }
            
            if progress > 0 && !isCompleted {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: BrandRadius.small)
                            .fill(BrandColors.tertiaryBackground)
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: BrandRadius.small)
                            .fill(BrandColors.primaryGradient)
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
                
                Text("\(Int(progress * 100))% 完成")
                    .font(BrandTypography.caption)
                    .foregroundColor(BrandColors.secondaryText)
            }
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataService.shared)
}
