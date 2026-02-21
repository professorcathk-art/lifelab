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
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                }
                .padding(.top, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                if viewModel.isLoadingBlueprint {
                    VStack(spacing: BrandSpacing.lg) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(BrandColors.actionAccent)
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
                                .foregroundColor(BrandColors.actionAccent)
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
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        
                        if !blueprint.vocationDirections.isEmpty {
                            VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                                HStack {
                                    Image(systemName: "sparkles")
                                        .foregroundColor(BrandColors.actionAccent)
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
                            .background(BrandColors.surface)
                            .cornerRadius(BrandRadius.medium)
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
                            .background(BrandColors.surface)
                            .cornerRadius(BrandRadius.medium)
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    
                    // Share/Export buttons
                    HStack(spacing: BrandSpacing.md) {
                        ShareLink(item: generateBlueprintText(blueprint: blueprint)) {
                            Label("分享", systemImage: "square.and.arrow.up")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.actionAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BrandSpacing.lg)
                                .background(BrandColors.actionAccent.opacity(0.1))
                                .cornerRadius(BrandRadius.medium)
                        }
                        
                        Button(action: {
                            exportBlueprintToFile(blueprint: blueprint)
                        }) {
                            Label("導出", systemImage: "doc.badge.plus")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.brandAccent)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, BrandSpacing.lg)
                                .background(BrandColors.brandAccent.opacity(0.1))
                                .cornerRadius(BrandRadius.medium)
                        }
                    }
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .padding(.bottom, BrandSpacing.xxxl)
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
            }
            .frame(maxWidth: .infinity)
        }
    }
    
    private func generateBlueprintText(blueprint: LifeBlueprint) -> String {
        var text = "我的生命藍圖\n\n"
        
        if !blueprint.vocationDirections.isEmpty {
            text += "基礎天職猜測：\n"
            for direction in blueprint.vocationDirections {
                text += "• \(direction.title)\n"
                text += "  \(direction.description)\n\n"
            }
        }
        
        if !blueprint.strengthsSummary.isEmpty {
            text += "優勢總結：\n\(blueprint.strengthsSummary)\n\n"
        }
        
        if !blueprint.feasibilityAssessment.isEmpty {
            text += "可行性初評：\n\(blueprint.feasibilityAssessment)\n"
        }
        
        return text
    }
    
    private func exportBlueprintToFile(blueprint: LifeBlueprint) {
        let text = generateBlueprintText(blueprint: blueprint)
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            rootViewController.present(activityVC, animated: true)
        }
    }
}

// MARK: - Vocation Direction Card with Data Chips
struct VocationDirectionCard: View {
    let direction: VocationDirection
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            Text(direction.title)
                .font(BrandTypography.headline)
                .foregroundColor(BrandColors.primaryText)
            
            Text(direction.description)
                .font(BrandTypography.subheadline)
                .foregroundColor(BrandColors.primaryText)
                .lineSpacing(6)
            
            // Data Chips - Small data labels with icons
            VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                // Market Feasibility
                if !direction.marketFeasibility.isEmpty {
                    DataChip(
                        icon: "chart.line.uptrend.xyaxis",
                        title: "市場需求",
                        value: direction.marketFeasibility
                    )
                }
                
                // Salary (if available in description or separate field)
                // You can add more data chips here based on your data model
            }
        }
        .padding(BrandSpacing.lg)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(BrandColors.surface)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(BrandColors.borderColor, lineWidth: 1)
        )
        .shadow(
            color: BrandColors.cardShadow.color,
            radius: BrandColors.cardShadow.radius,
            x: BrandColors.cardShadow.x,
            y: BrandColors.cardShadow.y
        )
    }
}

// MARK: - Data Chip Component (Theme-Aware)
struct DataChip: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        HStack(spacing: BrandSpacing.xs) {
            Image(systemName: icon)
                .font(.system(size: 12))
                .foregroundColor(BrandColors.actionAccent)
            
            Text(title)
                .font(BrandTypography.caption)
                .foregroundColor(
                    ThemeManager.shared.isDarkMode 
                        ? BrandColors.secondaryText
                        : BrandColors.dayModeDataChipText
                )
            
            Text(value)
                .font(BrandTypography.caption)
                .fontWeight(.semibold)
                .foregroundColor(BrandColors.actionAccent)
        }
        .padding(.horizontal, BrandSpacing.sm)
        .padding(.vertical, BrandSpacing.xs)
        .background(
            ThemeManager.shared.isDarkMode 
                ? BrandColors.surface.opacity(0.5) // Dark mode background
                : BrandColors.dayModeDataChipBackground // Very light purple in day mode
        )
        .cornerRadius(8)
    }
}

#Preview {
    LifeBlueprintView()
        .environmentObject(InitialScanViewModel())
}
