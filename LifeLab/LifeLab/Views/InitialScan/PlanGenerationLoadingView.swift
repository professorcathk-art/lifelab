import SwiftUI

struct PlanGenerationLoadingView: View {
    @State private var progress: Double = 0.0
    @State private var currentStep: String = "正在分析您的資料..."
    let onComplete: () -> Void
    
    private let steps = [
        (0.0, "正在分析您的資料..."),
        (0.2, "識別您的核心優勢..."),
        (0.4, "匹配最佳職業方向..."),
        (0.6, "評估市場可行性..."),
        (0.8, "生成個人化建議..."),
        (1.0, "即將完成...")
    ]
    
    var body: some View {
        ZStack {
            // Background gradient
            LinearGradient(
                colors: [
                    BrandColors.primaryBlue.opacity(0.1),
                    BrandColors.accentTeal.opacity(0.05),
                    BrandColors.background
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            VStack(spacing: BrandSpacing.xxl) {
                Spacer()
                
                // Animated icon
                ZStack {
                    Circle()
                        .stroke(BrandColors.primaryBlue.opacity(0.2), lineWidth: 4)
                        .frame(width: 120, height: 120)
                    
                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            BrandColors.primaryGradient,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.1), value: progress)
                    
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundStyle(BrandColors.primaryGradient)
                        .rotationEffect(.degrees(progress * 360))
                        .animation(.linear(duration: 1.0).repeatForever(autoreverses: false), value: progress)
                }
                
                VStack(spacing: BrandSpacing.md) {
                    Text("正在為您生成生命藍圖")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                        .multilineTextAlignment(.center)
                    
                    Text(currentStep)
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                
                // Progress bar
                VStack(spacing: BrandSpacing.sm) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: BrandRadius.large)
                                .fill(BrandColors.tertiaryBackground)
                                .frame(height: 8)
                            
                            RoundedRectangle(cornerRadius: BrandRadius.large)
                                .fill(BrandColors.primaryGradient)
                                .frame(width: geometry.size.width * progress, height: 8)
                                .animation(.linear(duration: 0.1), value: progress)
                        }
                    }
                    .frame(height: 8)
                    
                    Text("\(Int(progress * 100))%")
                        .font(BrandTypography.headline)
                        .foregroundColor(BrandColors.primaryBlue)
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                
                Spacer()
            }
        }
        .onAppear {
            startProgressAnimation()
        }
    }
    
    private func startProgressAnimation() {
        let duration: TimeInterval = 3.0
        let stepsPerSecond = 30.0
        let increment = 1.0 / (duration * stepsPerSecond)
        
        Timer.scheduledTimer(withTimeInterval: 1.0 / stepsPerSecond, repeats: true) { timer in
            if progress < 1.0 {
                progress += increment
                
                // Update step text
                if let step = steps.last(where: { progress >= $0.0 }) {
                    if currentStep != step.1 {
                        currentStep = step.1
                    }
                }
            } else {
                timer.invalidate()
                progress = 1.0
                currentStep = "完成！"
                
                // Wait a moment then complete
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onComplete()
                }
            }
        }
    }
}

#Preview {
    PlanGenerationLoadingView {
        print("Complete!")
    }
}
