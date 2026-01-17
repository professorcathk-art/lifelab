import SwiftUI

struct ValuesRankingView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("我的核心價值觀")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("請拖曳排列價值觀的重要性（1-10），選擇3-5個最重要的價值觀")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 32)
                
                ForEach(viewModel.selectedValues) { valueRanking in
                    ValueRankingCard(valueRanking: valueRanking)
                }
                .padding(.horizontal, 20)
                
                Button(action: {
                    viewModel.saveProgress()
                    viewModel.moveToNextStep()
                }) {
                    Text("完成")
                        .font(.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(12)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 32)
            }
        }
    }
}

struct ValueRankingCard: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    let valueRanking: ValueRanking
    @State private var rank: Int = 0
    @State private var relatedMemory: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(valueRanking.value.rawValue)
                        .font(.headline)
                    Text(valueRanking.value.description)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                if rank > 0 {
                    Text("排名：\(rank)")
                        .font(.headline)
                        .foregroundColor(.blue)
                }
            }
            
            if rank == 0 {
                Button(action: {
                    let newRank = (viewModel.selectedValues.filter { $0.rank > 0 }.max(by: { $0.rank < $1.rank })?.rank ?? 0) + 1
                    if newRank <= 10 {
                        rank = newRank
                        viewModel.updateValueRank(valueRanking.id, newRank: newRank)
                    }
                }) {
                    Text("選擇此價值觀")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.blue.opacity(0.1))
                        .cornerRadius(8)
                }
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    Stepper("排名：\(rank)", value: $rank, in: 1...10, onEditingChanged: { _ in
                        viewModel.updateValueRank(valueRanking.id, newRank: rank)
                    })
                    
                    TextField("相關回憶或具體情境（選填）", text: $relatedMemory, axis: .vertical)
                        .textFieldStyle(.roundedBorder)
                        .lineLimit(3...6)
                }
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .onAppear {
            rank = valueRanking.rank
            relatedMemory = valueRanking.relatedMemory ?? ""
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
