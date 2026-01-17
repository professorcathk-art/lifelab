import SwiftUI

// MARK: - Brand Colors
struct BrandColors {
    // Primary Blue Palette
    static let primaryBlue = Color(red: 0.2, green: 0.4, blue: 0.9) // #3366E6
    static let primaryBlueDark = Color(red: 0.15, green: 0.3, blue: 0.75) // #264DBF
    static let primaryBlueLight = Color(red: 0.35, green: 0.55, blue: 0.95) // #598CF2
    
    // Accent Colors
    static let accentTeal = Color(red: 0.2, green: 0.7, blue: 0.8) // #33B3CC
    static let accentPurple = Color(red: 0.6, green: 0.4, blue: 0.9) // #9966E6
    
    // Semantic Colors
    static let success = Color(red: 0.2, green: 0.7, blue: 0.4) // #33B366
    static let warning = Color(red: 1.0, green: 0.7, blue: 0.2) // #FFB333
    static let error = Color(red: 0.9, green: 0.3, blue: 0.3) // #E64D4D
    
    // Neutral Colors
    static let background = Color(.systemBackground)
    static let secondaryBackground = Color(.secondarySystemBackground)
    static let tertiaryBackground = Color(.tertiarySystemBackground)
    
    // Text Colors
    static let primaryText = Color(.label)
    static let secondaryText = Color(.secondaryLabel)
    static let tertiaryText = Color(.tertiaryLabel)
    
    // Gradient
    static let primaryGradient = LinearGradient(
        colors: [primaryBlue, primaryBlueLight],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let accentGradient = LinearGradient(
        colors: [accentTeal, accentPurple],
        startPoint: .leading,
        endPoint: .trailing
    )
}

// MARK: - Typography
struct BrandTypography {
    static let largeTitle = Font.system(size: 34, weight: .bold, design: .rounded)
    static let title = Font.system(size: 28, weight: .bold, design: .rounded)
    static let title2 = Font.system(size: 22, weight: .semibold, design: .rounded)
    static let headline = Font.system(size: 17, weight: .semibold, design: .rounded)
    static let body = Font.system(size: 17, weight: .regular, design: .rounded)
    static let callout = Font.system(size: 16, weight: .regular, design: .rounded)
    static let subheadline = Font.system(size: 15, weight: .regular, design: .rounded)
    static let footnote = Font.system(size: 13, weight: .regular, design: .rounded)
    static let caption = Font.system(size: 12, weight: .regular, design: .rounded)
}

// MARK: - Spacing
struct BrandSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
}

// MARK: - Corner Radius
struct BrandRadius {
    static let small: CGFloat = 8
    static let medium: CGFloat = 12
    static let large: CGFloat = 16
    static let xlarge: CGFloat = 20
}

// MARK: - Shadows
struct BrandShadow {
    static let small = Shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: .black.opacity(0.15), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: .black.opacity(0.2), radius: 16, x: 0, y: 8)
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
            .cornerRadius(BrandRadius.medium)
            .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
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
            .cornerRadius(BrandRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.medium)
                    .stroke(BrandColors.primaryBlue.opacity(0.3), lineWidth: 1)
            )
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
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func brandCard(shadow: Shadow = BrandShadow.medium) -> some View {
        modifier(BrandCard(shadow: shadow))
    }
}
