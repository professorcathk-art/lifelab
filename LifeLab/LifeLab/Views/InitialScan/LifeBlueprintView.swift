import SwiftUI
import UIKit

struct LifeBlueprintView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                VStack(spacing: BrandSpacing.md) {
                    Text("初版生命藍圖")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("基於您的輸入，AI為您生成的個人化方向建議")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, BrandSpacing.xxxl)
                
                if viewModel.isLoadingBlueprint {
                    VStack(spacing: BrandSpacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(BrandColors.primaryBlue)
                        Text("正在生成生命藍圖...")
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                        Text("這可能需要幾秒鐘時間")
                            .font(BrandTypography.caption)
                            .foregroundColor(BrandColors.tertiaryText)
                        
                        // Add retry button if loading takes too long
                        Button(action: {
                            // Force stop loading and use fallback
                            viewModel.isLoadingBlueprint = false
                            viewModel.generateLifeBlueprint()
                        }) {
                            Text("如果等待時間過長，點擊重試")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.primaryBlue)
                                .padding(.top, BrandSpacing.md)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.vertical, 60)
                } else if let blueprint = viewModel.lifeBlueprint {
                    VStack(spacing: BrandSpacing.xl) {
                        // Version indicator
                        HStack {
                            Text("Version \(blueprint.version)")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.secondaryText)
                            Spacer()
                            Text(blueprint.createdAt.formatted(date: .abbreviated, time: .omitted))
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.secondaryText)
                        }
                        .padding(.horizontal, BrandSpacing.xl)
                        
                        if !blueprint.vocationDirections.isEmpty {
                            VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(BrandColors.primaryBlue)
                                    Text("基礎天職猜測")
                                        .font(BrandTypography.title2)
                                        .foregroundColor(BrandColors.primaryText)
                                }
                                
                                ForEach(blueprint.vocationDirections) { direction in
                                    VocationDirectionCard(direction: direction)
                                }
                            }
                        }
                        
                        if !blueprint.strengthsSummary.isEmpty {
                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                Text("優勢總結")
                                    .font(BrandTypography.title2)
                                    .foregroundColor(BrandColors.primaryText)
                                
                                Text(blueprint.strengthsSummary)
                                    .font(BrandTypography.body)
                                    .foregroundColor(BrandColors.primaryText)
                                    .lineSpacing(8)
                            }
                            .padding(BrandSpacing.lg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(BrandColors.secondaryBackground)
                            .cornerRadius(BrandRadius.medium)
                            .shadow(color: BrandShadow.medium.color, radius: BrandShadow.medium.radius, x: BrandShadow.medium.x, y: BrandShadow.medium.y)
                        }
                        
                        if !blueprint.feasibilityAssessment.isEmpty {
                            VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                Text("可行性初評")
                                    .font(BrandTypography.title2)
                                    .foregroundColor(BrandColors.primaryText)
                                
                                Text(blueprint.feasibilityAssessment)
                                    .font(BrandTypography.body)
                                    .foregroundColor(BrandColors.primaryText)
                                    .lineSpacing(8)
                            }
                            .padding(BrandSpacing.lg)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(BrandColors.secondaryBackground)
                            .cornerRadius(BrandRadius.medium)
                            .shadow(color: BrandShadow.medium.color, radius: BrandShadow.medium.radius, x: BrandShadow.medium.x, y: BrandShadow.medium.y)
                        }
                    }
                    .padding(.horizontal, BrandSpacing.xl)
                    
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
                                .foregroundColor(Color(hex: "10b6cc"))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BrandSpacing.lg)
                                .background(Color(hex: "10b6cc").opacity(0.1))
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
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            Text(direction.title)
                .font(BrandTypography.headline)
                .foregroundColor(BrandColors.primaryText)
            
            Text(direction.description)
                .font(BrandTypography.subheadline)
                .foregroundColor(BrandColors.secondaryText)
                .lineSpacing(6)
            
            HStack(spacing: BrandSpacing.xs) {
                Image(systemName: "chart.line.uptrend.xyaxis")
                    .font(BrandTypography.caption)
                Text(direction.marketFeasibility)
                    .font(BrandTypography.caption)
            }
            .foregroundColor(BrandColors.primaryBlue)
        }
        .padding(BrandSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandColors.secondaryBackground)
        .cornerRadius(BrandRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: BrandRadius.medium)
                .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
        )
        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
    }
}

#Preview {
    LifeBlueprintView()
        .environmentObject(InitialScanViewModel())
}
