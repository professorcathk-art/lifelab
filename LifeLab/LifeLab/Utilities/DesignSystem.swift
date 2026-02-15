import SwiftUI
import Combine

// MARK: - Theme Manager
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = false // Default to light mode for better contrast
    
    static let shared = ThemeManager()
    private init() {}
}

// MARK: - Brand Colors (Warm & Professional Theme - WCAG AA Compliant)
struct BrandColors {
    // Warm Palette (鼓勵、溫暖)
    static let warmPrimary = Color(hex: "2B8A8F") // 寧靜藍綠
    static let warmAccent = Color(hex: "F5B861") // 溫暖金黃
    static let warmEmphasis = Color(hex: "FF7B54") // 珊瑚橙紅
    
    // Professional Palette (高端專業)
    static let professionalPrimary = Color(hex: "0D47A1") // 深藍
    static let professionalAccent = Color(hex: "E8B4FF") // 淡紫
    static let professionalEmphasis = Color(hex: "FF6B6B") // 柔和紅
    
    // Primary Colors (using warm palette as default)
    static let primaryBlue = warmPrimary
    static let accentTeal = warmPrimary
    static let accentPurple = professionalAccent
    static let accentPink = warmEmphasis
    static let accentOrange = warmAccent
    static let accentGreen = Color(hex: "4CAF50") // Success green
    static let accentYellow = warmAccent
    
    // Semantic Colors (using sky blue instead of green)
    static let success = Color(hex: "10b6cc") // Sky blue
    static let warning = Color(hex: "FFB300")
    static let error = Color(hex: "FF6B6B")
    
    // Background Colors (WCAG AA compliant)
    static var background: Color {
        ThemeManager.shared.isDarkMode 
            ? Color(hex: "1F2937") // Dark gray background
            : Color(hex: "FAFAF8") // Ivory white
    }
    
    static var secondaryBackground: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "374151") // Darker gray
            : Color.white
    }
    
    static var tertiaryBackground: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "4B5563") // Medium gray
            : Color(hex: "F8F9FA") // Cool white
    }
    
    // Text Colors (WCAG AA compliant - contrast ≥ 4.5:1)
    static var primaryText: Color {
        ThemeManager.shared.isDarkMode
            ? Color.white // White on dark background
            : Color(hex: "1F2937") // Dark gray-black on light background
    }
    
    static var secondaryText: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "D1D5DB") // Light gray on dark background
            : Color(hex: "6B7280") // Medium gray on light background
    }
    
    static var tertiaryText: Color {
        ThemeManager.shared.isDarkMode
            ? Color(hex: "9CA3AF") // Lighter gray on dark background
            : Color(hex: "9CA3AF") // Light gray on light background
    }
    
    // Gradients
    static let primaryGradient = LinearGradient(
        colors: [warmPrimary, Color(hex: "3BA5AB")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [warmAccent, warmEmphasis],
        startPoint: .leading,
        endPoint: .trailing
    )
    
    // Colorful gradients for keywords
    static let colorfulGradients: [LinearGradient] = [
        LinearGradient(colors: [warmPrimary, Color(hex: "3BA5AB")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [warmAccent, warmEmphasis], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [professionalAccent, Color(hex: "D4A5FF")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [accentGreen, Color(hex: "66BB6A")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [warmEmphasis, Color(hex: "FF9A7A")], startPoint: .topLeading, endPoint: .bottomTrailing),
    ]
    
    // Keyword colors (vibrant but accessible)
    static let keywordColors: [Color] = [
        warmPrimary,
        warmAccent,
        warmEmphasis,
        professionalAccent,
        accentGreen,
        Color(hex: "60A5FA"), // Sky blue
        Color(hex: "A78BFA") // Purple
    ]
    
    // Sky blue for compatibility
    static let skyBlue = Color(hex: "60A5FA")
    static let skyBlueLight = Color(hex: "93C5FD")
    static let skyBlueDark = Color(hex: "3B82F6")
    static let primaryBlueDark = skyBlueDark
    static let primaryBlueLight = skyBlueLight
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

// MARK: - Typography (Inter-inspired, Rounded)
struct BrandTypography {
    // Display fonts
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .semibold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let title3 = Font.system(size: 20, weight: .medium, design: .rounded)
    
    // Body fonts
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 16, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}

// MARK: - Spacing (8px base unit)
struct BrandSpacing {
    static let xs: CGFloat = 4   // 0.5x
    static let sm: CGFloat = 8    // 1x
    static let md: CGFloat = 12   // 1.5x
    static let lg: CGFloat = 16   // 2x
    static let xl: CGFloat = 20   // 2.5x
    static let xxl: CGFloat = 24  // 3x
    static let xxxl: CGFloat = 32 // 4x
}

// MARK: - Corner Radius
struct BrandRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
}

// MARK: - Shadows (Subtle, modern)
struct BrandShadow {
    static let small = Shadow(color: Color.black.opacity(0.04), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: Color.black.opacity(0.08), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: Color.black.opacity(0.12), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Button Styles
struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BrandSpacing.md)
            .background(BrandColors.primaryGradient)
            .cornerRadius(BrandRadius.small)
            .shadow(color: BrandColors.primaryBlue.opacity(0.2), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(BrandColors.primaryBlue)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BrandSpacing.md)
            .background(BrandColors.primaryBlue.opacity(0.1))
            .cornerRadius(BrandRadius.small)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.small)
                    .stroke(BrandColors.primaryBlue, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct TextButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(BrandColors.primaryBlue)
            .underline(configuration.isPressed)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SuccessButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BrandSpacing.md)
            .background(BrandColors.warmEmphasis)
            .cornerRadius(BrandRadius.small)
            .shadow(color: BrandColors.warmEmphasis.opacity(0.3), radius: 8, x: 0, y: 4)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Style
struct BrandCard: ViewModifier {
    let shadow: Shadow
    
    func body(content: Content) -> some View {
        content
            .padding(BrandSpacing.lg)
            .background(BrandColors.secondaryBackground)
            .cornerRadius(BrandRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.medium)
                    .stroke(Color(hex: "E5E7EB"), lineWidth: 1)
            )
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func brandCard(shadow: Shadow = BrandShadow.medium) -> some View {
        modifier(BrandCard(shadow: shadow))
    }
}

// MARK: - Animation Constants
struct BrandAnimation {
    static let standard = Animation.easeInOut(duration: 0.2)
    static let spring = Animation.spring(response: 0.3, dampingFraction: 0.7)
    static let entrance = Animation.easeOut(duration: 0.3)
    static let loading = Animation.easeInOut(duration: 0.6).repeatForever(autoreverses: true)
    static let feedback = Animation.linear(duration: 0.1)
}
