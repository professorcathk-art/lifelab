import SwiftUI

struct DeepeningExplorationView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedStep: DeepeningExplorationStep?
    @State private var isGeneratingNewVersion = false
    // Use shared state from DataService to sync with TaskManagementView
    private var isGeneratingActionPlan: Bool {
        dataService.isGeneratingActionPlan
    }
    @State private var showNewVersionSuccess = false
    @State private var latestVersionNumber = 1
    @State private var showActionPlanSuccess = false
    @State private var showCooldownAlert = false
    @State private var cooldownRemainingMinutes = 0
    @State private var navigateToEditView = false
    @State private var generatedBlueprint: LifeBlueprint?
    @State private var showFavoriteRequiredAlert = false
    @State private var navigateToEditForFavorite = false
    
    // Update latestVersionNumber when view appears or profile changes
    private func updateLatestVersionNumber() {
        if let profile = dataService.userProfile {
            let allBlueprints = profile.lifeBlueprints
            let highestVersion = allBlueprints.map { $0.version }.max() ?? 1
            latestVersionNumber = highestVersion
        }
    }
    
    private var isDeepeningComplete: Bool {
        guard let profile = dataService.userProfile else { return false }
        return profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count >= 3 &&
               profile.valuesQuestions != nil &&
               profile.resourceInventory != nil &&
               profile.acquiredStrengths != nil &&
               profile.feasibilityAssessment != nil
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("完成以下練習以獲得完整的個人化計劃")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        .padding(.top, 32)
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    
                    explorationStepsView
                    
                    if isDeepeningComplete {
                        actionButtonsView
                    }
                }
                .padding(.bottom, 32)
                .frame(maxWidth: .infinity)
            }
            .background(BrandColors.background)
            .navigationTitle("深化探索")
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .onAppear {
                updateLatestVersionNumber()
                updateCooldownStatus()
            }
            .onChange(of: dataService.userProfile?.lifeBlueprints.count) { _ in
                updateLatestVersionNumber()
            }
            .navigationDestination(isPresented: $navigateToEditView) {
                if let blueprint = generatedBlueprint {
                    LifeBlueprintEditView(blueprint: blueprint)
                }
            }
        }
    }
    
    private var explorationStepsView: some View {
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
    }
    
    private var actionButtonsView: some View {
        VStack(spacing: BrandSpacing.md) {
            Button(action: {
                guard !isGeneratingNewVersion else { return }
                checkCooldownAndGenerate()
            }) {
                HStack(spacing: BrandSpacing.sm) {
                    if isGeneratingNewVersion {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: BrandColors.invertedText))
                            .scaleEffect(0.8)
                    } else {
                        Image(systemName: "arrow.triangle.2.circlepath")
                    }
                    if canGenerateBlueprint() {
                        Text(isGeneratingNewVersion ? "正在生成..." : "生成更新版生命藍圖 (Version \(latestVersionNumber + 1))")
                    } else {
                        Text("請等待 \(cooldownRemainingMinutes) 分鐘後再生成")
                            .foregroundColor(themeManager.isDarkMode ? Color.white : Color.black)
                    }
                }
                .font(BrandTypography.headline)
                .foregroundColor(canGenerateBlueprint() ? BrandColors.invertedText : (themeManager.isDarkMode ? Color.white : Color.black))
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.lg)
                .background(
                    canGenerateBlueprint() 
                        ? (themeManager.isDarkMode 
                            ? AnyShapeStyle(BrandColors.actionAccent)
                            : AnyShapeStyle(BrandColors.actionAccent))
                        : AnyShapeStyle(BrandColors.surface)
                )
                .cornerRadius(BrandRadius.medium)
                .shadow(
                    color: canGenerateBlueprint() ? BrandColors.buttonShadow.color : Color.clear,
                    radius: canGenerateBlueprint() ? BrandColors.buttonShadow.radius : 0,
                    x: canGenerateBlueprint() ? BrandColors.buttonShadow.x : 0,
                    y: canGenerateBlueprint() ? BrandColors.buttonShadow.y : 0
                )
                .scaleEffect(isGeneratingNewVersion ? 0.98 : 1.0)
                .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isGeneratingNewVersion)
            }
            .buttonStyle(.plain)
            .disabled(isGeneratingNewVersion || !canGenerateBlueprint())
            
            // Only show action plan button if version 2+ exists and no action plan yet
            // CRITICAL: Check both dataService.userProfile?.actionPlan and isGeneratingActionPlan
            // This ensures button disappears immediately when generation starts or completes
            if latestVersionNumber >= 2 && dataService.userProfile?.actionPlan == nil && !isGeneratingActionPlan {
                Button(action: {
                    guard !isGeneratingActionPlan && dataService.userProfile?.actionPlan == nil else { return }
                    checkFavoriteAndGenerateActionPlan()
                }) {
                    VStack(spacing: BrandSpacing.sm) {
                        HStack(spacing: BrandSpacing.sm) {
                        if isGeneratingActionPlan {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: BrandColors.invertedText))
                                .scaleEffect(0.8)
                        } else if dataService.userProfile?.actionPlan != nil {
                            Image(systemName: "checkmark.circle.fill")
                        } else {
                            Image(systemName: "sparkles")
                        }
                            Text(isGeneratingActionPlan ? "行動計劃生成中" : (dataService.userProfile?.actionPlan != nil ? "行動計劃已生成" : "生成行動計劃"))
                        }
                        
                        if !isGeneratingActionPlan && dataService.userProfile?.actionPlan == nil {
                            Text("請先在編輯頁面選擇一個方向設為當前行動方向（⭐）")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.invertedText.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .font(BrandTypography.headline)
                    .foregroundColor(BrandColors.invertedText)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.lg)
                    .background(
                        dataService.userProfile?.actionPlan != nil
                            ? AnyShapeStyle(BrandColors.success)
                            : AnyShapeStyle(BrandColors.actionAccent)
                    )
                    .cornerRadius(BrandRadius.medium)
                    .shadow(
                        color: BrandColors.buttonShadow.color,
                        radius: BrandColors.buttonShadow.radius,
                        x: BrandColors.buttonShadow.x,
                        y: BrandColors.buttonShadow.y
                    )
                    .scaleEffect(isGeneratingActionPlan ? 0.98 : 1.0)
                    .animation(.spring(response: 0.2, dampingFraction: 0.6), value: isGeneratingActionPlan)
                }
                .buttonStyle(.plain)
                .disabled(isGeneratingActionPlan || dataService.userProfile?.actionPlan != nil)
            }
        }
        .alert("成功", isPresented: $showNewVersionSuccess) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("Version \(latestVersionNumber) 生命藍圖已生成並保存至個人檔案")
        }
        .alert("成功", isPresented: $showActionPlanSuccess) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("行動計劃已生成並保存至任務頁面")
        }
        .alert("冷卻時間", isPresented: $showCooldownAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("您需要等待 \(cooldownRemainingMinutes) 分鐘後才能再次生成更新版生命藍圖")
        }
        .alert("需要選擇當前行動方向", isPresented: $showFavoriteRequiredAlert) {
            Button("取消", role: .cancel) { }
            Button("前往編輯") {
                if let blueprint = dataService.userProfile?.lifeBlueprint {
                    generatedBlueprint = blueprint
                    navigateToEditForFavorite = true
                }
            }
        } message: {
            Text("請先在生命藍圖編輯頁面選擇一個方向設為最愛（⭐），作為當前行動方向，然後才能生成行動計劃。")
        }
        .alert("錯誤", isPresented: $showError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .navigationDestination(isPresented: $navigateToEditForFavorite) {
            if let blueprint = generatedBlueprint ?? dataService.userProfile?.lifeBlueprint {
                LifeBlueprintEditView(blueprint: blueprint)
            }
        }
        .padding(.horizontal, BrandSpacing.xl)
    }
    
    private func canGenerateBlueprint() -> Bool {
        guard let profile = dataService.userProfile,
              let lastGeneration = profile.lastBlueprintGenerationTime else {
            return true // Can generate if never generated before
        }
        let timeSinceLastGeneration = Date().timeIntervalSince(lastGeneration)
        let oneHourInSeconds: TimeInterval = 3600
        return timeSinceLastGeneration >= oneHourInSeconds
    }
    
    private func updateCooldownStatus() {
        guard let profile = dataService.userProfile,
              let lastGeneration = profile.lastBlueprintGenerationTime else {
            cooldownRemainingMinutes = 0
            return
        }
        let timeSinceLastGeneration = Date().timeIntervalSince(lastGeneration)
        let oneHourInSeconds: TimeInterval = 3600
        if timeSinceLastGeneration < oneHourInSeconds {
            cooldownRemainingMinutes = Int((oneHourInSeconds - timeSinceLastGeneration) / 60) + 1
        } else {
            cooldownRemainingMinutes = 0
        }
    }
    
    private func checkCooldownAndGenerate() {
        if canGenerateBlueprint() {
            generateNewVersionBlueprint()
        } else {
            updateCooldownStatus()
            showCooldownAlert = true
        }
    }
    
    private func generateNewVersionBlueprint() {
        guard let profile = dataService.userProfile else { return }
        guard !isGeneratingNewVersion else { return }
        
        isGeneratingNewVersion = true
        
        Task {
            do {
                // Generate new blueprint with profile (includes basicInfo)
                let blueprint = try await AIService.shared.generateLifeBlueprint(profile: profile)
                
                await MainActor.run {
                    // Find the highest version number and increment it
                    let allBlueprints = profile.lifeBlueprints
                    let highestVersion = allBlueprints.map { $0.version }.max() ?? 1
                    let nextVersion = highestVersion + 1
                    
                    var updatedBlueprint = blueprint
                    updatedBlueprint.version = nextVersion
                    updatedBlueprint.createdAt = Date()
                    
                    // Log the blueprint content to verify AI is working
                    print("✅ Saving Version \(nextVersion) blueprint:")
                    print("  - Directions count: \(blueprint.vocationDirections.count)")
                    print("  - First direction title: \(blueprint.vocationDirections.first?.title ?? "none")")
                    print("  - Strengths summary length: \(blueprint.strengthsSummary.count) chars")
                    print("  - Strengths summary preview: \(blueprint.strengthsSummary.prefix(100))...")
                    
                    DataService.shared.updateUserProfile { profile in
                        // Add new version to array (don't remove old versions)
                        profile.lifeBlueprints.append(updatedBlueprint)
                        profile.lifeBlueprint = updatedBlueprint // Set as current
                        profile.lastBlueprintGenerationTime = Date() // Update cooldown timer
                        print("✅ Added Version \(nextVersion) to lifeBlueprints array. Total versions: \(profile.lifeBlueprints.count)")
                    }
                    
                    // Update UI state
                    latestVersionNumber = nextVersion
                    isGeneratingNewVersion = false
                    generatedBlueprint = updatedBlueprint
                    
                    // Navigate to edit view after generation
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        navigateToEditView = true
                    }
                }
            } catch {
                await MainActor.run {
                    isGeneratingNewVersion = false
                    print("❌ Failed to generate new version blueprint: \(error)")
                }
            }
        }
    }
    
    private func checkFavoriteAndGenerateActionPlan() {
        guard let profile = dataService.userProfile,
              let blueprint = profile.lifeBlueprint else {
            showFavoriteRequiredAlert = true
            return
        }
        
        // Check if user has selected a favorite direction
        guard let favoriteDirection = blueprint.vocationDirections.first(where: { $0.isFavorite }) else {
            // Show alert and navigate to edit view
            showFavoriteRequiredAlert = true
            return
        }
        
        // Generate action plan
        generateActionPlan(favoriteDirection: favoriteDirection)
    }
    
    private func generateActionPlan(favoriteDirection: VocationDirection) {
        guard let profile = dataService.userProfile else { return }
        guard !dataService.isGeneratingActionPlan else { return }
        
        // CRITICAL: Set shared state so both pages know generation is in progress
        dataService.isGeneratingActionPlan = true
        
        // CRITICAL: Request background task to allow generation to continue even if app goes to background
        var backgroundTaskID: UIBackgroundTaskIdentifier = .invalid
        backgroundTaskID = UIApplication.shared.beginBackgroundTask(withName: "GenerateActionPlan") {
            // Task expired, end it
            if backgroundTaskID != .invalid {
                UIApplication.shared.endBackgroundTask(backgroundTaskID)
                backgroundTaskID = .invalid
            }
        }
        
        // Store backgroundTaskID in a way that can be accessed from detached task
        let taskID = backgroundTaskID
        
        // CRITICAL: Use detached task to prevent cancellation when view disappears
        // This ensures generation continues even when user switches screens
        Task.detached(priority: .userInitiated) {
            do {
                let plan = try await AIService.shared.generateActionPlan(profile: profile, favoriteDirection: favoriteDirection)
                await MainActor.run {
                    DataService.shared.updateUserProfile { profile in
                        profile.actionPlan = plan
                    }
                    // CRITICAL: Set shared state to false AFTER saving action plan
                    // This ensures button disappears immediately in both pages
                    dataService.isGeneratingActionPlan = false
                    showActionPlanSuccess = true
                    
                    // End background task
                    if taskID != .invalid {
                        UIApplication.shared.endBackgroundTask(taskID)
                    }
                }
            } catch {
                await MainActor.run {
                    // CRITICAL: Set shared state to false on error too
                    dataService.isGeneratingActionPlan = false
                    print("❌ Failed to generate action plan: \(error)")
                    errorMessage = error.localizedDescription
                    showError = true
                    
                    // End background task
                    if taskID != .invalid {
                        UIApplication.shared.endBackgroundTask(taskID)
                    }
                }
            }
        }
    }
    
    @State private var errorMessage = ""
    @State private var showError = false
}

struct ExplorationStepCard: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isUnlocked: Bool
    // CRITICAL: Observe theme changes to ensure proper updates
    @StateObject private var themeManager = ThemeManager.shared

    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                Text(title)
                    .font(BrandTypography.headline)
                    .foregroundColor(BrandColors.primaryText) // Theme-aware: white in dark mode, dark charcoal in light mode
                Text(description)
                    .font(BrandTypography.subheadline)
                    .foregroundColor(BrandColors.secondaryText) // Theme-aware: light gray in dark mode, soft gray in light mode
            }

            Spacer()

            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(BrandColors.success)
                    .font(.title2)
            } else if isUnlocked {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(BrandColors.actionAccent)
                    .font(.title2)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(BrandColors.secondaryText)
                    .font(.title2)
            }
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.surface) // Theme-aware: dark charcoal (#1C1C1E) in dark mode, white in light mode
        .cornerRadius(BrandRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: BrandRadius.medium)
                .stroke(BrandColors.borderColor, lineWidth: 1) // Theme-aware border
        )
        .shadow(
            color: BrandColors.cardShadow.color,
            radius: BrandColors.cardShadow.radius,
            x: BrandColors.cardShadow.x,
            y: BrandColors.cardShadow.y
        )
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    DeepeningExplorationView()
        .environmentObject(DataService.shared)
}
