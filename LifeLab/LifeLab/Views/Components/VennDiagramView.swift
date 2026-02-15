import SwiftUI

struct VennDiagramView: View {
    let interests: [String]
    let strengths: [String]
    let values: [String]
    @State private var overlapSummary: String = ""
    @State private var isLoadingSummary = false
    
    private let circleRadius: CGFloat = 100
    private let centerOffset: CGFloat = 60
    
    // Calculate overlaps
    private var interestStrengthOverlap: [String] {
        Array(Set(interests).intersection(Set(strengths)))
    }
    
    private var interestValueOverlap: [String] {
        Array(Set(interests).intersection(Set(values)))
    }
    
    private var strengthValueOverlap: [String] {
        Array(Set(strengths).intersection(Set(values)))
    }
    
    private var allOverlap: [String] {
        Array(Set(interests).intersection(Set(strengths)).intersection(Set(values)))
    }
    
    var body: some View {
        VStack(spacing: BrandSpacing.lg) {
            GeometryReader { geometry in
                let centerX = geometry.size.width / 2
                let centerY = geometry.size.height / 2
                
                ZStack {
                    // Interest circle (left)
                    Circle()
                        .fill(BrandColors.skyBlue.opacity(0.25))
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(x: centerX - centerOffset, y: centerY)
                        .overlay(
                            Circle()
                                .stroke(BrandColors.skyBlue, lineWidth: 2.5)
                                .frame(width: circleRadius * 2, height: circleRadius * 2)
                                .position(x: centerX - centerOffset, y: centerY)
                        )
                    
                    // Strengths circle (top)
                    Circle()
                        .fill(BrandColors.accentTeal.opacity(0.25))
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(x: centerX, y: centerY - centerOffset)
                        .overlay(
                            Circle()
                                .stroke(BrandColors.accentTeal, lineWidth: 2.5)
                                .frame(width: circleRadius * 2, height: circleRadius * 2)
                                .position(x: centerX, y: centerY - centerOffset)
                        )
                    
                    // Values circle (right)
                    Circle()
                        .fill(BrandColors.accentPurple.opacity(0.25))
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(x: centerX + centerOffset, y: centerY)
                        .overlay(
                            Circle()
                                .stroke(BrandColors.accentPurple, lineWidth: 2.5)
                                .frame(width: circleRadius * 2, height: circleRadius * 2)
                                .position(x: centerX + centerOffset, y: centerY)
                        )
                    
                    // Keywords inside circles
                    // Interest keywords
                    VStack(spacing: 2) {
                        Text("興趣")
                            .font(BrandTypography.caption)
                            .foregroundColor(BrandColors.skyBlue)
                            .fontWeight(.bold)
                        ForEach(interests.prefix(3), id: \.self) { keyword in
                            Text(keyword)
                                .font(.system(size: 10))
                                .foregroundColor(BrandColors.primaryText)
                                .lineLimit(1)
                        }
                        if interests.count > 3 {
                            Text("+\(interests.count - 3)")
                                .font(.system(size: 9))
                                .foregroundColor(BrandColors.secondaryText)
                        }
                    }
                    .frame(width: circleRadius * 1.5)
                    .position(x: centerX - centerOffset, y: centerY)
                    
                    // Strengths keywords
                    VStack(spacing: 2) {
                        Text("天賦")
                            .font(BrandTypography.caption)
                            .foregroundColor(BrandColors.accentTeal)
                            .fontWeight(.bold)
                        ForEach(strengths.prefix(3), id: \.self) { keyword in
                            Text(keyword)
                                .font(.system(size: 10))
                                .foregroundColor(BrandColors.primaryText)
                                .lineLimit(1)
                        }
                        if strengths.count > 3 {
                            Text("+\(strengths.count - 3)")
                                .font(.system(size: 9))
                                .foregroundColor(BrandColors.secondaryText)
                        }
                    }
                    .frame(width: circleRadius * 1.5)
                    .position(x: centerX, y: centerY - centerOffset - 10)
                    
                    // Values keywords
                    VStack(spacing: 2) {
                        Text("價值觀")
                            .font(BrandTypography.caption)
                            .foregroundColor(BrandColors.accentPurple)
                            .fontWeight(.bold)
                        ForEach(values.prefix(3), id: \.self) { keyword in
                            Text(keyword)
                                .font(.system(size: 10))
                                .foregroundColor(BrandColors.primaryText)
                                .lineLimit(1)
                        }
                        if values.count > 3 {
                            Text("+\(values.count - 3)")
                                .font(.system(size: 9))
                                .foregroundColor(BrandColors.secondaryText)
                        }
                    }
                    .frame(width: circleRadius * 1.5)
                    .position(x: centerX + centerOffset, y: centerY)
                    
                    // Overlap areas with keywords
                    // Interest x Strength overlap
                    if !interestStrengthOverlap.isEmpty {
                        VStack(spacing: 1) {
                            ForEach(interestStrengthOverlap.prefix(2), id: \.self) { keyword in
                                Text(keyword)
                                    .font(.system(size: 9))
                                    .foregroundColor(BrandColors.primaryText)
                                    .fontWeight(.semibold)
                                    .lineLimit(1)
                            }
                        }
                        .padding(4)
                        .background(BrandColors.secondaryBackground.opacity(0.9))
                        .cornerRadius(6)
                        .position(x: centerX - centerOffset/2, y: centerY - centerOffset/2)
                    }
                    
                    // All overlap (center)
                    if !allOverlap.isEmpty {
                        VStack(spacing: 1) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 8))
                                .foregroundColor(BrandColors.accentYellow)
                            ForEach(allOverlap.prefix(1), id: \.self) { keyword in
                                Text(keyword)
                                    .font(.system(size: 9))
                                    .foregroundColor(BrandColors.primaryText)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                            }
                        }
                        .padding(4)
                        .background(BrandColors.accentYellow.opacity(0.2))
                        .cornerRadius(6)
                        .position(x: centerX, y: centerY)
                    }
                }
            }
            .frame(height: 250)
            .padding()
            
            // AI Summary for overlaps
            if !overlapSummary.isEmpty {
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("交集分析")
                        .font(BrandTypography.headline)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text(overlapSummary)
                        .font(BrandTypography.body)
                        .foregroundColor(BrandColors.secondaryText)
                        .lineSpacing(6)
                }
                .padding(BrandSpacing.lg)
                .background(BrandColors.secondaryBackground)
                .cornerRadius(BrandRadius.medium)
                .padding(.horizontal, BrandSpacing.xl)
            } else if isLoadingSummary {
                ProgressView()
                    .tint(BrandColors.primaryBlue)
            }
        }
        .onAppear {
            generateOverlapSummary()
        }
    }
    
    private func generateOverlapSummary() {
        guard !interests.isEmpty && !strengths.isEmpty && !values.isEmpty else { return }
        
        isLoadingSummary = true
        
        Task {
            do {
                let summary = try await AIService.shared.generateVennOverlapSummary(
                    interests: interests,
                    strengths: strengths,
                    values: values,
                    interestStrengthOverlap: interestStrengthOverlap,
                    interestValueOverlap: interestValueOverlap,
                    strengthValueOverlap: strengthValueOverlap,
                    allOverlap: allOverlap
                )
                
                await MainActor.run {
                    overlapSummary = summary
                    isLoadingSummary = false
                }
            } catch {
                await MainActor.run {
                    isLoadingSummary = false
                    // Fallback summary
                    if !allOverlap.isEmpty {
                        overlapSummary = "您的興趣、天賦和價值觀在「\(allOverlap.joined(separator: "、"))」方面高度一致，這表示這些領域對您來說特別重要且自然。"
                    } else if !interestStrengthOverlap.isEmpty {
                        overlapSummary = "您的興趣和天賦在「\(interestStrengthOverlap.joined(separator: "、"))」方面重疊，這可能是您最適合發展的方向。"
                    } else {
                        overlapSummary = "您的興趣、天賦和價值觀各有特色，這為您提供了多元的發展可能性。"
                    }
                }
            }
        }
    }
}

#Preview {
    VennDiagramView(
        interests: ["設計", "寫作", "音樂", "攝影"],
        strengths: ["創意", "溝通", "問題解決", "設計"],
        values: ["創新", "成長", "意義", "創意"]
    )
    .background(BrandColors.background)
}
