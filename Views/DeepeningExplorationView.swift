import SwiftUI

struct DeepeningExplorationView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    Text("深化探索")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .padding(.top, 32)
                    
                    Text("完成以下練習以獲得完整的個人化計劃")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                    
                    VStack(spacing: 16) {
                        ExplorationStepCard(
                            title: "心流日記",
                            description: "記錄3天內感覺最有活力的時刻",
                            isCompleted: false,
                            isUnlocked: true
                        )
                        
                        ExplorationStepCard(
                            title: "價值觀問題",
                            description: "回答深度價值觀探索問題",
                            isCompleted: false,
                            isUnlocked: false
                        )
                        
                        ExplorationStepCard(
                            title: "資源盤點",
                            description: "盤點時間、金錢、物品、人脈四大資源",
                            isCompleted: false,
                            isUnlocked: false
                        )
                        
                        ExplorationStepCard(
                            title: "後天強項",
                            description: "分析經驗、知識、技能、實績",
                            isCompleted: false,
                            isUnlocked: false
                        )
                        
                        ExplorationStepCard(
                            title: "可行性評估",
                            description: "6大行動路徑評估",
                            isCompleted: false,
                            isUnlocked: false
                        )
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("深化探索")
        }
    }
}

struct ExplorationStepCard: View {
    let title: String
    let description: String
    let isCompleted: Bool
    let isUnlocked: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 8) {
                Text(title)
                    .font(.headline)
                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            if isCompleted {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.title2)
            } else if isUnlocked {
                Image(systemName: "arrow.right.circle.fill")
                    .foregroundColor(.blue)
                    .font(.title2)
            } else {
                Image(systemName: "lock.fill")
                    .foregroundColor(.gray)
                    .font(.title2)
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
        .opacity(isUnlocked ? 1.0 : 0.6)
    }
}

#Preview {
    DeepeningExplorationView()
        .environmentObject(DataService.shared)
}
