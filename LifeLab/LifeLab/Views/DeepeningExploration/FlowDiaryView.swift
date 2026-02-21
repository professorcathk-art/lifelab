import SwiftUI

struct FlowDiaryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FlowDiaryViewModel()
    @State private var showFlowTips = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        HStack {
                            Text("心流日記")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                            
                            Spacer()
                            
                            // Tips button with animation
                            Button(action: {
                                showFlowTips = true
                            }) {
                                Image(systemName: "questionmark.circle.fill")
                                    .font(.title3)
                                    .foregroundColor(BrandColors.actionAccent)
                                    .modifier(PulseAnimationModifier())
                            }
                        }
                        .padding(.horizontal, 32)
                        
                    Text("記錄3個心流事件（不一定要連續3天）")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    
                    // Progress indicator
                    HStack(spacing: 8) {
                        ForEach(Array(0..<max(3, viewModel.entries.count)), id: \.self) { index in
                            Circle()
                                .fill(index < viewModel.completedEvents ? Color(hex: "10b6cc") : Color.gray.opacity(0.3))
                                .frame(width: 12, height: 12)
                        }
                    }
                    .padding(.bottom, 8)
                    
                    Text("已完成 \(viewModel.completedEvents)/3 個心流事件")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // Flow event entries
                    VStack(spacing: 16) {
                        ForEach(Array(viewModel.entries.enumerated()), id: \.element.id) { index, entry in
                            FlowEventCard(
                                eventNumber: index + 1,
                                entry: entry,
                                isCompleted: !entry.activity.isEmpty,
                                onSave: { updatedEntry in
                                    viewModel.saveEntry(updatedEntry, at: index)
                                },
                                onDelete: {
                                    viewModel.deleteEntry(at: index)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Add new event button
                    Button(action: {
                        viewModel.addNewEntry()
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("新增心流事件")
                        }
                        .font(.headline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal, 20)
                    
                    // Complete button
                    if viewModel.completedEvents >= 3 {
                        Button(action: {
                            viewModel.completeFlowDiary()
                            dismiss()
                        }) {
                            HStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "checkmark.circle.fill")
                                Text("完成心流日記")
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
                            .shadow(color: Color(hex: "10b6cc").opacity(0.3), radius: 8, x: 0, y: 4)
                        }
                        .buttonStyle(.plain)
                        .padding(.horizontal, BrandSpacing.xl)
                        .padding(.bottom, BrandSpacing.xxxl)
                    }
                }
            }
            .navigationTitle("心流日記")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showFlowTips) {
                FlowTipsView()
            }
        }
    }
}

// MARK: - Flow Tips View
struct FlowTipsView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                    // Title
                    VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                        Text("什麼是心流？")
                            .font(BrandTypography.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(BrandColors.primaryText)
                        
                        Text("心理學家米哈里·契克森米哈伊（Mihaly Csikszentmihalyi）提出的概念")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(.top, BrandSpacing.xl)
                    
                    // Definition Card
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        Text("心流（Flow）的定義")
                            .font(BrandTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(BrandColors.primaryText)
                        
                        Text("心流是一種完全沉浸於當下活動的心理狀態。當你處於心流時，會感到時間似乎靜止，自我意識消失，完全專注於手頭上的任務，並從中獲得極大的滿足感和成就感。")
                            .font(BrandTypography.body)
                            .foregroundColor(BrandColors.primaryText)
                            .lineSpacing(4)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.secondaryBackground)
                    .cornerRadius(BrandRadius.medium)
                    
                    // Characteristics Card
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        Text("心流的特徵")
                            .font(BrandTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(BrandColors.primaryText)
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            FlowCharacteristicItem(
                                icon: "target",
                                title: "清晰的目標",
                                description: "你知道自己要做什麼，目標明確且可實現"
                            )
                            
                            FlowCharacteristicItem(
                                icon: "gauge.with.dots.needle.67percent",
                                title: "技能與挑戰平衡",
                                description: "任務難度與你的能力水平相匹配，既不會太簡單（感到無聊），也不會太困難（感到焦慮）"
                            )
                            
                            FlowCharacteristicItem(
                                icon: "eye.fill",
                                title: "全神貫注",
                                description: "完全專注於當前活動，外界干擾消失"
                            )
                            
                            FlowCharacteristicItem(
                                icon: "clock.fill",
                                title: "時間感改變",
                                description: "感覺時間過得特別快，或者時間似乎靜止了"
                            )
                            
                            FlowCharacteristicItem(
                                icon: "sparkles",
                                title: "內在動機",
                                description: "活動本身就是獎勵，不需要外部激勵"
                            )
                            
                            FlowCharacteristicItem(
                                icon: "hand.thumbsup.fill",
                                title: "控制感",
                                description: "感覺完全掌控局面，行動與意識融為一體"
                            )
                            
                            FlowCharacteristicItem(
                                icon: "face.smiling",
                                title: "自我意識消失",
                                description: "不再擔心別人怎麼看，完全沉浸在活動中"
                            )
                        }
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.secondaryBackground)
                    .cornerRadius(BrandRadius.medium)
                    
                    // Examples Card
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        Text("心流事件的例子")
                            .font(BrandTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(BrandColors.primaryText)
                        
                        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                            Text("• 專注地寫作、繪畫或創作時")
                            Text("• 運動時完全投入，感覺身體與動作合一")
                            Text("• 解決複雜問題時，思路清晰流暢")
                            Text("• 演奏樂器或進行藝術表演時")
                            Text("• 深度閱讀或學習新知識時")
                            Text("• 與他人進行深度對話時")
                        }
                        .font(BrandTypography.body)
                        .foregroundColor(BrandColors.primaryText)
                        .lineSpacing(4)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.secondaryBackground)
                    .cornerRadius(BrandRadius.medium)
                    
                    // Why Important Card
                    VStack(alignment: .leading, spacing: BrandSpacing.md) {
                        Text("為什麼記錄心流事件很重要？")
                            .font(BrandTypography.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(BrandColors.primaryText)
                        
                        Text("通過記錄心流事件，你可以發現：\n\n• 哪些活動讓你感到最有活力和滿足感\n• 你的天賦和興趣所在\n• 什麼樣的環境和條件能讓你進入心流狀態\n• 如何將這些發現應用到職業選擇和人生規劃中")
                            .font(BrandTypography.body)
                            .foregroundColor(BrandColors.primaryText)
                            .lineSpacing(4)
                    }
                    .padding(BrandSpacing.lg)
                    .background(BrandColors.secondaryBackground)
                    .cornerRadius(BrandRadius.medium)
                }
                .padding(BrandSpacing.lg)
            }
            .background(BrandColors.background)
            .navigationTitle("心流事件說明")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        dismiss()
                    }
                    .foregroundColor(BrandColors.actionAccent)
                }
            }
        }
    }
}

// MARK: - Flow Characteristic Item
struct FlowCharacteristicItem: View {
    let icon: String
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: BrandSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(BrandColors.actionAccent)
                .frame(width: 24)
            
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(BrandColors.primaryText)
                
                Text(description)
                    .font(BrandTypography.caption)
                    .foregroundColor(BrandColors.secondaryText)
                    .lineSpacing(2)
            }
        }
    }
}

struct FlowEventCard: View {
    let eventNumber: Int
    @State var entry: FlowDiaryEntry
    let isCompleted: Bool
    let onSave: (FlowDiaryEntry) -> Void
    let onDelete: () -> Void
    
    @State private var isEditing = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("心流事件 \(eventNumber)")
                    .font(.headline)
                
                Spacer()
                
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "10b6cc"))
                }
                
                if isCompleted {
                    Button(action: {
                        onDelete()
                    }) {
                        Image(systemName: "trash")
                            .foregroundColor(.red)
                    }
                }
            }
            
                    if isEditing {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("什麼時候？")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            DatePicker("", selection: Binding(
                                get: { entry.date },
                                set: { entry.date = $0 }
                            ), displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            
                            Text("做了什麼？")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("描述您當時在做的事情", text: Binding(
                                get: { entry.activity },
                                set: { entry.activity = $0 }
                            ))
                            .textFieldStyle(.roundedBorder)
                            
                            Text("詳細描述")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            TextField("描述您的感受和體驗", text: Binding(
                                get: { entry.description },
                                set: { entry.description = $0 }
                            ), axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                            .lineLimit(3...6)
                            
                            Text("活力程度：\(entry.energyLevel)/10")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                            
                            Slider(value: Binding(
                                get: { Double(entry.energyLevel) },
                                set: { entry.energyLevel = Int($0) }
                            ), in: 1...10, step: 1)
                            
                            HStack {
                                Button("取消") {
                                    isEditing = false
                                    // Delete if blank
                                    if entry.activity.isEmpty && entry.description.isEmpty {
                                        onDelete()
                                    }
                                }
                                .foregroundColor(.red)
                                
                                Spacer()
                                
                                Button("保存") {
                                    onSave(entry)
                                    isEditing = false
                                }
                                .foregroundColor(.blue)
                                .fontWeight(.semibold)
                            }
                        }
            } else {
                if isCompleted {
                    VStack(alignment: .leading, spacing: 8) {
                        Text(entry.date, style: .date)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        
                        Text("做了：\(entry.activity)")
                            .font(.body)
                        
                        if !entry.description.isEmpty {
                            Text("感受：\(entry.description)")
                                .font(.body)
                                .foregroundColor(.secondary)
                        }
                        
                        Text("活力程度：\(entry.energyLevel)/10")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    
                    Button("編輯") {
                        isEditing = true
                    }
                    .font(.subheadline)
                    .foregroundColor(.blue)
                } else {
                    Button(action: {
                        isEditing = true
                    }) {
                        HStack {
                            Image(systemName: "plus.circle.fill")
                            Text("記錄心流事件 \(eventNumber)")
                        }
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

// MARK: - Pulse Animation Modifier (iOS 16+ Compatible)
struct PulseAnimationModifier: ViewModifier {
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? 1.1 : 1.0)
            .opacity(isAnimating ? 0.8 : 1.0)
            .onAppear {
                withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                    isAnimating = true
                }
            }
    }
}

#Preview {
    FlowDiaryView()
}
