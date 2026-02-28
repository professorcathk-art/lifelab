import SwiftUI

/// BlueprintGenerationProgressView - Shows progress while AI generates the life blueprint
/// Supports both light and dark mode with consistent UI style
struct BlueprintGenerationProgressView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @StateObject private var themeManager = ThemeManager.shared
    @State private var animatedProgress: Double = 0.0
    @State private var currentStepIndex: Int = 0
    
    private let steps = [
        "正在分析您的興趣與天賦...",
        "識別您的核心價值觀...",
        "匹配最佳職業方向...",
        "評估市場可行性...",
        "生成個人化建議...",
        "即將完成..."
    ]
    
    var body: some View {
        ZStack {
            // Background - theme-aware
            BrandColors.background
                .ignoresSafeArea()
                .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            
            VStack(spacing: BrandSpacing.xxl) {
                Spacer()
                
                // Animated icon with sparkles
                ZStack {
                    // Outer circle - theme-aware
                    Circle()
                        .stroke(
                            themeManager.isDarkMode 
                                ? BrandColors.actionAccent.opacity(0.2) 
                                : BrandColors.actionAccent.opacity(0.1),
                            lineWidth: 4
                        )
                        .frame(width: 120, height: 120)
                    
                    // Progress circle - purple gradient
                    Circle()
                        .trim(from: 0, to: animatedProgress)
                        .stroke(
                            BrandColors.actionAccent,
                            style: StrokeStyle(lineWidth: 4, lineCap: .round)
                        )
                        .frame(width: 120, height: 120)
                        .rotationEffect(.degrees(-90))
                        .animation(.linear(duration: 0.2), value: animatedProgress)
                    
                    // Sparkle icon - rotating
                    Image(systemName: "sparkles")
                        .font(.system(size: 50))
                        .foregroundColor(BrandColors.actionAccent)
                        .rotationEffect(.degrees(animatedProgress * 360))
                        .animation(.linear(duration: 2.0).repeatForever(autoreverses: false), value: animatedProgress)
                }
                
                // Title and description
                VStack(spacing: BrandSpacing.md) {
                    Text("正在為您生成生命藍圖")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(
                            themeManager.isDarkMode 
                                ? Color.white 
                                : Color(hex: "2C2C2E")
                        )
                        .multilineTextAlignment(.center)
                    
                    Text(currentStepText)
                        .font(BrandTypography.subheadline)
                        .foregroundColor(
                            themeManager.isDarkMode 
                                ? Color(hex: "EBEBF5").opacity(0.6)
                                : Color(hex: "3C3C43").opacity(0.6)
                        )
                        .multilineTextAlignment(.center)
                        .animation(.easeInOut(duration: 0.5), value: currentStepIndex)
                        .frame(height: 40) // Fixed height to prevent layout shift
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                
                // Progress bar - theme-aware
                VStack(spacing: BrandSpacing.sm) {
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: BrandRadius.large)
                                .fill(
                                    themeManager.isDarkMode 
                                        ? Color.white.opacity(0.1)
                                        : Color.black.opacity(0.1)
                                )
                                .frame(height: 8)
                            
                            // Progress fill - purple
                            RoundedRectangle(cornerRadius: BrandRadius.large)
                                .fill(BrandColors.actionAccent)
                                .frame(width: geometry.size.width * animatedProgress, height: 8)
                                .animation(.linear(duration: 0.2), value: animatedProgress)
                        }
                    }
                    .frame(height: 8)
                    
                    // Percentage text - theme-aware
                    Text("\(Int(animatedProgress * 100))%")
                        .font(BrandTypography.headline)
                        .foregroundColor(BrandColors.actionAccent)
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                .padding(.top, BrandSpacing.md)
                
                Spacer()
            }
        }
        .onAppear {
            startProgressAnimation()
        }
        .onChange(of: viewModel.isLoadingBlueprint) { isLoading in
            if !isLoading {
                // AI generation completed, animate to 100%
                withAnimation(.easeOut(duration: 0.5)) {
                    animatedProgress = 1.0
                    currentStepIndex = steps.count - 1
                }
            }
        }
    }
    
    private var currentStepText: String {
        guard currentStepIndex < steps.count else {
            return steps.last ?? "即將完成..."
        }
        return steps[currentStepIndex]
    }
    
    private func startProgressAnimation() {
        // Simulate progress based on actual loading state
        // Update progress based on viewModel.isLoadingBlueprint
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
            Task { @MainActor in
                // If still loading, gradually increase progress
                if viewModel.isLoadingBlueprint {
                    // Animate progress from 0 to 90% while loading
                    if animatedProgress < 0.9 {
                        animatedProgress += 0.01
                        
                        // Update step text based on progress
                        let stepIndex = Int(animatedProgress * Double(steps.count - 1))
                        if stepIndex != currentStepIndex && stepIndex < steps.count {
                            currentStepIndex = stepIndex
                        }
                    }
                } else {
                    // Loading completed, animate to 100%
                    timer.invalidate()
                    withAnimation(.easeOut(duration: 0.5)) {
                        animatedProgress = 1.0
                        currentStepIndex = steps.count - 1
                    }
                }
            }
        }
    }
}

#Preview("Dark Mode") {
    BlueprintGenerationProgressView()
        .environmentObject(InitialScanViewModel())
        .preferredColorScheme(.dark)
}

#Preview("Light Mode") {
    BlueprintGenerationProgressView()
        .environmentObject(InitialScanViewModel())
        .preferredColorScheme(.light)
}
