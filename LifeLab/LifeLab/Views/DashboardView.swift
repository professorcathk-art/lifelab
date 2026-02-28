import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var themeManager: ThemeManager
    
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
                    // Header - NO gradient, pure black background
                    VStack(spacing: BrandSpacing.sm) {
                        HStack(spacing: BrandSpacing.xs) {
                            Text("歡迎回來")
                                .font(BrandTypography.title)
                                .foregroundColor(BrandColors.primaryText)
                            
                            if let userName = dataService.userProfile?.basicInfo?.name, !userName.isEmpty {
                                Text(userName)
                                    .font(BrandTypography.title)
                                    .foregroundColor(BrandColors.actionAccent)
                            }
                        }
                        
                        Text("繼續您的天職探索之旅")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    .padding(.vertical, BrandSpacing.xl)
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    
                    if let blueprint = dataService.userProfile?.lifeBlueprint {
                        VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                            HStack {
                                Image(systemName: "sparkles")
                                    .foregroundColor(BrandColors.actionAccent) // Purple
                                Text("您的生命藍圖")
                                    .font(BrandTypography.title2)
                                    .foregroundColor(BrandColors.primaryText)
                                
                                Spacer()
                                
                                // Edit button - navigate to blueprint view
                                NavigationLink(destination: LifeBlueprintEditView(blueprint: blueprint)) {
                                    Image(systemName: "pencil")
                                        .font(.title3)
                                        .foregroundColor(BrandColors.actionAccent) // Purple
                                        .padding(BrandSpacing.sm)
                                        .background(BrandColors.actionAccent.opacity(0.1))
                                        .cornerRadius(BrandRadius.small)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Only show favorite direction on homepage
                            if let favoriteDirection = blueprint.vocationDirections.first(where: { $0.isFavorite }) {
                                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                    HStack {
                                        Image(systemName: "star.fill")
                                            .foregroundColor(BrandColors.brandAccent) // Golden yellow
                                        Text("當前行動方向")
                                            .font(BrandTypography.subheadline)
                                            .foregroundColor(BrandColors.secondaryText)
                                    }
                                    VocationDirectionCard(direction: favoriteDirection)
                                }
                            } else if !blueprint.vocationDirections.isEmpty {
                                // If no favorite, show first direction with hint
                                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                                    Text("提示：請在編輯頁面選擇一個方向設為最愛")
                                        .font(BrandTypography.caption)
                                        .foregroundColor(BrandColors.secondaryText)
                                    VocationDirectionCard(direction: blueprint.vocationDirections[0])
                                }
                            }
                        }
                        .padding(BrandSpacing.lg)
                        .background(BrandColors.surface)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .stroke(BrandColors.borderColor, lineWidth: 1)
                        )
                        .shadow(
                            color: BrandColors.cardShadow.color,
                            radius: BrandColors.cardShadow.radius,
                            x: BrandColors.cardShadow.x,
                            y: BrandColors.cardShadow.y
                        )
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    }
                    
                    VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                        HStack {
                            Text("進度")
                                .font(BrandTypography.title2)
                                .foregroundColor(BrandColors.primaryText)
                            
                            Spacer()
                            
                            // Theme toggle button
                            Button(action: {
                                themeManager.toggleTheme()
                            }) {
                                Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                    .font(.title3)
                                    .foregroundColor(BrandColors.actionAccent)
                                    .padding(BrandSpacing.sm)
                                    .background(BrandColors.surface)
                                    .cornerRadius(BrandRadius.small)
                            }
                            .buttonStyle(.plain)
                            
                            if dataService.userProfile?.lifeBlueprint != nil {
                                NavigationLink(destination: ReviewInitialScanView()) {
                                    HStack(spacing: BrandSpacing.xs) {
                                        Image(systemName: "arrow.clockwise")
                                        Text("重新檢視")
                                    }
                                    .font(BrandTypography.subheadline)
                                    .foregroundColor(BrandColors.actionAccent) // Purple
                                }
                            }
                        }
                        
                        ProgressCard(
                            title: "初步掃描",
                            isCompleted: dataService.userProfile?.lifeBlueprint != nil,
                            progress: calculateInitialScanProgress()
                        )
                        
                        // Disabled navigation - just show progress card without link
                        ProgressCard(
                            title: "深化探索",
                            isCompleted: isDeepeningExplorationComplete(),
                            progress: calculateDeepeningProgress()
                        )
                        
                        // Disabled navigation - just show progress card without link
                        ProgressCard(
                            title: "行動計劃",
                            isCompleted: dataService.userProfile?.actionPlan != nil,
                            progress: dataService.userProfile?.actionPlan != nil ? 1.0 : 0.0
                        )
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.surface)
                    .cornerRadius(16)
                    .shadow(
                        color: BrandColors.cardShadow.color,
                        radius: BrandColors.cardShadow.radius,
                        x: BrandColors.cardShadow.x,
                        y: BrandColors.cardShadow.y
                    )
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
                .padding(.vertical, BrandSpacing.lg)
                .frame(maxWidth: .infinity)
            }
            .background(BrandColors.background)
            .navigationTitle("首頁")
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        }
    }
}

struct ProgressCard: View {
    let title: String
    let isCompleted: Bool
    let progress: Double
    // CRITICAL: Observe theme changes to ensure proper updates
    @StateObject private var themeManager = ThemeManager.shared
    
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
                    .foregroundColor(BrandColors.primaryText) // Theme-aware: white in dark mode, dark charcoal in light mode
                Spacer()
                Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                    .foregroundColor(isCompleted ? BrandColors.brandAccent : BrandColors.tertiaryText) // Golden yellow when completed
                    .font(.title3)
            }
            
            if progress > 0 && !isCompleted {
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: BrandRadius.small)
                            .fill(BrandColors.surface) // Theme-aware: dark charcoal in dark mode, white in light mode
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: BrandRadius.small)
                            .fill(BrandColors.actionAccent) // Fill: Purple #8B5CF6
                            .frame(width: geometry.size.width * progress, height: 8)
                    }
                }
                .frame(height: 8)
                
                Text("\(Int(progress * 100))% 完成")
                    .font(BrandTypography.caption)
                    .foregroundColor(BrandColors.secondaryText) // Theme-aware: light gray in dark mode, soft gray in light mode
            }
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.surface) // Theme-aware: dark charcoal (#1C1C1E) in dark mode, white in light mode
        .cornerRadius(BrandRadius.medium)
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataService.shared)
}
