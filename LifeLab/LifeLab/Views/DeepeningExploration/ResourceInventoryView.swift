import SwiftUI

struct ResourceInventoryView: View {
    @Environment(\.dismiss) var dismiss
    @StateObject private var viewModel = ResourceInventoryViewModel()
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header
                    VStack(spacing: 12) {
                        Text("資源盤點")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("盤點您的時間、金錢、物品、人脈四大資源")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 32)
                    }
                    .padding(.top, 32)
                    
                    // Resource categories
                    VStack(spacing: 16) {
                        ResourceCategoryCard(
                            icon: "clock.fill",
                            title: "時間資源",
                            color: .blue,
                            description: "您每天/每週可以投入的時間",
                            text: Binding(
                                get: { viewModel.inventory.time ?? "" },
                                set: { viewModel.inventory.time = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：每天2小時，週末8小時..."
                        )
                        
                        ResourceCategoryCard(
                            icon: "dollarsign.circle.fill",
                            title: "金錢資源",
                            color: Color(hex: "10b6cc"),
                            description: "您可以投入的資金預算",
                            text: Binding(
                                get: { viewModel.inventory.money ?? "" },
                                set: { viewModel.inventory.money = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：每月$5000，總預算$50000..."
                        )
                        
                        ResourceCategoryCard(
                            icon: "bag.fill",
                            title: "物品資源",
                            color: .orange,
                            description: "您擁有的設備、工具、空間等",
                            text: Binding(
                                get: { viewModel.inventory.items ?? "" },
                                set: { viewModel.inventory.items = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：MacBook、相機、工作室空間..."
                        )
                        
                        ResourceCategoryCard(
                            icon: "person.2.fill",
                            title: "人脈資源",
                            color: .purple,
                            description: "您可以尋求幫助的人際網絡",
                            text: Binding(
                                get: { viewModel.inventory.network ?? "" },
                                set: { viewModel.inventory.network = $0.isEmpty ? nil : $0 }
                            ),
                            placeholder: "例如：設計師朋友、創業導師、行業專家..."
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                    
                    // Complete button
                    if viewModel.isComplete {
                        Button(action: {
                            viewModel.completeResourceInventory()
                            dismiss()
                        }) {
                            Text("完成資源盤點")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(hex: "10b6cc"))
                                .cornerRadius(12)
                        }
                        .padding(.horizontal, 20)
                        .padding(.bottom, 32)
                    }
                }
            }
            .navigationTitle("資源盤點")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("完成") {
                        viewModel.saveProgress()
                        dismiss()
                    }
                }
            }
        }
    }
}

struct ResourceCategoryCard: View {
    let icon: String
    let title: String
    let color: Color
    let description: String
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.headline)
                    
                    Text(description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if !text.isEmpty {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(hex: "10b6cc"))
                }
            }
            
            TextField(placeholder, text: $text, axis: .vertical)
                .textFieldStyle(.roundedBorder)
                .lineLimit(3...6)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    ResourceInventoryView()
}
