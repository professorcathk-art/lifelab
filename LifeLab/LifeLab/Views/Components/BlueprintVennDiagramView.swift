import SwiftUI

/// Premium Neon-Glow Style Venn Diagram for Life Blueprint
/// 具備頂級質感的深色發光風格文氏圖
struct BlueprintVennDiagramView: View {
    let interests: [String]
    let strengths: [String]
    let values: [String]
    
    // Breathing animation state
    @State private var breathingScale: CGFloat = 1.0
    
    // Color palette (霓虹發光色系)
    private let strengthColor = Color(hex: "8B5CF6") // 霓虹紫 - 天賦
    private let interestColor = Color(hex: "3B82F6") // 科技藍 - 興趣
    private let valueColor = Color(hex: "FFC107")   // 晨曦金 - 價值觀
    
    // Circle dimensions (further reduced for better fit)
    private let circleRadius: CGFloat = 60  // Further reduced from 65
    private let centerOffset: CGFloat = 38   // Further reduced from 40
    
    var body: some View {
        VStack(spacing: 0) {
            GeometryReader { geometry in
                let centerX = geometry.size.width / 2
                // Move diagram down to ensure "天賦" label is visible
                // Add offset to push content down by ~40 points
                let centerY = geometry.size.height / 2 + 40
                
                ZStack {
                    // MARK: - Circle 1: Strengths (Top) - 天賦
                    Circle()
                        .fill(strengthColor.opacity(0.15)) // Low opacity fill
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(x: centerX, y: centerY - centerOffset)
                        .blendMode(.screen) // Blend mode for glow effect
                        .overlay(
                            Circle()
                                .stroke(strengthColor, lineWidth: 1.5)
                                .frame(width: circleRadius * 2, height: circleRadius * 2)
                                .position(x: centerX, y: centerY - centerOffset)
                                .shadow(color: strengthColor.opacity(0.5), radius: 4, x: 0, y: 0)
                        )
                        .scaleEffect(breathingScale)
                    
                    // MARK: - Circle 2: Interests (Left Bottom) - 興趣
                    Circle()
                        .fill(interestColor.opacity(0.15)) // Low opacity fill
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(x: centerX - centerOffset, y: centerY)
                        .blendMode(.screen) // Blend mode for glow effect
                        .overlay(
                            Circle()
                                .stroke(interestColor, lineWidth: 1.5)
                                .frame(width: circleRadius * 2, height: circleRadius * 2)
                                .position(x: centerX - centerOffset, y: centerY)
                                .shadow(color: interestColor.opacity(0.5), radius: 4, x: 0, y: 0)
                        )
                        .scaleEffect(breathingScale)
                    
                    // MARK: - Circle 3: Values (Right Bottom) - 價值觀
                    Circle()
                        .fill(valueColor.opacity(0.15)) // Low opacity fill
                        .frame(width: circleRadius * 2, height: circleRadius * 2)
                        .position(x: centerX + centerOffset, y: centerY)
                        .blendMode(.screen) // Blend mode for glow effect
                        .overlay(
                            Circle()
                                .stroke(valueColor, lineWidth: 1.5)
                                .frame(width: circleRadius * 2, height: circleRadius * 2)
                                .position(x: centerX + centerOffset, y: centerY)
                                .shadow(color: valueColor.opacity(0.5), radius: 4, x: 0, y: 0)
                        )
                        .scaleEffect(breathingScale)
                    
                    // MARK: - Outer Labels (外圍標籤) - 在圓形最外側
                    // Top: Strengths (天賦)
                    VStack(spacing: 4) {
                        Image(systemName: "sparkles")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(strengthColor)
                        Text("天賦")
                            .font(.subheadline.bold())
                            .foregroundColor(BrandColors.primaryText) // Pure white
                    }
                    .position(x: centerX, y: centerY - centerOffset - circleRadius - 30)  // Further increased spacing for label visibility
                    
                    // Left Bottom: Interests (興趣)
                    VStack(spacing: 4) {
                        Image(systemName: "heart.fill")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(interestColor)
                        Text("興趣")
                            .font(.subheadline.bold())
                            .foregroundColor(BrandColors.primaryText) // Pure white
                    }
                    .position(x: centerX - centerOffset - circleRadius - 20, y: centerY)  // Increased spacing for label visibility
                    
                    // Right Bottom: Values (價值觀)
                    VStack(spacing: 4) {
                        Image(systemName: "target")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(valueColor)
                        Text("價值觀")
                            .font(.subheadline.bold())
                            .foregroundColor(BrandColors.primaryText) // Pure white
                    }
                    .position(x: centerX + centerOffset + circleRadius + 15, y: centerY)  // Reduced spacing
                    
                    // MARK: - Core Intersection (中心交集點) - The Ikigai
                    VStack(spacing: 8) {
                        // Glowing gradient icon
                        Image(systemName: "sparkles")
                            .font(.system(size: 24, weight: .light))
                            .foregroundStyle(
                                LinearGradient(
                                    gradient: Gradient(colors: [
                                        strengthColor,
                                        interestColor,
                                        valueColor
                                    ]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .shadow(color: strengthColor.opacity(0.6), radius: 8, x: 0, y: 0)
                            .shadow(color: interestColor.opacity(0.6), radius: 8, x: 0, y: 0)
                            .shadow(color: valueColor.opacity(0.6), radius: 8, x: 0, y: 0)
                        
                        Text("我的藍圖")
                            .font(.caption.bold())
                            .foregroundColor(BrandColors.primaryText) // Pure white
                    }
                    .position(x: centerX, y: centerY)
                }
            }
            .frame(height: 220)  // Increased height to accommodate downward shift and ensure "天賦" label is visible
        }
        .padding(BrandSpacing.lg)
        .background(BrandColors.surface) // #1C1C1E
        .cornerRadius(16)
        .onAppear {
            startBreathingAnimation()
        }
    }
    
    // MARK: - Breathing Animation
    private func startBreathingAnimation() {
        withAnimation(.easeInOut(duration: 3.0).repeatForever(autoreverses: true)) {
            breathingScale = 1.02
        }
    }
}

#Preview {
    BlueprintVennDiagramView(
        interests: ["設計", "寫作", "音樂", "攝影"],
        strengths: ["創意", "溝通", "問題解決", "設計"],
        values: ["創新", "成長", "意義", "創意"]
    )
    .background(BrandColors.background)
    .padding()
}
