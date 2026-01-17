import SwiftUI
import Combine

struct ValuesRankingView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
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
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("我的核心價值觀")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("使用上下箭頭調整優先級，上方的價值觀優先級更高")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)
                
                List {
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
                        .listRowInsets(EdgeInsets(top: 8, leading: 0, bottom: 8, trailing: 0))
                    }
                    .onMove { source, destination in
                        // Handle drag to reorder
                        let sortedIndices = sortedValues.map { $0.id }
                        var reordered = sortedIndices
                        reordered.move(fromOffsets: source, toOffset: destination)
                        
                        // Update ranks based on new order (top = rank 1, etc.)
                        for (index, id) in reordered.enumerated() {
                            if let valueIndex = viewModel.selectedValues.firstIndex(where: { $0.id == id }) {
                                let newRank = index + 1
                                viewModel.selectedValues[valueIndex].rank = newRank
                                viewModel.selectedValues[valueIndex].isGreyedOut = false
                            }
                        }
                        viewModel.objectWillChange.send()
                    }
                }
                .listStyle(.plain)
                .frame(height: CGFloat(sortedValues.count * 150))
                .padding(.horizontal, 20)
                
                Button(action: {
                    // Save final ranking based on position
                    saveRankingFromPosition()
                    viewModel.saveProgress()
                    viewModel.moveToNextStep()
                }) {
                    Text("完成")
                        .font(BrandTypography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, BrandSpacing.lg)
                        .background(BrandColors.primaryGradient)
                        .cornerRadius(BrandRadius.medium)
                        .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BrandSpacing.xl)
                .padding(.bottom, BrandSpacing.xxxl)
            }
        }
    }
    
    private func moveValueUp(at index: Int) {
        guard index > 0 else { return }
        let values = sortedValues
        let currentId = values[index].id
        let targetId = values[index - 1].id
        
        if let currentIndex = viewModel.selectedValues.firstIndex(where: { $0.id == currentId }),
           let targetIndex = viewModel.selectedValues.firstIndex(where: { $0.id == targetId }) {
            // Swap ranks to update position immediately
            let currentRank = viewModel.selectedValues[currentIndex].rank
            let targetRank = viewModel.selectedValues[targetIndex].rank
            
            viewModel.selectedValues[currentIndex].rank = targetRank
            viewModel.selectedValues[targetIndex].rank = currentRank
            
            // Force UI update
            viewModel.objectWillChange.send()
        }
    }
    
    private func moveValueDown(at index: Int) {
        let values = sortedValues
        guard index < values.count - 1 else { return }
        let currentId = values[index].id
        let targetId = values[index + 1].id
        
        if let currentIndex = viewModel.selectedValues.firstIndex(where: { $0.id == currentId }),
           let targetIndex = viewModel.selectedValues.firstIndex(where: { $0.id == targetId }) {
            // Swap ranks to update position immediately
            let currentRank = viewModel.selectedValues[currentIndex].rank
            let targetRank = viewModel.selectedValues[targetIndex].rank
            
            viewModel.selectedValues[currentIndex].rank = targetRank
            viewModel.selectedValues[targetIndex].rank = currentRank
            
            // Force UI update
            viewModel.objectWillChange.send()
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
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(valueRanking.value.rawValue)
                        .font(.headline)
                        .foregroundColor(isGreyedOut ? .secondary : .primary)
                    Text(valueRanking.value.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !isGreyedOut && rank > 0 {
                    HStack(spacing: BrandSpacing.xs) {
                        Image(systemName: "star.fill")
                            .font(.caption)
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
                HStack(spacing: 12) {
                    Button(action: onMoveUp) {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.title2)
                            .foregroundColor(index > 0 ? BrandColors.primaryBlue : BrandColors.tertiaryText)
                    }
                    .disabled(index == 0)
                    .buttonStyle(.plain)
                    
                    Button(action: onMoveDown) {
                        Image(systemName: "arrow.down.circle.fill")
                            .font(.title2)
                            .foregroundColor(index < totalCount - 1 ? BrandColors.primaryBlue : BrandColors.tertiaryText)
                    }
                    .disabled(index >= totalCount - 1)
                    .buttonStyle(.plain)
                    
                    Spacer()
                    
                    Text("位置決定優先級")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
                        }
                    }
                }) {
                    HStack {
                        Image(systemName: isGreyedOut ? "eye.slash.fill" : "eye.slash")
                        Text(isGreyedOut ? "取消標記為不重要" : "標記為不重要")
                    }
                    .font(.subheadline)
                    .foregroundColor(isGreyedOut ? .blue : .secondary)
                }
            }
        }
        .padding(BrandSpacing.lg)
        .background(isGreyedOut ? BrandColors.tertiaryBackground : BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
        .opacity(isGreyedOut ? 0.6 : 1.0)
        .onAppear {
            rank = valueRanking.rank
            relatedMemory = valueRanking.relatedMemory ?? ""
            isGreyedOut = valueRanking.isGreyedOut
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
