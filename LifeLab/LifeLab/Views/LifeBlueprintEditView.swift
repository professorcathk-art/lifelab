import SwiftUI

struct LifeBlueprintEditView: View {
    @EnvironmentObject var dataService: DataService
    @Environment(\.dismiss) var dismiss
    let blueprint: LifeBlueprint
    @State private var editedDirections: [EditableDirection]
    @State private var allVersionsDirections: [EditableDirection] = []
    @State private var showDirectionChangeAlert = false
    @State private var hasUnsavedChanges = false
    @State private var showBackAlert = false
    
    init(blueprint: LifeBlueprint) {
        self.blueprint = blueprint
        // Initialize with original version and sequence number
        var directions: [EditableDirection] = []
        for (index, direction) in blueprint.vocationDirections.enumerated() {
            var editable = EditableDirection(
                from: direction,
                version: blueprint.version,
                sequenceNumber: index + 1
            )
            editable.priority = direction.priority > 0 ? direction.priority : index + 1
            directions.append(editable)
        }
        // Auto-set favorite as first priority (display order only)
        if let favoriteIndex = directions.firstIndex(where: { $0.isFavorite }) {
            var favorite = directions.remove(at: favoriteIndex)
            favorite.priority = 1
            // Update other priorities (display order only)
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
        var priority: Int // Display priority (for sorting)
        var isFavorite: Bool
        var originalVersion: Int // Original version number
        var originalSequenceNumber: Int // Original sequence number within that version
        
        init(id: UUID = UUID(), title: String = "", description: String = "", marketFeasibility: String = "", priority: Int = 0, isFavorite: Bool = false, originalVersion: Int = 1, originalSequenceNumber: Int = 1) {
            self.id = id
            self.title = title
            self.description = description
            self.marketFeasibility = marketFeasibility
            self.priority = priority
            self.isFavorite = isFavorite
            self.originalVersion = originalVersion
            self.originalSequenceNumber = originalSequenceNumber
        }
        
        init(from direction: VocationDirection, version: Int, sequenceNumber: Int) {
            self.id = direction.id
            self.title = direction.title
            self.description = direction.description
            self.marketFeasibility = direction.marketFeasibility
            self.priority = direction.priority
            self.isFavorite = direction.isFavorite
            self.originalVersion = version
            self.originalSequenceNumber = sequenceNumber
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
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.invertedText) // Black text on white button
                        .padding(.horizontal, BrandSpacing.md)
                        .padding(.vertical, BrandSpacing.sm)
                        .background(BrandColors.primaryText) // White background
                        .clipShape(Capsule()) // Pill shape
                    }
                    .buttonStyle(.plain)
                }
                .padding(.top, BrandSpacing.xxxl)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Instructions - Simplified
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("提示：")
                        .font(BrandTypography.headline)
                        .foregroundColor(BrandColors.primaryText)
                    Text("• 點擊⭐標記可以設為最愛（只能選擇一個）")
                        .font(BrandTypography.subheadline)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.actionAccent)
                }
                .padding(BrandSpacing.md)
                .background(BrandColors.secondaryBackground.opacity(0.5))
                .cornerRadius(BrandRadius.medium)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                // Display all versions directions (using editedDirections which contains all versions)
                let allVersionsDirs = loadAllVersionsDirections()
                
                // Sort: Favorite first, then by version (newest first), then by original sequence number
                let sortedDirections = allVersionsDirs.sorted(by: { 
                    // Favorite first
                    if $0.isFavorite != $1.isFavorite {
                        return $0.isFavorite
                    }
                    // Then by version (newest first)
                    if $0.originalVersion != $1.originalVersion {
                        return $0.originalVersion > $1.originalVersion
                    }
                    // Then by original sequence number
                    return $0.originalSequenceNumber < $1.originalSequenceNumber
                })
                
                ForEach(sortedDirections, id: \.id) { direction in
                    // Find the index in editedDirections array (or use direction directly if not found)
                    let editedIndex = editedDirections.firstIndex(where: { $0.id == direction.id })
                    
                    // Use direction from sorted list, but update editedDirections when user edits
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        HStack {
                            // Display: Version X 方向 Y (using original version and sequence number)
                            Text("Version \(direction.originalVersion) 方向 \(direction.originalSequenceNumber)")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.primaryText)
                            
                            // Show indicator if this is from a different version (but still editable)
                            if direction.originalVersion != blueprint.version {
                                Text("（歷史版本，可編輯）")
                                    .font(BrandTypography.caption)
                                    .foregroundColor(BrandColors.secondaryText)
                            }
                            
                            Spacer()
                            
                            // Favorite button
                            Button(action: {
                                hasUnsavedChanges = true
                                let wasFavorite = direction.isFavorite
                                
                                // Check if user already has an action plan and is changing favorite
                                if !wasFavorite, let profile = dataService.userProfile, profile.actionPlan != nil {
                                    // User is changing favorite direction - show alert
                                    showDirectionChangeAlert = true
                                }
                                
                                // Only one can be favorite (across all versions)
                                for i in editedDirections.indices {
                                    editedDirections[i].isFavorite = (editedDirections[i].id == direction.id)
                                }
                                
                                // Update priority for display order (favorite moves to top)
                                // But originalSequenceNumber remains unchanged
                                if !wasFavorite {
                                    // Find the favorite direction and update its priority
                                    if let favoriteIndex = editedDirections.firstIndex(where: { $0.id == direction.id }) {
                                        editedDirections[favoriteIndex].priority = 0 // Set to 0 so it sorts first
                                    }
                                    // Update other priorities (increment by 1)
                                    for i in editedDirections.indices {
                                        if editedDirections[i].id != direction.id {
                                            editedDirections[i].priority += 1
                                        }
                                    }
                                }
                            }) {
                                Image(systemName: direction.isFavorite ? "star.fill" : "star")
                                    .foregroundColor(direction.isFavorite ? BrandColors.brandAccent : BrandColors.secondaryText)
                                    .font(.title3)
                            }
                            .buttonStyle(.plain)
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            Text("標題")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            TextField("職業方向標題", text: Binding(
                                get: { 
                                    if let index = editedIndex {
                                        return editedDirections[index].title
                                    }
                                    return direction.title
                                },
                                set: { newValue in
                                    hasUnsavedChanges = true
                                    if let index = editedIndex {
                                        editedDirections[index].title = newValue
                                    } else {
                                        // Add to editedDirections if not found
                                        var newDir = direction
                                        newDir.title = newValue
                                        editedDirections.append(newDir)
                                    }
                                }
                            ))
                            .textFieldStyle(.roundedBorder)
                            .font(BrandTypography.body)
                        }
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            Text("描述")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                            
                            TextField("詳細描述", text: Binding(
                                get: { 
                                    if let index = editedIndex {
                                        return editedDirections[index].description
                                    }
                                    return direction.description
                                },
                                set: { newValue in
                                    hasUnsavedChanges = true
                                    if let index = editedIndex {
                                        editedDirections[index].description = newValue
                                    } else {
                                        var newDir = direction
                                        newDir.description = newValue
                                        editedDirections.append(newDir)
                                    }
                                }
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
                                get: { 
                                    if let index = editedIndex {
                                        return editedDirections[index].marketFeasibility
                                    }
                                    return direction.marketFeasibility
                                },
                                set: { newValue in
                                    hasUnsavedChanges = true
                                    if let index = editedIndex {
                                        editedDirections[index].marketFeasibility = newValue
                                    } else {
                                        var newDir = direction
                                        newDir.marketFeasibility = newValue
                                        editedDirections.append(newDir)
                                    }
                                }
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
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                Button(action: {
                    saveChanges()
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "checkmark")
                        Text("保存修改")
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
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.bottom, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
            }
            .frame(maxWidth: .infinity)
        }
        .background(BrandColors.background)
        .navigationTitle("編輯生命藍圖")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    if hasUnsavedChanges {
                        showBackAlert = true
                    } else {
                        dismiss()
                    }
                }) {
                    HStack(spacing: BrandSpacing.xs) {
                        Image(systemName: "chevron.left")
                        Text("返回")
                    }
                    .foregroundColor(BrandColors.actionAccent)
                }
            }
        }
        .alert("確認返回", isPresented: $showBackAlert) {
            Button("繼續編輯", role: .cancel) { }
            Button("放棄變更", role: .destructive) {
                hasUnsavedChanges = false
                dismiss()
            }
        } message: {
            Text("您有未儲存的變更。如果現在返回，所有變更將會遺失。建議您先儲存變更。")
        }
        .alert("改變當前行動方向", isPresented: $showDirectionChangeAlert) {
            Button("確定", role: .cancel) { }
        } message: {
            Text("您已改變當前行動方向。請注意，新的行動方向可能與現有的行動計劃不完全匹配。建議您重新檢視行動計劃，確保計劃與新的方向一致。")
        }
        .onAppear {
            // Load all versions directions on first appear
            if editedDirections.count == blueprint.vocationDirections.count {
                // Only load if we haven't loaded all versions yet
                let allVersionsDirs = loadAllVersionsDirections()
                editedDirections = allVersionsDirs
            }
        }
    }
    
    private func loadAllVersionsDirections() -> [EditableDirection] {
        guard let profile = dataService.userProfile else { return editedDirections }
        
        // Collect all directions from all versions with original version and sequence number
        var allDirections: [EditableDirection] = []
        
        // Add directions from all versions (including current)
        for versionBlueprint in profile.lifeBlueprints {
            for (index, direction) in versionBlueprint.vocationDirections.enumerated() {
                // Check if this direction is already in editedDirections (user may have edited it)
                if let editedDir = editedDirections.first(where: { $0.id == direction.id }) {
                    // Use edited version but preserve original version and sequence number
                    var updatedDir = editedDir
                    updatedDir.originalVersion = versionBlueprint.version
                    updatedDir.originalSequenceNumber = index + 1
                    allDirections.append(updatedDir)
                } else {
                    // Add new direction with original version and sequence number
                    allDirections.append(EditableDirection(
                        from: direction,
                        version: versionBlueprint.version,
                        sequenceNumber: index + 1
                    ))
                }
            }
        }
        
        // Remove duplicates (keep the one with highest version number)
        var uniqueDirections: [EditableDirection] = []
        for direction in allDirections.reversed() {
            if !uniqueDirections.contains(where: { $0.id == direction.id }) {
                uniqueDirections.append(direction)
            }
        }
        
        return uniqueDirections.reversed()
    }
    
    private func saveChanges() {
        guard let profile = dataService.userProfile else {
            dismiss()
            return
        }
        
        // Save all edited directions to their respective versions
        var updatedBlueprints: [LifeBlueprint] = []
        
        // Group directions by their original version
        let directionsByVersion = Dictionary(grouping: editedDirections) { $0.originalVersion }
        
        // Update each version's blueprint
        for versionBlueprint in profile.lifeBlueprints {
            var updatedBlueprint = versionBlueprint
            
            // Get directions for this version
            if let versionDirections = directionsByVersion[versionBlueprint.version] {
                // Sort by original sequence number to maintain order
                let sortedDirections = versionDirections.sorted(by: { 
                    // Favorite first, then by original sequence number
                    if $0.isFavorite != $1.isFavorite {
                        return $0.isFavorite
                    }
                    return $0.originalSequenceNumber < $1.originalSequenceNumber
                })
                
                // Convert to VocationDirection and assign priorities
                var finalDirections: [VocationDirection] = []
                for (index, dir) in sortedDirections.enumerated() {
                    var direction = dir.toVocationDirection()
                    direction.priority = index + 1
                    finalDirections.append(direction)
                }
                
                updatedBlueprint.vocationDirections = finalDirections
            }
            
            updatedBlueprints.append(updatedBlueprint)
        }
        
        // Update current blueprint (if it exists in the list)
        var currentBlueprint = blueprint
        if let currentVersionDirections = directionsByVersion[blueprint.version] {
            let sortedDirections = currentVersionDirections.sorted(by: { 
                if $0.isFavorite != $1.isFavorite {
                    return $0.isFavorite
                }
                return $0.originalSequenceNumber < $1.originalSequenceNumber
            })
            
            var finalDirections: [VocationDirection] = []
            for (index, dir) in sortedDirections.enumerated() {
                var direction = dir.toVocationDirection()
                direction.priority = index + 1
                finalDirections.append(direction)
            }
            
            currentBlueprint.vocationDirections = finalDirections
        }
        
        // Save all changes
        DataService.shared.updateUserProfile { profile in
            profile.lifeBlueprint = currentBlueprint
            profile.lifeBlueprints = updatedBlueprints
        }
        
        hasUnsavedChanges = false
        dismiss()
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
