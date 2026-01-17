import SwiftUI

struct DashboardView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let blueprint = dataService.userProfile?.lifeBlueprint {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("您的生命藍圖")
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            ForEach(blueprint.vocationDirections.prefix(2)) { direction in
                                VocationDirectionCard(direction: direction)
                            }
                        }
                        .padding()
                    }
                    
                    VStack(alignment: .leading, spacing: 16) {
                        Text("進度")
                            .font(.title2)
                            .fontWeight(.semibold)
                        
                        ProgressCard(title: "初步掃描", isCompleted: dataService.userProfile?.lifeBlueprint != nil)
                        ProgressCard(title: "深化探索", isCompleted: false)
                        ProgressCard(title: "行動計劃", isCompleted: dataService.userProfile?.actionPlan != nil)
                    }
                    .padding()
                }
                .padding(.vertical)
            }
            .navigationTitle("首頁")
        }
    }
}

struct ProgressCard: View {
    let title: String
    let isCompleted: Bool
    
    var body: some View {
        HStack {
            Text(title)
                .font(.headline)
            Spacer()
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isCompleted ? .green : .gray)
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    DashboardView()
        .environmentObject(DataService.shared)
}
