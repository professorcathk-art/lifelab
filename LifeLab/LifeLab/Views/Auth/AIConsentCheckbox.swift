import SwiftUI

struct AIConsentCheckbox: View {
    @Binding var hasReadTerms: Bool
    @Binding var showPrivacyPolicy: Bool
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            // Modern circular checkbox - Premium Design
            Button(action: {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    hasReadTerms.toggle()
                }
            }) {
                ZStack {
                    // Unchecked state: 1px solid gray border (#9CA3AF)
                    Circle()
                        .fill(hasReadTerms ? BrandColors.actionAccent : Color.clear)
                        .frame(width: 22, height: 22)
                        .overlay(
                            Circle()
                                .stroke(
                                    hasReadTerms ? BrandColors.actionAccent : Color(hex: "9CA3AF"),
                                    lineWidth: hasReadTerms ? 0 : 1.5
                                )
                        )
                    
                    // Checked state: White, crisp checkmark
                    if hasReadTerms {
                        Image(systemName: "checkmark")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)
            
            // Text content - top-aligned with checkbox, proper typography
            HStack(spacing: 0) {
                Text("我已閱讀並同意 ")
                    .font(.system(size: 14))
                    .foregroundColor(BrandColors.primaryText)
                    .lineSpacing(4)
                
                Button(action: {
                    showPrivacyPolicy = true
                }) {
                    Text("AI 服務使用條款")
                        .font(.system(size: 14))
                        .foregroundColor(BrandColors.actionAccent)
                        // No underline - just color differentiation as per Apple guidelines
                }
                .buttonStyle(.plain)
            }
            .fixedSize(horizontal: false, vertical: true)
        }
    }
}

#Preview {
    AIConsentCheckbox(
        hasReadTerms: .constant(false),
        showPrivacyPolicy: .constant(false)
    )
    .padding()
}
