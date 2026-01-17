import SwiftUI
import UIKit

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
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.5)
                        Text("正在生成生命藍圖...")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("這可能需要幾秒鐘時間")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
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
                    
                    // Share/Export buttons
                    HStack(spacing: BrandSpacing.md) {
                        ShareLink(item: generateBlueprintText(blueprint: blueprint)) {
                            Label("分享", systemImage: "square.and.arrow.up")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.primaryBlue)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BrandSpacing.lg)
                                .background(BrandColors.primaryBlue.opacity(0.1))
                                .cornerRadius(BrandRadius.medium)
                        }
                        
                        Button(action: {
                            exportBlueprintToFile(blueprint: blueprint)
                        }) {
                            Label("導出", systemImage: "doc.badge.plus")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.success)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BrandSpacing.lg)
                                .background(BrandColors.success.opacity(0.1))
                                .cornerRadius(BrandRadius.medium)
                        }
                    }
                    .padding(.horizontal, BrandSpacing.xl)
                    .padding(.bottom, BrandSpacing.xxxl)
                }
            }
        }
    }
    
    private func generateBlueprintText(blueprint: LifeBlueprint) -> String {
        var text = "我的生命藍圖\n\n"
        
        if !blueprint.vocationDirections.isEmpty {
            text += "基礎天職猜測：\n"
            for (index, direction) in blueprint.vocationDirections.enumerated() {
                text += "\n\(index + 1). \(direction.title)\n"
                text += "   \(direction.description)\n"
                text += "   市場可行性：\(direction.marketFeasibility)\n"
            }
            text += "\n"
        }
        
        if !blueprint.strengthsSummary.isEmpty {
            text += "優勢總結：\n\(blueprint.strengthsSummary)\n\n"
        }
        
        if !blueprint.feasibilityAssessment.isEmpty {
            text += "可行性初評：\n\(blueprint.feasibilityAssessment)\n"
        }
        
        text += "\n---\n由 LifeLab 生成"
        return text
    }
    
    private func exportBlueprintToFile(blueprint: LifeBlueprint) {
        let text = generateBlueprintText(blueprint: blueprint)
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: Date())
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("生命藍圖_\(dateString).txt")
        
        do {
            try text.write(to: url, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                // For iPad
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Export failed: \(error)")
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
