import SwiftUI

struct LifeBlueprintView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: 12) {
                    Text("初版生命藍圖")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                    
                    Text("基於您的輸入，AI為您生成的個人化方向建議")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, 32)
                
                if viewModel.isLoadingBlueprint {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(.vertical, 60)
                } else if let blueprint = viewModel.lifeBlueprint {
                    VStack(spacing: 20) {
                        if !blueprint.vocationDirections.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("基礎天職猜測")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                ForEach(blueprint.vocationDirections) { direction in
                                    VocationDirectionCard(direction: direction)
                                }
                            }
                        }
                        
                        if !blueprint.strengthsSummary.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("優勢總結")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(blueprint.strengthsSummary)
                                    .font(.body)
                                    .lineSpacing(8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                        
                        if !blueprint.feasibilityAssessment.isEmpty {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("可行性初評")
                                    .font(.title2)
                                    .fontWeight(.semibold)
                                
                                Text(blueprint.feasibilityAssessment)
                                    .font(.body)
                                    .lineSpacing(8)
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color(.systemGray6))
                            .cornerRadius(12)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    Button(action: {
                        viewModel.saveProgress()
                        // ContentView will automatically navigate to MainTabView
                        // when hasCompletedInitialScan becomes true
                    }) {
                        Text("開始深化探索")
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
}

struct VocationDirectionCard: View {
    let direction: VocationDirection
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(direction.title)
                .font(.headline)
            
            Text(direction.description)
                .font(.subheadline)
                .foregroundColor(.secondary)
                .lineSpacing(4)
            
            HStack {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(.caption)
                Text(direction.marketFeasibility)
                    .font(.caption)
            }
            .foregroundColor(.blue)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}

#Preview {
    LifeBlueprintView()
        .environmentObject(InitialScanViewModel())
}
