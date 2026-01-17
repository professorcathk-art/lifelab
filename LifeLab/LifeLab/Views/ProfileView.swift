import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    if let profile = dataService.userProfile {
                        VStack(spacing: BrandSpacing.lg) {
                            VStack(spacing: BrandSpacing.sm) {
                                Image(systemName: "person.circle.fill")
                                    .font(.system(size: 60))
                                    .foregroundStyle(BrandColors.primaryGradient)
                                
                                Text("個人檔案")
                                    .font(BrandTypography.largeTitle)
                                    .foregroundColor(BrandColors.primaryText)
                            }
                            .padding(.top, BrandSpacing.xxxl)
                            
                            if !profile.interests.isEmpty {
                                ProfileSection(title: "興趣", items: profile.interests)
                            }
                            
                            if !profile.strengths.isEmpty {
                                ProfileSection(title: "天賦", items: profile.strengths.flatMap { $0.selectedKeywords })
                            }
                            
                            if !profile.values.isEmpty {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("核心價值觀")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 20)
                                    
                                    ForEach(profile.values.sorted { $0.rank < $1.rank && !$0.isGreyedOut }.prefix(5)) { value in
                                        HStack(spacing: BrandSpacing.sm) {
                                            Text("\(value.rank)")
                                                .font(BrandTypography.headline)
                                                .foregroundColor(BrandColors.primaryBlue)
                                                .frame(width: 24, height: 24)
                                                .background(BrandColors.primaryBlue.opacity(0.1))
                                                .cornerRadius(BrandRadius.small)
                                            Text(value.value.rawValue)
                                                .font(BrandTypography.headline)
                                                .foregroundColor(BrandColors.primaryText)
                                            Spacer()
                                        }
                                        .padding(BrandSpacing.lg)
                                        .background(BrandColors.secondaryBackground)
                                        .cornerRadius(BrandRadius.medium)
                                        .shadow(color: BrandShadow.small.color, radius: BrandShadow.small.radius, x: BrandShadow.small.x, y: BrandShadow.small.y)
                                        .padding(.horizontal, BrandSpacing.xl)
                                    }
                                }
                            }
                            
                            // AI 分析總結
                            if let summary = getAISummary() {
                                VStack(alignment: .leading, spacing: 12) {
                                    Text("AI 分析總結")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 20)
                                    
                                    Text(summary)
                                        .font(.body)
                                        .lineSpacing(8)
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 20)
                                }
                            }
                            
                            // 初版生命藍圖
                            if let blueprint = profile.lifeBlueprint {
                                VStack(alignment: .leading, spacing: 16) {
                                    Text("初版生命藍圖")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                        .padding(.horizontal, 20)
                                    
                                    if !blueprint.vocationDirections.isEmpty {
                                        ForEach(blueprint.vocationDirections) { direction in
                                            VocationDirectionCard(direction: direction)
                                                .padding(.horizontal, 20)
                                        }
                                    }
                                    
                                    if !blueprint.strengthsSummary.isEmpty {
                                        VStack(alignment: .leading, spacing: 8) {
                                            Text("優勢總結")
                                                .font(.headline)
                                            Text(blueprint.strengthsSummary)
                                                .font(.body)
                                                .lineSpacing(8)
                                        }
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color(.systemGray6))
                                        .cornerRadius(12)
                                        .padding(.horizontal, 20)
                                    }
                                }
                            }
                        }
                    } else {
                        VStack(spacing: 16) {
                            Image(systemName: "person.circle")
                                .font(.system(size: 60))
                                .foregroundColor(.gray)
                            Text("尚未建立個人檔案")
                                .font(.headline)
                                .foregroundColor(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(.top, 100)
                    }
                }
                .padding(.vertical)
            }
            .navigationTitle("個人檔案")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    if dataService.userProfile?.lifeBlueprint != nil {
                        NavigationLink(destination: ReviewInitialScanView()) {
                            Text("檢視")
                                .foregroundColor(.blue)
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

struct ProfileSection: View {
    let title: String
    let items: [String]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.title2)
                .fontWeight(.semibold)
                .padding(.horizontal, 20)
            
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(items, id: \.self) { item in
                        Text(item)
                            .font(.subheadline)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(Color.blue.opacity(0.1))
                            .foregroundColor(.blue)
                            .cornerRadius(16)
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    ProfileView()
        .environmentObject(DataService.shared)
}
