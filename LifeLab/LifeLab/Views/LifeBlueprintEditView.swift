import SwiftUI

struct LifeBlueprintEditView: View {
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) var dismiss
    let blueprint: LifeBlueprint
    @State private var editedDirections: [EditableDirection]
    @State private var allVersionsDirections: [EditableDirection] = []
    
    init(blueprint: LifeBlueprint) {
        self.blueprint = blueprint
        // Initialize with priority order (1, 2, 3...) if not set
        var directions = blueprint.vocationDirections.map { EditableDirection(from: $0) }
        for (index, _) in directions.enumerated() {
            if directions[index].priority == 0 {
                directions[index].priority = index + 1
            }
        }
        // Auto-set favorite as first priority
        if let favoriteIndex = directions.firstIndex(where: { $0.isFavorite }) {
            var favorite = directions.remove(at: favoriteIndex)
            favorite.priority = 1
            // Update other priorities
            for i in directions.indices {
                directions[i].priority = i + 2
            }
            directions.insert(favorite, at: 0)
        }
        _editedDirections = State(initialValue: directions)
    }
    
    struct EditableDirection: Identifiable {
        let id: UUID
        var title: String
        var description: String
        var marketFeasibility: String
        var priority: Int
        var isFavorite: Bool
        
        init(id: UUID = UUID(), title: String = "", description: String = "", marketFeasibility: String = "", priority: Int = 0, isFavorite: Bool = false) {
            self.id = id
            self.title = title
            self.description = description
            self.marketFeasibility = marketFeasibility
            self.priority = priority
            self.isFavorite = isFavorite
        }
        
        init(from direction: VocationDirection) {
            self.id = direction.id
            self.title = direction.title
            self.description = direction.description
            self.marketFeasibility = direction.marketFeasibility
            self.priority = direction.priority
            self.isFavorite = direction.isFavorite
        }
        
        func toVocationDirection() -> VocationDirection {
            VocationDirection(id: id, title: title, description: description, marketFeasibility: marketFeasibility, priority: priority, isFavorite: isFavorite)
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: BrandSpacing.xl) {
                HStack {
                    Text("編輯生命藍圖")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Spacer()
                    
                    // Save button at top
                    Button(action: {
                        saveChanges()
                    }) {
                        HStack(spacing: BrandSpacing.xs) {
                            Image(systemName: "checkmark")
                            Text("保存")
                        }
                        .font(BrandTypography.subheadline)
                        .foregroundColor(.white)
                        .padding(.horizontal, BrandSpacing.md)
                        .padding(.vertical, BrandSpacing.sm)
                        .background(BrandColors.primaryGradient)
                        .cornerRadius(BrandRadius.small)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, BrandSpacing.xxxl)
                .padding(.horizontal, BrandSpacing.lg)
                
                // Instructions
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("提示：")
                        .font(BrandTypography.headline)
                        .foregroundColor(BrandColors.primaryText)
                    Text("• 點擊⭐標記可以設為最愛（只能選擇一個）")
                    Text("• 最愛方向 = 當前行動方向，會自動設為第一優先順序")
                    Text("• 點擊上下箭頭可以調整優先順序")
                }
                .font(BrandTypography.subheadline)
                .foregroundColor(BrandColors.secondaryText)
                .padding(BrandSpacing.md)
                .background(BrandColors.secondaryBackground.opacity(0.5))
                .cornerRadius(BrandRadius.medium)
                
                ForEach(editedDirections.sorted(by: { $0.priority < $1.priority }), id: \.id) { direction in
                    let index = editedDirections.firstIndex(where: { $0.id == direction.id }) ?? 0
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        HStack {
                            Text("Version \(blueprint.version) 方向 \(direction.priority)")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.primaryText)
                            
                            Spacer()
                            
                            // Favorite button
                            Button(action: {
                                let wasFavorite = direction.isFavorite
                                // Only one can be favorite
                                for i in editedDirections.indices {
                                    editedDirections[i].isFavorite = (editedDirections[i].id == direction.id)
                                }
                                // Auto-update priority: favorite becomes priority 1
                                if !wasFavorite {
                                    let favoriteIndex = editedDirections.firstIndex(where: { $0.id == direction.id }) ?? 0
                                    let oldPriority = editedDirections[favoriteIndex].priority
                                    editedDirections[favoriteIndex].priority = 1
                                    // Update other priorities
                                    for i in editedDirections.indices {
                                        if editedDirections[i].id != direction.id {
                                            if editedDirections[i].priority < oldPriority {
                                                editedDirections[i].priority += 1
                                            }
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: direction.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(direction.isFavorite ? .yellow : BrandColors.secondaryText)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                            
                            // Priority controls
                            VStack(spacing: BrandSpacing.xs) {
                                Button(action: {
                                    moveDirectionUp(at: index)
                                }) {
                                    Image(systemName: "chevron.up.circle")
                                        .foregroundColor(index > 0 ? BrandColors.primaryBlue : BrandColors.secondaryText)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                                .disabled(index == 0)
                                
                                Button(action: {
                                    moveDirectionDown(at: index)
                                }) {
                                    Image(systemName: "chevron.down.circle")
                                        .foregroundColor(index < editedDirections.count - 1 ? BrandColors.primaryBlue : BrandColors.secondaryText)
                                        .font(.title3)
                                }
                                .buttonStyle(.plain)
                                .disabled(index == editedDirections.count - 1)
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            Text("標題")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            TextField("職業方向標題", text: Binding(
                                get: { direction.title },
                                set: { editedDirections[index].title = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .font(BrandTypography.body)
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            Text("描述")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            TextField("詳細描述", text: Binding(
                                get: { direction.description },
                                set: { editedDirections[index].description = $0 }
                            ), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .font(BrandTypography.body)
                            .lineLimit(5...10)
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            Text("市場可行性")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            TextField("市場可行性評估", text: Binding(
                                get: { direction.marketFeasibility },
                                set: { editedDirections[index].marketFeasibility = $0 }
                            ), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .font(BrandTypography.body)
                            .lineLimit(3...6)
                        }
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.secondaryBackground)
                    .cornerRadius(BrandRadius.medium)
                }
                
                Button(action: {
                    // Save edited blueprint with updated priorities
                    var updatedBlueprint = blueprint
                    // Update priorities based on current order
                    let sortedDirections = editedDirections.sorted(by: { $0.priority < $1.priority })
                    var finalDirections: [VocationDirection] = []
                    for (index, dir) in sortedDirections.enumerated() {
                        var direction = dir.toVocationDirection()
                        direction.priority = index + 1
                        finalDirections.append(direction)
                    }
                    updatedBlueprint.vocationDirections = finalDirections
                    
                    DataService.shared.updateUserProfile { profile in
                        profile.lifeBlueprint = updatedBlueprint
                        if let index = profile.lifeBlueprints.firstIndex(where: { $0.version == blueprint.version }) {
                            profile.lifeBlueprints[index] = updatedBlueprint
                        }
                    }
                    
                    dismiss()
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "checkmark")
                        Text("保存修改")
                    }
                    .font(BrandTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.lg)
                    .background(BrandColors.primaryGradient)
                    .cornerRadius(BrandRadius.medium)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BrandSpacing.xl)
                .padding(.bottom, BrandSpacing.xxxl)
            }
                .padding(.horizontal, BrandSpacing.lg)
        }
        .background(BrandColors.background)
        .navigationTitle("編輯生命藍圖")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadAllVersionsDirections()
        }
    }
    
    private func loadAllVersionsDirections() {
        guard let profile = dataService.userProfile else { return }
        
        // Collect all directions from all versions
        var allDirections: [EditableDirection] = []
        
        // Add directions from current blueprint
        for direction in blueprint.vocationDirections {
            allDirections.append(EditableDirection(from: direction))
        }
        
        // Add directions from other versions (excluding current version)
        for versionBlueprint in profile.lifeBlueprints {
            if versionBlueprint.version != blueprint.version {
                for direction in versionBlueprint.vocationDirections {
                    // Only add if not already in current directions
                    if !allDirections.contains(where: { $0.id == direction.id }) {
                        allDirections.append(EditableDirection(from: direction))
                    }
                }
            }
        }
        
        // Update priorities
        for (index, _) in allDirections.enumerated() {
            if allDirections[index].priority == 0 {
                allDirections[index].priority = index + 1
            }
        }
        
        allVersionsDirections = allDirections
        // Merge with editedDirections (current version takes precedence)
        var mergedDirections = editedDirections
        for versionDir in allVersionsDirections {
            if !mergedDirections.contains(where: { $0.id == versionDir.id }) {
                mergedDirections.append(versionDir)
            }
        }
        editedDirections = mergedDirections
    }
    
    private func saveChanges() {
        // Save current edited directions
        var updatedBlueprint = blueprint
        var finalDirections: [VocationDirection] = []
        for (index, dir) in editedDirections.sorted(by: { $0.priority < $1.priority }).enumerated() {
            var direction = dir.toVocationDirection()
            direction.priority = index + 1
            finalDirections.append(direction)
        }
        updatedBlueprint.vocationDirections = finalDirections
        
        DataService.shared.updateUserProfile { profile in
            profile.lifeBlueprint = updatedBlueprint
            if let index = profile.lifeBlueprints.firstIndex(where: { $0.version == blueprint.version }) {
                profile.lifeBlueprints[index] = updatedBlueprint
            }
        }
        
        dismiss()
    }
    
    private func moveDirectionUp(at index: Int) {
        guard index > 0 else { return }
        let tempPriority = editedDirections[index].priority
        editedDirections[index].priority = editedDirections[index - 1].priority
        editedDirections[index - 1].priority = tempPriority
    }
    
    private func moveDirectionDown(at index: Int) {
        guard index < editedDirections.count - 1 else { return }
        let tempPriority = editedDirections[index].priority
        editedDirections[index].priority = editedDirections[index + 1].priority
        editedDirections[index + 1].priority = tempPriority
    }
}

#Preview {
    NavigationStack {
        LifeBlueprintEditView(blueprint: LifeBlueprint(
            vocationDirections: [
                VocationDirection(title: "測試方向", description: "測試描述", marketFeasibility: "測試可行性")
            ],
            strengthsSummary: "測試總結",
            feasibilityAssessment: "測試評估"
        ))
        .environmentObject(DataService.shared)
    }
}
