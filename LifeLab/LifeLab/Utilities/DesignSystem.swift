import SwiftUI
import Combine
import UIKit

// MARK: - Theme Manager (Dark Mode & Day Mode Support)
class ThemeManager: ObservableObject {
    @Published var isDarkMode: Bool = true
    
    // Track if user has manually set theme preference
    private var hasUserSetTheme: Bool {
        UserDefaults.standard.bool(forKey: "app_theme_manual_set")
    }
    
    static let shared = ThemeManager()
    
    private init() {
        // Check if user has manually set theme preference
        if hasUserSetTheme {
            // Use saved theme preference
            if let savedTheme = UserDefaults.standard.string(forKey: "app_theme") {
                isDarkMode = savedTheme == "dark"
            }
        } else {
            // Auto-detect system theme preference
            isDarkMode = detectSystemTheme()
        }
    }
    
    /// Detect system theme preference
    private func detectSystemTheme() -> Bool {
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            return windowScene.traitCollection.userInterfaceStyle == .dark
        }
        // Fallback: check trait collection from main window
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            return window.traitCollection.userInterfaceStyle == .dark
        }
        // Default to dark mode if cannot detect
        return true
    }
    
    /// Get current system theme
    func getSystemTheme() -> Bool {
        return detectSystemTheme()
    }
    
    /// Toggle theme manually (user action)
    func toggleTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            isDarkMode.toggle()
            // Mark as manually set
            UserDefaults.standard.set(true, forKey: "app_theme_manual_set")
            UserDefaults.standard.set(isDarkMode ? "dark" : "light", forKey: "app_theme")
        }
    }
    
    /// Sync with system theme (if user hasn't manually set)
    func syncWithSystemTheme() {
        guard !hasUserSetTheme else { return }
        
        let systemIsDark = detectSystemTheme()
        if isDarkMode != systemIsDark {
            withAnimation(.easeInOut(duration: 0.3)) {
                isDarkMode = systemIsDark
            }
        }
    }
    
    /// Reset to follow system theme
    func resetToSystemTheme() {
        withAnimation(.easeInOut(duration: 0.3)) {
            UserDefaults.standard.set(false, forKey: "app_theme_manual_set")
            isDarkMode = detectSystemTheme()
        }
    }
}

// MARK: - Brand Colors (Theme-Aware Design System)
struct BrandColors {
    // Theme-aware computed properties
    static var background: Color {
        ThemeManager.shared.isDarkMode ? darkMode.background : dayMode.background
    }
    
    static var surface: Color {
        ThemeManager.shared.isDarkMode ? darkMode.surface : dayMode.surface
    }
    
    static var primaryText: Color {
        ThemeManager.shared.isDarkMode ? darkMode.primaryText : dayMode.primaryText
    }
    
    static var invertedText: Color {
        ThemeManager.shared.isDarkMode ? darkMode.invertedText : dayMode.invertedText
    }
    
    static var brandAccent: Color {
        ThemeManager.shared.isDarkMode ? darkMode.brandAccent : dayMode.brandAccent
    }
    
    static var actionAccent: Color {
        ThemeManager.shared.isDarkMode ? darkMode.actionAccent : dayMode.actionAccent
    }
    
    static var secondaryText: Color {
        ThemeManager.shared.isDarkMode ? darkMode.secondaryText : dayMode.secondaryText
    }
    
    static var tertiaryText: Color {
        ThemeManager.shared.isDarkMode ? darkMode.tertiaryText : dayMode.tertiaryText
    }
    
    static var borderColor: Color {
        ThemeManager.shared.isDarkMode ? darkMode.borderColor : dayMode.borderColor
    }
    
    static var secondaryBackground: Color {
        surface
    }
    
    static var tertiaryBackground: Color {
        ThemeManager.shared.isDarkMode ? darkMode.tertiaryBackground : dayMode.tertiaryBackground
    }
    
    // MARK: - Dark Mode Colors (Existing - Do Not Change)
    private struct darkMode {
        static let background = Color.black // #000000 - Pure black
        static let surface = Color(hex: "1C1C1E") // Dark charcoal
        static let primaryText = Color.white // #FFFFFF - Pure white
        static let invertedText = Color.black // #000000 - Pure black
        static let brandAccent = Color(hex: "FFC107") // Golden yellow
        static let actionAccent = Color(hex: "8B5CF6") // Neon purple
        static let secondaryText = Color(hex: "D1D5DB") // Light gray
        static let tertiaryText = Color(hex: "9CA3AF") // Medium gray
        static let borderColor = Color(hex: "2C2C2E") // Border gray
        static let tertiaryBackground = Color(hex: "1C1C1E").opacity(0.8)
    }
    
    // MARK: - Day Mode Colors (New - Daylight Healing Soft-Minimalist)
    private struct dayMode {
        static let background = Color(hex: "F7F7F9") // Pearl gray/Beige white - Warm, reduces eye strain
        static let surface = Color.white // #FFFFFF - Pure white for cards
        static let primaryText = Color(hex: "2C2C2E") // Deep charcoal - Soft, gentle reading
        static let invertedText = Color.white // #FFFFFF - White text for colored buttons
        static let brandAccent = Color(hex: "F5A623") // Dawn gold - Warm sunrise feel
        static let actionAccent = Color(hex: "6B4EFF") // Periwinkle blue - Calm, intellectual purple
        static let secondaryText = Color(hex: "8E8E93") // Soft light gray
        static let tertiaryText = Color(hex: "8E8E93") // Same as secondary for day mode
        static let borderColor = Color(hex: "E5E5EA") // Very light gray border
        static let tertiaryBackground = Color(hex: "F0F0F5") // Very light gray (System Gray 6)
    }
    
    // MARK: - Day Mode Specific Colors
    static var dayModeInputBackground: Color {
        Color(hex: "F0F0F5") // Very light gray for input fields
    }
    
    static var dayModeDataChipBackground: Color {
        Color(hex: "F0EDFF") // Very light purple background for data chips
    }
    
    static var dayModeDataChipText: Color {
        Color(hex: "5038BC") // Deep purple text for data chips
    }
    
    // MARK: - Shadows (Theme-Aware)
    static var cardShadow: Shadow {
        if ThemeManager.shared.isDarkMode {
            return Shadow(color: Color.clear, radius: 0, x: 0, y: 0) // No shadow in dark mode
        } else {
            return Shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4) // Soft shadow in day mode
        }
    }
    
    static var buttonShadow: Shadow {
        if ThemeManager.shared.isDarkMode {
            return Shadow(color: Color.clear, radius: 0, x: 0, y: 0) // No shadow in dark mode
        } else {
            return Shadow(color: Color(hex: "6B4EFF").opacity(0.25), radius: 8, x: 0, y: 4) // Soft purple shadow for buttons
        }
    }
    
    // Semantic Colors (Same for both themes)
    static let success = Color(hex: "4CAF50")
    static let warning = Color(hex: "FFB300")
    static let error = Color(hex: "FF6B6B")
    
    // Legacy support (mapped to theme-aware colors)
    static var primaryBlue: Color { actionAccent }
    static var accentTeal: Color { actionAccent }
    static var accentPurple: Color { actionAccent }
    static var accentPink: Color { actionAccent }
    static var accentOrange: Color { brandAccent }
    static var accentGreen: Color { success }
    static var accentYellow: Color { brandAccent }
    
    // Sky blue for compatibility (used in VennDiagramView)
    static let skyBlue = Color(hex: "60A5FA")
    static let skyBlueLight = Color(hex: "93C5FD")
    static let skyBlueDark = Color(hex: "3B82F6")
    static let primaryBlueDark = skyBlueDark
    static let primaryBlueLight = skyBlueLight
    
    // Keyword colors for compatibility
    static let keywordColors: [Color] = [
        actionAccent,
        brandAccent,
        Color(hex: "FF7B54"),
        Color(hex: "10b6cc"),
        Color(hex: "4CAF50"),
        Color(hex: "60A5FA"),
        Color(hex: "A78BFA"),
        Color(hex: "FF6B6B"),
    ]
    
    // Colorful gradients for compatibility
    static let colorfulGradients: [LinearGradient] = [
        LinearGradient(colors: [actionAccent, actionAccent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [brandAccent, brandAccent.opacity(0.8)], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "FF7B54"), Color(hex: "FF9A7A")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "10b6cc"), Color(hex: "3BA5AB")], startPoint: .topLeading, endPoint: .bottomTrailing),
        LinearGradient(colors: [Color(hex: "4CAF50"), Color(hex: "66BB6A")], startPoint: .topLeading, endPoint: .bottomTrailing),
    ]
    
    // Gradients (Theme-aware)
    static var primaryGradient: LinearGradient {
        if ThemeManager.shared.isDarkMode {
            return LinearGradient(
                colors: [Color.white, Color.white.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        } else {
            return LinearGradient(
                colors: [actionAccent, actionAccent.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
    
    static let accentGradient = LinearGradient(
        colors: [actionAccent, actionAccent.opacity(0.8)],
        startPoint: .leading,
        endPoint: .trailing
    )
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

// MARK: - Typography (SF Pro - Apple Native)
struct BrandTypography {
    // Display fonts (Bold/Heavy)
    static let largeTitle = Font.largeTitle.bold()
    static let title = Font.title.bold()
    static let title2 = Font.title2.bold()
    static let title3 = Font.title3.bold()
    
    // Body fonts (Standard readability)
    static let headline = Font.headline
    static let body = Font.body
    static let callout = Font.callout
    static let subheadline = Font.subheadline
    static let footnote = Font.footnote
    static let caption = Font.caption
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
    static let pill: CGFloat = 999 // For pill-shaped buttons
}

// MARK: - Shadows
struct BrandShadow {
    static let small = Shadow(color: Color.black.opacity(0.2), radius: 2, x: 0, y: 1)
    static let medium = Shadow(color: Color.black.opacity(0.3), radius: 8, x: 0, y: 4)
    static let large = Shadow(color: Color.black.opacity(0.4), radius: 16, x: 0, y: 8)
}

struct Shadow {
    let color: Color
    let radius: CGFloat
    let x: CGFloat
    let y: CGFloat
}

// MARK: - Reusable Components

// MARK: Primary Action Button (Theme-aware)
struct PrimaryButton: View {
    let title: String
    let action: () -> Void
    var isEnabled: Bool = true
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(BrandTypography.headline)
                .fontWeight(.bold)
                .foregroundColor(BrandColors.invertedText)
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.md)
                .background(
                    ThemeManager.shared.isDarkMode 
                        ? BrandColors.primaryText // White in dark mode
                        : BrandColors.actionAccent // Purple in day mode
                )
                .clipShape(Capsule())
                .shadow(
                    color: BrandColors.buttonShadow.color,
                    radius: BrandColors.buttonShadow.radius,
                    x: BrandColors.buttonShadow.x,
                    y: BrandColors.buttonShadow.y
                )
        }
        .disabled(!isEnabled)
        .opacity(isEnabled ? 1.0 : 0.5)
        .padding(.horizontal, BrandSpacing.xl)
    }
}

// MARK: Selection Card (List Style)
struct SelectionCard: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                    .font(BrandTypography.body)
                    .foregroundColor(BrandColors.primaryText)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(BrandColors.primaryText)
                        .font(.title3)
                }
            }
            .padding(BrandSpacing.lg)
            .background(isSelected ? BrandColors.actionAccent : BrandColors.surface)
            .cornerRadius(BrandRadius.large)
        }
        .buttonStyle(.plain)
    }
}

// MARK: Highlighted Text
struct HighlightedText: View {
    let text: String
    let highlightColor: HighlightColor
    
    enum HighlightColor {
        case purple
        case yellow
    }
    
    var body: some View {
        switch highlightColor {
        case .purple:
            Text(text)
                .foregroundColor(BrandColors.actionAccent)
        case .yellow:
            Text(text)
                .foregroundColor(BrandColors.invertedText)
                .padding(.horizontal, BrandSpacing.sm)
                .padding(.vertical, BrandSpacing.xs)
                .background(BrandColors.brandAccent)
                .cornerRadius(BrandRadius.small)
        }
    }
}

// MARK: Progress Indicators

// MARK: Onboarding Page Indicator (Small dots)
struct PageIndicator: View {
    let currentPage: Int
    let totalPages: Int
    
    var body: some View {
        HStack(spacing: BrandSpacing.sm) {
            ForEach(0..<totalPages, id: \.self) { index in
                Circle()
                    .fill(index == currentPage ? BrandColors.primaryText : BrandColors.surface)
                    .frame(width: 8, height: 8)
            }
        }
        .padding(.bottom, BrandSpacing.xl)
    }
}

// MARK: Linear Progress Bar
struct LinearProgressBar: View {
    let progress: Double // 0.0 to 1.0
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: BrandRadius.small)
                    .fill(BrandColors.surface)
                    .frame(height: 4)
                
                // Progress
                RoundedRectangle(cornerRadius: BrandRadius.small)
                    .fill(BrandColors.actionAccent)
                    .frame(width: geometry.size.width * CGFloat(progress), height: 4)
            }
        }
        .frame(height: 4)
    }
}

// MARK: - Button Styles

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .fontWeight(.bold)
            .foregroundColor(BrandColors.invertedText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BrandSpacing.md)
            .background(
                ThemeManager.shared.isDarkMode 
                    ? BrandColors.primaryText // White in dark mode
                    : BrandColors.actionAccent // Purple in day mode
            )
            .clipShape(Capsule())
            .shadow(
                color: BrandColors.buttonShadow.color,
                radius: BrandColors.buttonShadow.radius,
                x: BrandColors.buttonShadow.x,
                y: BrandColors.buttonShadow.y
            )
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(BrandTypography.headline)
            .foregroundColor(BrandColors.primaryText)
            .frame(maxWidth: .infinity)
            .padding(.vertical, BrandSpacing.md)
            .background(BrandColors.surface)
            .cornerRadius(BrandRadius.large)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.large)
                    .stroke(BrandColors.borderColor, lineWidth: 1)
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
            .foregroundColor(BrandColors.actionAccent)
            .underline(configuration.isPressed)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .animation(.easeInOut(duration: 0.1), value: configuration.isPressed)
    }
}

// MARK: - Card Style
struct BrandCard: ViewModifier {
    let shadow: Shadow
    
    func body(content: Content) -> some View {
        content
            .padding(BrandSpacing.lg)
            .background(BrandColors.surface)
            .cornerRadius(BrandRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.medium)
                    .stroke(BrandColors.borderColor, lineWidth: 1)
            )
            .shadow(color: shadow.color, radius: shadow.radius, x: shadow.x, y: shadow.y)
    }
}

extension View {
    func brandCard(shadow: Shadow? = nil) -> some View {
        let cardShadow = shadow ?? BrandColors.cardShadow
        return modifier(BrandCard(shadow: cardShadow))
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

// MARK: - Responsive Layout Helper
struct ResponsiveLayout {
    static func isIPad() -> Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func horizontalPadding() -> CGFloat {
        isIPad() ? BrandSpacing.xxxl * 2 : BrandSpacing.xl
    }
    
    static func maxContentWidth() -> CGFloat {
        isIPad() ? 600 : .infinity
    }
}
