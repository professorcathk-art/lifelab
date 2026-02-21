import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: BrandSpacing.xl) {
                    if let profile = dataService.userProfile {
                        VStack(spacing: BrandSpacing.lg) {
                            VStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundColor(BrandColors.brandAccent) // Golden yellow
                                
                                Text("個人檔案")
                                    .font(BrandTypography.largeTitle)
                                    .foregroundColor(BrandColors.primaryText)
                            }
                            .padding(.top, BrandSpacing.xxxl)
                            .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            
                            // Venn Diagram - Premium Neon-Glow Style
                            if !profile.interests.isEmpty && !profile.strengths.isEmpty && !profile.values.isEmpty {
                                VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                    Text("關鍵詞總覽")
                                        .font(BrandTypography.title2)
                                        .foregroundColor(BrandColors.primaryText)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    
                                    BlueprintVennDiagramView(
                                        interests: profile.interests,
                                        strengths: profile.strengths.flatMap { $0.selectedKeywords },
                                        values: profile.values.filter { !$0.isGreyedOut }.map { $0.value.rawValue }
                                    )
                                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                }
                                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                            }
                            
                            if !profile.interests.isEmpty {
                                ProfileSection(title: "興趣", items: profile.interests)
                                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            }
                            
                            if !profile.strengths.isEmpty {
                                ProfileSection(title: "天賦", items: profile.strengths.flatMap { $0.selectedKeywords })
                                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                            }
                            
                            if !profile.values.isEmpty {
                                VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                    Text("核心價值觀")
                                        .font(BrandTypography.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(BrandColors.primaryText)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    
                                    ForEach(profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(5)) { value in
                                        HStack(spacing: BrandSpacing.sm) {
                                            Text("\(value.rank)")
                                                .font(BrandTypography.headline)
                                                .foregroundColor(BrandColors.actionAccent) // Purple
                                                .frame(width: 24, height: 24)
                                                .background(BrandColors.actionAccent.opacity(0.1))
                                                .cornerRadius(BrandRadius.small)
                                            Text(value.value.rawValue)
                                                .font(BrandTypography.headline)
                                                .foregroundColor(BrandColors.primaryText)
                                            Spacer()
                                        }
                                        .padding(BrandSpacing.lg)
                                        .background(BrandColors.surface) // #1C1C1E
                                        .cornerRadius(BrandRadius.medium)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    }
                                }
                                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                            }
                            
                            // AI 分析總結
                            if let summary = getAISummary() {
                                VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                    Text("AI 分析總結")
                                        .font(BrandTypography.title2)
                                        .fontWeight(.semibold)
                                        .foregroundColor(BrandColors.primaryText)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    
                                    Text(summary)
                                        .font(BrandTypography.body)
                                        .lineSpacing(8)
                                        .foregroundColor(BrandColors.primaryText) // Pure white
                                        .padding(BrandSpacing.lg)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(BrandColors.surface) // #1C1C1E
                                        .cornerRadius(12)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                }
                                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                            }
                            
                            // 生命藍圖 (show all versions)
                            if !profile.lifeBlueprints.isEmpty || profile.lifeBlueprint != nil {
                                VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                                    Text("生命藍圖")
                                        .font(BrandTypography.title2)
                                        .foregroundColor(BrandColors.primaryText)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    
                                    // Show all versions - combine lifeBlueprint and lifeBlueprints
                                    let allBlueprints: [LifeBlueprint] = {
                                        var blueprints = profile.lifeBlueprints
                                        // Add current lifeBlueprint if it's not already in the array
                                        if let currentBlueprint = profile.lifeBlueprint {
                                            if !blueprints.contains(where: { $0.version == currentBlueprint.version && abs($0.createdAt.timeIntervalSince(currentBlueprint.createdAt)) < 1 }) {
                                                blueprints.append(currentBlueprint)
                                            }
                                        }
                                        // Sort by version (newest first)
                                        return blueprints.sorted { $0.version > $1.version }
                                    }()
                                    
                                    ForEach(allBlueprints, id: \.version) { blueprint in
                                        VStack(alignment: .leading, spacing: BrandSpacing.md) {
                                            HStack {
                                                Text("Version \(blueprint.version)")
                                                    .font(BrandTypography.headline)
                                                    .foregroundColor(BrandColors.actionAccent) // Purple
                                                Spacer()
                                                Text(blueprint.createdAt.formatted(date: .abbreviated, time: .omitted))
                                                    .font(BrandTypography.caption)
                                                    .foregroundColor(BrandColors.secondaryText)
                                            }
                                            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                            
                                            if !blueprint.vocationDirections.isEmpty {
                                                ForEach(blueprint.vocationDirections) { direction in
                                                    VocationDirectionCard(direction: direction)
                                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                                }
                                            }
                                            
                                            if !blueprint.strengthsSummary.isEmpty {
                                                VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                                                    Text("優勢總結")
                                                        .font(BrandTypography.headline)
                                                        .foregroundColor(BrandColors.primaryText)
                                                    Text(blueprint.strengthsSummary)
                                                        .font(BrandTypography.body)
                                                        .foregroundColor(BrandColors.primaryText)
                                                        .lineSpacing(8)
                                                }
                                                .padding(BrandSpacing.lg)
                                                .frame(maxWidth: .infinity, alignment: .leading)
                                                .background(BrandColors.surface) // #1C1C1E
                                                .cornerRadius(BrandRadius.medium)
                                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                            }
                                        }
                                        .padding(BrandSpacing.lg)
                                        .background(BrandColors.surface) // #1C1C1E
                                        .cornerRadius(16)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    }
                                }
                                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                            } else if let blueprint = profile.lifeBlueprint {
                                VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                                    Text("初版生命藍圖")
                                        .font(BrandTypography.title2)
                                        .foregroundColor(BrandColors.primaryText)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    
                                    if !blueprint.vocationDirections.isEmpty {
                                        ForEach(blueprint.vocationDirections) { direction in
                                            VocationDirectionCard(direction: direction)
                                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                        }
                                    }
                                    
                                    if !blueprint.strengthsSummary.isEmpty {
                                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                                            Text("優勢總結")
                                                .font(BrandTypography.headline)
                                                .foregroundColor(BrandColors.primaryText)
                                            Text(blueprint.strengthsSummary)
                                                .font(BrandTypography.body)
                                                .foregroundColor(BrandColors.primaryText)
                                                .lineSpacing(8)
                                        }
                                        .padding(BrandSpacing.lg)
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(BrandColors.surface) // #1C1C1E
                                        .cornerRadius(12)
                                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                                    }
                                }
                                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                            }
                        }
                    } else {
                        VStack(spacing: BrandSpacing.md) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 60))
                                .foregroundColor(BrandColors.secondaryText)
                            Text("尚未建立個人檔案")
                                .font(BrandTypography.headline)
                                .foregroundColor(BrandColors.secondaryText)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                }
                .padding(.vertical)
                .frame(maxWidth: .infinity)
            }
            .background(BrandColors.background)
            .navigationTitle("個人檔案")
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if dataService.userProfile?.lifeBlueprint != nil {
                        NavigationLink(destination: ReviewInitialScanView()) {
                            Text("檢視")
                                .foregroundColor(BrandColors.actionAccent) // Purple
                        }
                    }
                }
            }
        }
    }
    
    private func getAISummary() -> String? {
        // Get AI summary from saved profile or generate from data
        if let profile = dataService.userProfile {
            // Try to get from InitialScanViewModel if available
            // For now, generate from profile data
            let interestsText = profile.interests.joined(separator: "、")
            let strengthsText = profile.strengths.flatMap { $0.selectedKeywords }.joined(separator: "、")
            let topValues = profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(3).map { $0.value.rawValue }.joined(separator: "、")
            
            if !interestsText.isEmpty || !strengthsText.isEmpty || !topValues.isEmpty {
                var summary = "根據您的輸入，我們發現以下關鍵特質：\n\n"
                if !interestsText.isEmpty {
                    summary += "**興趣關鍵詞**：\(interestsText)\n\n"
                }
                if !strengthsText.isEmpty {
                    summary += "**天賦關鍵詞**：\(strengthsText)\n\n"
                }
                if !topValues.isEmpty {
                    summary += "**核心價值觀**：\(topValues)\n\n"
                }
                summary += "這些特質顯示您是一個具有獨特優勢的人。"
                return summary
            }
        }
        return nil
    }
}

// MARK: - Profile Section with Minimalist Tags
struct ProfileSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.md) {
            Text(title)
                .font(BrandTypography.title2)
                .fontWeight(.semibold)
                .foregroundColor(BrandColors.primaryText)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: BrandSpacing.sm) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.primaryText)
                            .padding(.horizontal, BrandSpacing.md)
                            .padding(.vertical, BrandSpacing.sm)
                            .background(BrandColors.surface)
                            .overlay(
                                RoundedRectangle(cornerRadius: BrandRadius.large)
                                    .stroke(BrandColors.borderColor, lineWidth: 1)
                            )
                            .cornerRadius(BrandRadius.large) // Capsule shape
                    }
                }
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataService.shared)
}
