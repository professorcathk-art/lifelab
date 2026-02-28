import SwiftUI
import Combine

struct ValuesRankingView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @State private var refreshTrigger = UUID() // Force view refresh
    
    // Sort: greyed out at bottom, then by rank (higher rank = top)
    private var sortedValues: [ValueRanking] {
        viewModel.selectedValues.sorted { value1, value2 in
            if value1.isGreyedOut != value2.isGreyedOut {
                return !value1.isGreyedOut // Non-greyed out first
            }
            if value1.isGreyedOut {
                return false // Both greyed out, keep order
            }
            // Both not greyed out, sort by rank (higher rank = top)
            if value1.rank == 0 && value2.rank == 0 {
                return false
            }
            if value1.rank == 0 {
                return false
            }
            if value2.rank == 0 {
                return true
            }
            return value1.rank < value2.rank // Lower rank number = higher priority (rank 1 is top)
        }
    }
    
    var body: some View {
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color(hex: "667eea").opacity(0.1),
                    Color(hex: "764ba2").opacity(0.1),
                    Color(hex: "f093fb").opacity(0.1)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: BrandSpacing.xxl) {
                VStack(spacing: BrandSpacing.md) {
                    Text("我的核心價值觀")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("使用上下箭頭調整優先級，上方的價值觀優先級更高")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                }
                .padding(.top, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                VStack(spacing: BrandSpacing.md) {
                    ForEach(Array(sortedValues.enumerated()), id: \.element.id) { index, valueRanking in
                        ValueRankingCard(
                            valueRanking: valueRanking,
                            index: index,
                            totalCount: sortedValues.count,
                            onMoveUp: {
                                moveValueUp(at: index)
                            },
                            onMoveDown: {
                                moveValueDown(at: index)
                            }
                        )
                        .transition(.asymmetric(
                            insertion: .move(edge: .leading).combined(with: .opacity),
                            removal: .move(edge: .trailing).combined(with: .opacity)
                        ))
                    }
                    // Removed .onMove to disable drag and drop - only arrow buttons allowed
                }
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .id(refreshTrigger) // Force refresh when trigger changes
                
                Button(action: {
                    // Save final ranking based on position
                    saveRankingFromPosition()
                    viewModel.saveProgress()
                    viewModel.moveToNextStep()
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Text("完成")
                            .font(.system(size: 18, weight: .bold))
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 18, weight: .bold))
                    }
                    .foregroundColor(
                        // CRITICAL: Ensure proper contrast
                        // Dark mode: White background → Black text
                        // Light mode: Dark charcoal background → White text
                        ThemeManager.shared.isDarkMode ? Color.black : Color.white
                    )
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(
                        // CRITICAL: Ensure proper contrast
                        // Dark mode: White background
                        // Light mode: Dark charcoal background
                        ThemeManager.shared.isDarkMode ? Color.white : BrandColors.primaryText
                    )
                    .clipShape(Capsule()) // Pill shape
                }
                .buttonStyle(.plain)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.bottom, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func moveValueUp(at index: Int) {
        guard index > 0 else { return }
        let values = sortedValues
        guard !values[index].isGreyedOut && !values[index - 1].isGreyedOut else { return }
        
        let currentId = values[index].id
        let targetId = values[index - 1].id
        
        if let currentIndex = viewModel.selectedValues.firstIndex(where: { $0.id == currentId }),
           let targetIndex = viewModel.selectedValues.firstIndex(where: { $0.id == targetId }) {
            
            // Actually swap the array positions (not just ranks)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedValues.swapAt(currentIndex, targetIndex)
                
                // Update ranks based on new positions (top = rank 1)
                let nonGreyedValues = viewModel.selectedValues.filter { !$0.isGreyedOut }
                for (idx, value) in nonGreyedValues.enumerated() {
                    if let valueIndex = viewModel.selectedValues.firstIndex(where: { $0.id == value.id }) {
                        viewModel.selectedValues[valueIndex].rank = idx + 1
                    }
                }
                
                // Force view refresh
                refreshTrigger = UUID()
            }
        }
    }
    
    private func moveValueDown(at index: Int) {
        let values = sortedValues
        guard index < values.count - 1 else { return }
        guard !values[index].isGreyedOut && !values[index + 1].isGreyedOut else { return }
        
        let currentId = values[index].id
        let targetId = values[index + 1].id
        
        if let currentIndex = viewModel.selectedValues.firstIndex(where: { $0.id == currentId }),
           let targetIndex = viewModel.selectedValues.firstIndex(where: { $0.id == targetId }) {
            
            // Actually swap the array positions (not just ranks)
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                viewModel.selectedValues.swapAt(currentIndex, targetIndex)
                
                // Update ranks based on new positions (top = rank 1)
                let nonGreyedValues = viewModel.selectedValues.filter { !$0.isGreyedOut }
                for (idx, value) in nonGreyedValues.enumerated() {
                    if let valueIndex = viewModel.selectedValues.firstIndex(where: { $0.id == value.id }) {
                        viewModel.selectedValues[valueIndex].rank = idx + 1
                    }
                }
                
                // Force view refresh
                refreshTrigger = UUID()
            }
        }
    }
    
    private func moveValues(from source: IndexSet, to destination: Int) {
        let nonGreyedValues = sortedValues.filter { !$0.isGreyedOut }
        let greyedValues = sortedValues.filter { $0.isGreyedOut }
        
        var reorderedNonGreyed = nonGreyedValues
        reorderedNonGreyed.move(fromOffsets: source, toOffset: destination)
        
        // Update ranks based on new positions
        for (index, value) in reorderedNonGreyed.enumerated() {
            if let valueIndex = viewModel.selectedValues.firstIndex(where: { $0.id == value.id }) {
                viewModel.selectedValues[valueIndex].rank = index + 1
            }
        }
        
        // Combine back with greyed values
        let allReordered = reorderedNonGreyed + greyedValues
        
        // Update the order in viewModel
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            viewModel.selectedValues = allReordered.map { value in
                viewModel.selectedValues.first(where: { $0.id == value.id }) ?? value
            }
            // Force view refresh
            refreshTrigger = UUID()
        }
    }
    
    private func saveRankingFromPosition() {
        // Update ranks based on current position (top = rank 1)
        let nonGreyedValues = sortedValues.filter { !$0.isGreyedOut }
        for (index, valueRanking) in nonGreyedValues.enumerated() {
            if let valueIndex = viewModel.selectedValues.firstIndex(where: { $0.id == valueRanking.id }) {
                viewModel.selectedValues[valueIndex].rank = index + 1
            }
        }
    }
}

struct ValueRankingCard: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    let valueRanking: ValueRanking
    let index: Int
    let totalCount: Int
    let onMoveUp: () -> Void
    let onMoveDown: () -> Void
    
    @State private var rank: Int = 0
    @State private var relatedMemory: String = ""
    @State private var isGreyedOut: Bool = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            HStack {
                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                    Text(valueRanking.value.rawValue)
                        .font(BrandTypography.headline)
                        .foregroundColor(isGreyedOut ? BrandColors.secondaryText : BrandColors.primaryText)
                    Text(valueRanking.value.description)
                        .font(BrandTypography.caption)
                        .foregroundColor(BrandColors.secondaryText)
                }
                
                Spacer()
                
                if !isGreyedOut && rank > 0 {
                    HStack(spacing: BrandSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption)
                            .foregroundColor(BrandColors.accentYellow)
                        Text("優先級：\(rank)")
                            .font(BrandTypography.headline)
                            .foregroundColor(BrandColors.primaryBlue)
                    }
                } else if isGreyedOut {
                    Text("不重要")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                }
            }
            
            if !isGreyedOut {
                // Up/Down arrow buttons
                HStack(spacing: BrandSpacing.md) {
                    Button(action: {
                        onMoveUp()
                    }) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(index > 0 && !isGreyedOut ? BrandColors.primaryBlue : BrandColors.tertiaryText)
                    }
                    .disabled(index == 0 || isGreyedOut)
                    .buttonStyle(.plain)
                    
                    Button(action: {
                        onMoveDown()
                    }) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(index < totalCount - 1 && !isGreyedOut ? BrandColors.primaryBlue : BrandColors.tertiaryText)
                    }
                    .disabled(index >= totalCount - 1 || isGreyedOut)
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("位置決定優先級")
                        .font(BrandTypography.caption)
                        .foregroundColor(BrandColors.secondaryText)
                }
                
                TextField("相關回憶或具體情境（選填）", text: $relatedMemory, axis: .vertical)
                    .textFieldStyle(.roundedBorder)
                    .lineLimit(3...6)
            }
            
            HStack {
                Spacer()
                Button(action: {
                    isGreyedOut.toggle()
                    if let index = viewModel.selectedValues.firstIndex(where: { $0.id == valueRanking.id }) {
                        viewModel.selectedValues[index].isGreyedOut = isGreyedOut
                        if isGreyedOut {
                            viewModel.selectedValues[index].rank = 0
                            rank = 0
                        } else {
                            // Assign a rank when un-greyed
                            let nonGreyedCount = viewModel.selectedValues.filter { !$0.isGreyedOut }.count
                            viewModel.selectedValues[index].rank = nonGreyedCount + 1
                            rank = nonGreyedCount + 1
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isGreyedOut ? "eye.slash.fill" : "eye.slash")
                        Text(isGreyedOut ? "取消標記為不重要" : "標記為不重要")
                    }
                    .font(BrandTypography.subheadline)
                    .foregroundColor(isGreyedOut ? BrandColors.primaryBlue : BrandColors.secondaryText)
                }
            }
        }
        .padding(BrandSpacing.lg)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(isGreyedOut ? BrandColors.tertiaryBackground : BrandColors.secondaryBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(isGreyedOut ? Color.clear : BrandColors.primaryBlue.opacity(0.2), lineWidth: 1)
                )
        )
        .shadow(color: BrandColors.primaryBlue.opacity(isGreyedOut ? 0.1 : 0.2), radius: 10, x: 0, y: 5)
        .opacity(isGreyedOut ? 0.6 : 1.0)
        // Removed drag gesture - only arrow buttons allowed for ranking
        .onAppear {
            rank = valueRanking.rank
            relatedMemory = valueRanking.relatedMemory ?? ""
            isGreyedOut = valueRanking.isGreyedOut
        }
        .onChange(of: valueRanking.rank) { newRank in
            rank = newRank
        }
        .onChange(of: valueRanking.isGreyedOut) { newValue in
            isGreyedOut = newValue
        }
        .onChange(of: relatedMemory) { newValue in
            if let index = viewModel.selectedValues.firstIndex(where: { $0.id == valueRanking.id }) {
                viewModel.selectedValues[index].relatedMemory = newValue.isEmpty ? nil : newValue
            }
        }
    }
}

#Preview {
    ValuesRankingView()
        .environmentObject(InitialScanViewModel())
}
