import SwiftUI

struct WelcomeIntroView: View {
    @AppStorage("hasSeenWelcomeIntro") private var hasSeenWelcomeIntro = false
    @State private var heroScale: CGFloat = 0.95
    @State private var heroOpacity: Double = 0.8
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            // Background: Pure black with subtle dark purple radial gradient
            Color.black
                .ignoresSafeArea()
            
            // Subtle radial gradient overlay (very dark purple to black)
            RadialGradient(
                gradient: Gradient(colors: [
                    Color(hex: "1C0B3B").opacity(0.3), // Very subtle dark purple
                    Color.black
                ]),
                center: .top,
                startRadius: 100,
                endRadius: 600
            )
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                Spacer()
                
                // Hero Graphic with Breathing Animation
                ZStack {
                    // Glow effect (subtle)
                    Circle()
                        .fill(
                            RadialGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "8B5CF6").opacity(0.2),
                                    Color.clear
                                ]),
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .blur(radius: 30)
                        .scaleEffect(heroScale)
                        .opacity(heroOpacity)
                    
                    // Main Icon
                    Image(systemName: "sparkles")
                        .font(.system(size: 80, weight: .light))
                        .foregroundStyle(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "8B5CF6"), // Neon purple
                                    Color(hex: "D8B4FE")  // Light purple
                                ]),
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .scaleEffect(heroScale)
                        .opacity(heroOpacity)
                        .shadow(color: Color(hex: "8B5CF6").opacity(0.5), radius: 20, x: 0, y: 0)
                }
                .padding(.bottom, BrandSpacing.xxxl)
                
                // Copywriting Section with Fade-in Animation
                VStack(spacing: BrandSpacing.lg) {
                    // Main Headline
                    Text("不要只是過日子，\n開始創造你的人生。")
                        .font(BrandTypography.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.primaryText) // Pure white
                        .multilineTextAlignment(.center)
                        .lineSpacing(8)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                    
                    // Subtitle / Value Proposition
                    Text("透過 AI 深度洞察你的天賦與熱情，生成專屬行動藍圖。這不僅是探索，更是改變的開始。")
                        .font(BrandTypography.title3)
                        .foregroundColor(BrandColors.secondaryText) // #8E8E93
                        .multilineTextAlignment(.center)
                        .lineSpacing(6)
                        .padding(.horizontal, BrandSpacing.xl)
                        .opacity(contentOpacity)
                        .offset(y: contentOffset)
                }
                .padding(.horizontal, BrandSpacing.lg)
                .padding(.bottom, BrandSpacing.xxxl)
                
                Spacer()
            }
            
            // Bottom Action Area (Fixed at bottom)
            VStack {
                Spacer()
                
                VStack(spacing: BrandSpacing.md) {
                    // Primary CTA Button
                    Button(action: {
                        // Trigger transition to LoginView
                        withAnimation(.easeInOut(duration: 0.3)) {
                            hasSeenWelcomeIntro = true
                        }
                    }) {
                        HStack(spacing: BrandSpacing.sm) {
                            Text("開啟探索之旅")
                                .font(BrandTypography.headline)
                                .fontWeight(.bold)
                            Text("➔")
                                .font(BrandTypography.headline)
                                .fontWeight(.bold)
                        }
                        .foregroundColor(BrandColors.invertedText) // Pure white
                        .frame(maxWidth: .infinity)
                        .frame(height: 56)
                        .background(
                            LinearGradient(
                                gradient: Gradient(colors: [
                                    Color(hex: "6B4EFF"), // Serene purple
                                    Color(hex: "8B5CF6")  // Neon purple
                                ]),
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .clipShape(Capsule())
                        .shadow(color: Color(hex: "8B5CF6").opacity(0.3), radius: 12, x: 0, y: 6)
                    }
                    .buttonStyle(.plain)
                    .padding(.horizontal, BrandSpacing.lg)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
                .padding(.bottom, BrandSpacing.xl)
                .safeAreaInset(edge: .bottom) {
                    Color.clear.frame(height: 0)
                }
            }
        }
        .onAppear {
            // Start breathing animation for hero icon
            startBreathingAnimation()
            
            // Start fade-in animation for content
            withAnimation(.easeOut(duration: 0.8).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
    
    private func startBreathingAnimation() {
        // Breathing animation: scale from 0.95 to 1.05 and opacity from 0.8 to 1.0
        withAnimation(.easeInOut(duration: 2.5).repeatForever(autoreverses: true)) {
            heroScale = 1.05
            heroOpacity = 1.0
        }
    }
}

#Preview {
    WelcomeIntroView()
}
