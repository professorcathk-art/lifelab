import SwiftUI

struct FlowDiaryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = FlowDiaryViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("心流日記")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
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

#Preview {
    FlowDiaryView()
}
