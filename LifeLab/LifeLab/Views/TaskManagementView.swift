import SwiftUI

struct TaskManagementView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var themeManager: ThemeManager
    @State private var selectedTab = 0
    @State private var isGeneratingActionPlan = false
    @State private var showFavoriteRequiredAlert = false
    @State private var showActionPlanSuccess = false
    @State private var isGeneratingTodayTasks = false
    @State private var isEditingTodayTasks = false
    @State private var editedTodayTasks: [ActionItem] = []
    @State private var showRegenerateConfirmation = false
    @State private var showGenerateTodayTasksConfirmation = false
    @State private var showEmptyTitleAlert = false
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                Picker("", selection: $selectedTab) {
                    Text("今日任務").tag(0)
                    Text("所有任務").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                if let actionPlan = dataService.userProfile?.actionPlan {
                    ScrollView {
                        VStack(spacing: BrandSpacing.xxl) {
                            if selectedTab == 0 {
                                // Today's Tasks Section
                                TodayTasksSection(
                                    items: actionPlan.todayTasks,
                                    isGenerating: isGeneratingTodayTasks,
                                    isEditing: $isEditingTodayTasks,
                                    editedItems: $editedTodayTasks,
                                    onGenerate: {
                                        showGenerateTodayTasksConfirmation = true
                                    },
                                    onSave: saveTodayTasks
                                )
                            } else {
                                TaskSection(title: "短期目標（1-3個月）", items: actionPlan.shortTerm, sectionType: .shortTerm)
                                TaskSection(title: "中期目標（3-6個月）", items: actionPlan.midTerm, sectionType: .midTerm)
                                TaskSection(title: "長期目標（6-12個月）", items: actionPlan.longTerm, sectionType: .longTerm)
                                
                                if !actionPlan.milestones.isEmpty {
                                    EditableMilestonesSection(milestones: actionPlan.milestones)
                                }
                                
                                // Regenerate Action Plan Button
                                RegenerateActionPlanButton(
                                    onRegenerate: {
                                        showRegenerateConfirmation = true
                                    }
                                )
                            }
                        }
                        .padding(.vertical)
                        .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    }
                } else {
                    ScrollView {
                        VStack(spacing: BrandSpacing.xl) {
                            // Guidance message
                            VStack(spacing: BrandSpacing.md) {
                                Image(systemName: "checklist")
                                    .font(.system(size: 60))
                                    .foregroundColor(BrandColors.secondaryText)
                                Text("尚未生成行動計劃")
                                    .font(BrandTypography.headline)
                                    .foregroundColor(BrandColors.primaryText)
                                
                                if isDeepeningExplorationComplete() {
                                    VStack(spacing: BrandSpacing.sm) {
                                        Text("您已完成深化探索！")
                                            .font(BrandTypography.subheadline)
                                            .foregroundColor(BrandColors.primaryText)
                                        
                                        // Check if user has selected a favorite direction
                                        if let blueprint = dataService.userProfile?.lifeBlueprint,
                                           blueprint.vocationDirections.contains(where: { $0.isFavorite }) {
                                            Button(action: {
                                                generateActionPlan()
                                            }) {
                                                HStack(spacing: BrandSpacing.sm) {
                                                    if isGeneratingActionPlan {
                                                        ProgressView()
                                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                                            .scaleEffect(0.8)
                                                    } else {
                                                        Image(systemName: "sparkles")
                                                    }
                                                    Text(isGeneratingActionPlan ? "正在生成..." : "生成行動計劃")
                                                }
                                                .font(BrandTypography.headline)
                                                .fontWeight(.bold)
                                                .foregroundColor(BrandColors.invertedText) // Black text on white button
                                                .frame(maxWidth: .infinity)
                                                .frame(height: 50)
                                                .background(BrandColors.primaryText) // White background
                                                .clipShape(Capsule()) // Pill shape
                                            }
                                            .buttonStyle(.plain)
                                            .disabled(isGeneratingActionPlan)
                                        } else {
                                            VStack(spacing: BrandSpacing.sm) {
                                                Text("請先在生命藍圖編輯頁面選擇一個方向設為最愛")
                                                    .font(BrandTypography.subheadline)
                                                    .foregroundColor(BrandColors.secondaryText)
                                                    .multilineTextAlignment(.center)
                                                
                                                if let blueprint = dataService.userProfile?.lifeBlueprint {
                                                    NavigationLink(destination: LifeBlueprintEditView(blueprint: blueprint)) {
                                                        HStack(spacing: BrandSpacing.sm) {
                                                            Image(systemName: "pencil")
                                                            Text("編輯生命藍圖")
                                                        }
                                                        .font(BrandTypography.headline)
                                                        .fontWeight(.bold)
                                                        .foregroundColor(BrandColors.invertedText) // Black text on white button
                                                        .frame(maxWidth: .infinity)
                                                        .frame(height: 50)
                                                        .background(BrandColors.primaryText) // White background
                                                        .clipShape(Capsule()) // Pill shape
                                                        .cornerRadius(BrandRadius.medium)
                                                    }
                                                    .buttonStyle(.plain)
                                                }
                                            }
                                        }
                                    }
                                } else {
                                    VStack(spacing: BrandSpacing.sm) {
                                        Text("請先完成深化探索，然後AI將為您生成個人化行動計劃")
                                            .font(BrandTypography.subheadline)
                                            .foregroundColor(BrandColors.secondaryText)
                                            .multilineTextAlignment(.center)
                                        
                                        NavigationLink(destination: DeepeningExplorationView()) {
                                            HStack(spacing: BrandSpacing.sm) {
                                                Image(systemName: "chart.line.uptrend.xyaxis")
                                                    .font(.system(size: 16, weight: .bold))
                                                Text("前往深化探索")
                                                    .font(BrandTypography.headline)
                                                    .fontWeight(.bold)
                                            }
                                            .foregroundColor(BrandColors.invertedText) // Black text on white button
                                            .frame(maxWidth: .infinity)
                                            .frame(height: 50)
                                            .background(BrandColors.primaryText) // White background
                                            .clipShape(Capsule()) // Pill shape
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                            }
                            .padding(BrandSpacing.xl)
                            .frame(maxWidth: .infinity)
                        }
                        .padding(.vertical, BrandSpacing.xl)
                    }
                }
            }
            .background(BrandColors.background)
            .navigationTitle("任務管理")
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .alert("需要選擇最愛方向", isPresented: $showFavoriteRequiredAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("請先在生命藍圖編輯頁面選擇一個方向設為最愛，然後再生成行動計劃")
            }
            .alert("成功", isPresented: $showActionPlanSuccess) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("行動計劃已生成")
            }
            .alert("重新生成行動計劃", isPresented: $showRegenerateConfirmation) {
                Button("取消", role: .cancel) { }
                Button("確認重新生成", role: .destructive) {
                    regenerateActionPlan()
                }
            } message: {
                Text("重新生成行動計劃將會刪除現有的行動計劃。此操作無法復原，確定要繼續嗎？")
            }
            .alert("生成今日任務", isPresented: $showGenerateTodayTasksConfirmation) {
                Button("取消", role: .cancel) { }
                Button("確認生成", role: .destructive) {
                    generateTodayTasks()
                }
            } message: {
                Text("生成新的今日任務將會重置所有現有的今日任務。此操作無法復原，確定要繼續嗎？")
            }
            .alert("任務標題不能為空", isPresented: $showEmptyTitleAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("請為所有任務輸入標題後再儲存。")
            }
        }
    }
    
    private func regenerateActionPlan() {
        // IMPORTANT: Clear existing action plan first
        DataService.shared.updateUserProfile { profile in
            profile.actionPlan = nil
        }
        // Then generate new one
        generateActionPlan()
    }
    
    private func generateTodayTasks() {
        guard let profile = dataService.userProfile else { return }
        guard !isGeneratingTodayTasks else { return }
        
        isGeneratingTodayTasks = true
        
        Task {
            do {
                let tasks = try await AIService.shared.generateTodayTasks(profile: profile)
                await MainActor.run {
                    DataService.shared.updateUserProfile { profile in
                        if var actionPlan = profile.actionPlan {
                            actionPlan.todayTasks = tasks
                            actionPlan.todayTasksLastGenerated = Date()
                            profile.actionPlan = actionPlan
                        }
                    }
                    isGeneratingTodayTasks = false
                }
            } catch {
                await MainActor.run {
                    isGeneratingTodayTasks = false
                    print("Failed to generate today tasks: \(error)")
                }
            }
        }
    }
    
    private func saveTodayTasks() {
        // Check if any task has empty title
        let hasEmptyTitle = editedTodayTasks.contains { $0.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty }
        
        if hasEmptyTitle {
            showEmptyTitleAlert = true
            return
        }
        
        DataService.shared.updateUserProfile { profile in
            if var actionPlan = profile.actionPlan {
                actionPlan.todayTasks = editedTodayTasks
                profile.actionPlan = actionPlan
            }
        }
        isEditingTodayTasks = false
    }
    
    private func isDeepeningExplorationComplete() -> Bool {
        guard let profile = dataService.userProfile else { return false }
        return profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count >= 3 &&
               profile.valuesQuestions != nil &&
               profile.resourceInventory != nil &&
               profile.acquiredStrengths != nil &&
               profile.feasibilityAssessment != nil
    }
    
    private func generateActionPlan() {
        guard let profile = dataService.userProfile else { return }
        
        // Check if user has selected a favorite direction
        guard let blueprint = profile.lifeBlueprint,
              let favoriteDirection = blueprint.vocationDirections.first(where: { $0.isFavorite }) else {
            showFavoriteRequiredAlert = true
            return
        }
        
        guard !isGeneratingActionPlan else { return }
        isGeneratingActionPlan = true
        
        Task {
            do {
                let plan = try await AIService.shared.generateActionPlan(profile: profile, favoriteDirection: favoriteDirection)
                await MainActor.run {
                    DataService.shared.updateUserProfile { profile in
                        profile.actionPlan = plan
                    }
                    isGeneratingActionPlan = false
                    showActionPlanSuccess = true
                }
            } catch {
                await MainActor.run {
                    isGeneratingActionPlan = false
                    print("Failed to generate action plan: \(error)")
                }
            }
        }
    }
}

// MARK: - Regenerate Action Plan Button
struct RegenerateActionPlanButton: View {
    let onRegenerate: () -> Void
    
    var body: some View {
        Button(action: onRegenerate) {
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: "arrow.clockwise")
                Text("重新生成行動計劃")
            }
            .font(BrandTypography.headline)
            .fontWeight(.bold)
            .foregroundColor(BrandColors.invertedText)
            .frame(maxWidth: .infinity)
            .frame(height: 50)
            .background(BrandColors.actionAccent)
            .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .padding(.horizontal, BrandSpacing.xl)
        .padding(.top, BrandSpacing.lg)
    }
}

struct TaskSection: View {
    @EnvironmentObject var dataService: DataService
    let title: String
    let items: [ActionItem]
    let sectionType: TaskSectionType
    @State private var isEditing = false
    @State private var editedItems: [ActionItem] = []
    
    enum TaskSectionType {
        case shortTerm
        case midTerm
        case longTerm
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            HStack {
                Text(title)
                    .font(BrandTypography.title2)
                    .foregroundColor(BrandColors.primaryText)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditing.toggle()
                        if isEditing {
                            editedItems = items
                        }
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.title3)
                        .foregroundColor(BrandColors.primaryBlue)
                        .padding(BrandSpacing.sm)
                        .background(BrandColors.primaryBlue.opacity(0.1))
                        .cornerRadius(BrandRadius.small)
                }
                .buttonStyle(.plain)
                
                if isEditing {
                    Button(action: {
                        addNewTask()
                    }) {
                        Image(systemName: "plus")
                            .font(.title3)
                            .foregroundColor(BrandColors.primaryBlue)
                            .padding(BrandSpacing.sm)
                            .background(BrandColors.primaryBlue.opacity(0.1))
                            .cornerRadius(BrandRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BrandSpacing.xl)
            
            if isEditing {
                ForEach(editedItems.indices, id: \.self) { index in
                    EditableTaskCard(
                        title: Binding(
                            get: { editedItems[index].title },
                            set: { editedItems[index].title = $0; saveTasks() }
                        ),
                        description: Binding(
                            get: { editedItems[index].description },
                            set: { editedItems[index].description = $0; saveTasks() }
                        ),
                        dueDate: Binding(
                            get: { editedItems[index].dueDate ?? Date() },
                            set: { editedItems[index].dueDate = $0; saveTasks() }
                        ),
                        onDelete: {
                            editedItems.remove(at: index)
                            saveTasks()
                        }
                    )
                    .padding(.horizontal, BrandSpacing.xl)
                }
            } else {
                ForEach(items) { item in
                    TaskCard(item: item)
                        .padding(.horizontal, BrandSpacing.xl)
                }
            }
        }
    }
    
    private func addNewTask() {
        let newTask = ActionItem(
            title: "新任務",
            description: "點擊編輯",
            dueDate: Calendar.current.date(byAdding: .month, value: sectionType == .shortTerm ? 1 : sectionType == .midTerm ? 3 : 6, to: Date())
        )
        editedItems.append(newTask)
        saveTasks()
    }
    
    private func saveTasks() {
        DataService.shared.updateUserProfile { profile in
            guard var actionPlan = profile.actionPlan else { return }
            
            switch sectionType {
            case .shortTerm:
                actionPlan.shortTerm = editedItems
            case .midTerm:
                actionPlan.midTerm = editedItems
            case .longTerm:
                actionPlan.longTerm = editedItems
            }
            
            profile.actionPlan = actionPlan
        }
    }
}

struct EditableTaskCard: View {
    @Binding var title: String
    @Binding var description: String
    @Binding var dueDate: Date
    let onDelete: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            TextField("任務標題", text: $title)
                .font(BrandTypography.headline)
                .textFieldStyle(.roundedBorder)
            
            TextField("任務描述", text: $description, axis: .vertical)
                .font(BrandTypography.subheadline)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
            
            HStack {
                DatePicker("截止日期", selection: $dueDate, displayedComponents: [.date])
                    .labelsHidden()
                
                Spacer()
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .foregroundColor(BrandColors.error)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
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
                    .foregroundColor(item.isCompleted ? BrandColors.primaryBlue : BrandColors.tertiaryText)
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
            
            // Find and toggle in todayTasks
            if let index = actionPlan.todayTasks.firstIndex(where: { $0.id == item.id }) {
                actionPlan.todayTasks[index].isCompleted.toggle()
            }
            // Find and toggle in shortTerm
            else if let index = actionPlan.shortTerm.firstIndex(where: { $0.id == item.id }) {
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
                        .foregroundColor(milestone.isCompleted ? BrandColors.primaryBlue : BrandColors.tertiaryText)
                        .font(.title3)
                }
                .buttonStyle(PlainButtonStyle())
            }
            
            Text(milestone.description)
                .font(BrandTypography.subheadline)
                .foregroundColor(BrandColors.secondaryText)
            
            if let targetDate = milestone.targetDate {
                Text("目標日期：\(targetDate.formatted(date: .abbreviated, time: .omitted))")
                    .font(BrandTypography.caption)
                    .foregroundColor(BrandColors.secondaryText)
            }
            
            if !milestone.successIndicators.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("成功指標：")
                        .font(BrandTypography.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(BrandColors.primaryText)
                    ForEach(milestone.successIndicators, id: \.self) { indicator in
                        HStack(spacing: 4) {
                            Text("•")
                            Text(indicator)
                                .font(BrandTypography.caption)
                        }
                        .foregroundColor(BrandColors.secondaryText)
                    }
                }
            }
        }
        .padding()
        .background(BrandColors.surface)
        .cornerRadius(12)
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(BrandColors.borderColor, lineWidth: 1)
        )
        .shadow(
            color: BrandColors.cardShadow.color,
            radius: BrandColors.cardShadow.radius,
            x: BrandColors.cardShadow.x,
            y: BrandColors.cardShadow.y
        )
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

struct TodayTasksSection: View {
    @EnvironmentObject var dataService: DataService
    let items: [ActionItem]
    let isGenerating: Bool
    @Binding var isEditing: Bool
    @Binding var editedItems: [ActionItem]
    let onGenerate: () -> Void
    let onSave: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            HStack {
                Text("今日任務")
                    .font(BrandTypography.title2)
                    .foregroundColor(BrandColors.primaryText)
                
                Spacer()
                
                // Generate button if no tasks or tasks are old
                if items.isEmpty || shouldRegenerateTodayTasks() {
                    Button(action: onGenerate) {
                        HStack(spacing: BrandSpacing.xs) {
                            if isGenerating {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: BrandColors.primaryBlue))
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "sparkles")
                            }
                            Text(isGenerating ? "生成中..." : "生成今日任務")
                        }
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.primaryBlue)
                        .padding(BrandSpacing.sm)
                        .background(BrandColors.primaryBlue.opacity(0.1))
                        .cornerRadius(BrandRadius.small)
                    }
                    .buttonStyle(.plain)
                    .disabled(isGenerating)
                }
                
                // Edit button
                if !items.isEmpty {
                    Button(action: {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isEditing.toggle()
                            if isEditing {
                                editedItems = items
                            } else {
                                onSave()
                            }
                        }
                    }) {
                        Image(systemName: isEditing ? "checkmark" : "pencil")
                            .font(.title3)
                            .foregroundColor(BrandColors.primaryBlue)
                            .padding(BrandSpacing.sm)
                            .background(BrandColors.primaryBlue.opacity(0.1))
                            .cornerRadius(BrandRadius.small)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, BrandSpacing.xl)
            
            if items.isEmpty {
                VStack(spacing: BrandSpacing.sm) {
                    Image(systemName: "calendar.badge.clock")
                        .font(.system(size: 40))
                        .foregroundColor(BrandColors.secondaryText)
                    Text("尚未生成今日任務")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                    Text("點擊上方按鈕讓AI為您生成今天的任務")
                        .font(BrandTypography.caption)
                        .foregroundColor(BrandColors.tertiaryText)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(BrandSpacing.xl)
            } else if isEditing {
                ForEach(editedItems.indices, id: \.self) { index in
                    EditableTaskCard(
                        title: Binding(
                            get: { editedItems[index].title },
                            set: { editedItems[index].title = $0 }
                        ),
                        description: Binding(
                            get: { editedItems[index].description },
                            set: { editedItems[index].description = $0 }
                        ),
                        dueDate: Binding(
                            get: { editedItems[index].dueDate ?? Date() },
                            set: { editedItems[index].dueDate = $0 }
                        ),
                        onDelete: {
                            editedItems.remove(at: index)
                        }
                    )
                    .padding(.horizontal, BrandSpacing.xl)
                }
                
                // Add new task button
                Button(action: {
                    let newTask = ActionItem(
                        title: "新任務",
                        description: "點擊編輯",
                        dueDate: Date()
                    )
                    editedItems.append(newTask)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加新任務")
                    }
                    .font(BrandTypography.subheadline)
                    .foregroundColor(BrandColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(BrandSpacing.md)
                    .background(BrandColors.primaryBlue.opacity(0.1))
                    .cornerRadius(BrandRadius.medium)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BrandSpacing.xl)
            } else {
                ForEach(items) { item in
                    TaskCard(item: item)
                        .padding(.horizontal, BrandSpacing.xl)
                        .swipeActions(edge: .leading, allowsFullSwipe: false) {
                            Button(role: .destructive) {
                                deleteTodayTask(item)
                            } label: {
                                Label("刪除", systemImage: "trash")
                            }
                        }
                }
            }
        }
    }
    
    private func shouldRegenerateTodayTasks() -> Bool {
        guard let profile = dataService.userProfile,
              let actionPlan = profile.actionPlan,
              let lastGenerated = actionPlan.todayTasksLastGenerated else {
            return true
        }
        // Regenerate if last generated was not today
        let calendar = Calendar.current
        return !calendar.isDateInToday(lastGenerated)
    }
    
    private func deleteTodayTask(_ item: ActionItem) {
        DataService.shared.updateUserProfile { profile in
            if var actionPlan = profile.actionPlan {
                actionPlan.todayTasks.removeAll { $0.id == item.id }
                profile.actionPlan = actionPlan
            }
        }
    }
}

struct EditableMilestonesSection: View {
    @EnvironmentObject var dataService: DataService
    let milestones: [Milestone]
    @State private var isEditing = false
    @State private var editedMilestones: [Milestone]
    
    init(milestones: [Milestone]) {
        self.milestones = milestones
        _editedMilestones = State(initialValue: milestones)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("關鍵里程碑")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Spacer()
                
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        isEditing.toggle()
                        if isEditing {
                            editedMilestones = milestones
                        } else {
                            saveMilestones()
                        }
                    }
                }) {
                    Image(systemName: isEditing ? "checkmark" : "pencil")
                        .font(.title3)
                        .foregroundColor(BrandColors.primaryBlue)
                        .padding(BrandSpacing.sm)
                        .background(BrandColors.primaryBlue.opacity(0.1))
                        .cornerRadius(BrandRadius.small)
                }
                .buttonStyle(.plain)
            }
            .padding(.horizontal)
            
            if isEditing {
                ForEach(editedMilestones.indices, id: \.self) { index in
                    EditableMilestoneCard(
                        milestone: Binding(
                            get: { editedMilestones[index] },
                            set: { editedMilestones[index] = $0 }
                        ),
                        onDelete: {
                            editedMilestones.remove(at: index)
                        }
                    )
                    .padding(.horizontal)
                }
                
                // Add new milestone button
                Button(action: {
                    let newMilestone = Milestone(
                        title: "新里程碑",
                        description: "點擊編輯",
                        targetDate: Calendar.current.date(byAdding: .month, value: 3, to: Date()),
                        successIndicators: []
                    )
                    editedMilestones.append(newMilestone)
                }) {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                        Text("添加新里程碑")
                    }
                    .font(BrandTypography.subheadline)
                    .foregroundColor(BrandColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(BrandSpacing.md)
                    .background(BrandColors.primaryBlue.opacity(0.1))
                    .cornerRadius(BrandRadius.medium)
                }
                .buttonStyle(.plain)
                .padding(.horizontal)
            } else {
                ForEach(milestones) { milestone in
                    MilestoneCard(milestone: milestone)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.vertical)
    }
    
    private func saveMilestones() {
        DataService.shared.updateUserProfile { profile in
            if var actionPlan = profile.actionPlan {
                actionPlan.milestones = editedMilestones
                profile.actionPlan = actionPlan
            }
        }
    }
}

struct EditableMilestoneCard: View {
    @Binding var milestone: Milestone
    let onDelete: () -> Void
    @State private var newIndicatorText: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            TextField("里程碑標題", text: $milestone.title)
                .font(BrandTypography.headline)
                .textFieldStyle(.roundedBorder)
            
            TextField("里程碑描述", text: $milestone.description, axis: .vertical)
                .font(BrandTypography.subheadline)
                .textFieldStyle(.roundedBorder)
                .lineLimit(2...4)
            
            DatePicker("目標日期", selection: Binding(
                get: { milestone.targetDate ?? Date() },
                set: { milestone.targetDate = $0 }
            ), displayedComponents: [.date])
                .labelsHidden()
            
            // Success indicators editing
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text("成功指標：")
                    .font(BrandTypography.caption)
                    .fontWeight(.semibold)
                ForEach(milestone.successIndicators.indices, id: \.self) { index in
                    HStack {
                        TextField("指標", text: Binding(
                            get: { milestone.successIndicators[index] },
                            set: { milestone.successIndicators[index] = $0 }
                        ))
                        .textFieldStyle(.roundedBorder)
                        .font(BrandTypography.caption)
                        Button(action: {
                            milestone.successIndicators.remove(at: index)
                        }) {
                            Image(systemName: "minus.circle.fill")
                                .foregroundColor(.red)
                        }
                    }
                }
                
                HStack {
                    TextField("新增指標", text: $newIndicatorText)
                        .textFieldStyle(.roundedBorder)
                        .font(BrandTypography.caption)
                    Button(action: {
                        if !newIndicatorText.isEmpty {
                            milestone.successIndicators.append(newIndicatorText)
                            newIndicatorText = ""
                        }
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(BrandColors.primaryBlue)
                    }
                }
            }
            
            Button(action: onDelete) {
                HStack {
                    Image(systemName: "trash")
                    Text("刪除里程碑")
                }
                .foregroundColor(BrandColors.error)
            }
            .buttonStyle(.plain)
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
    }
}

#Preview {
    TaskManagementView()
        .environmentObject(DataService.shared)
}
