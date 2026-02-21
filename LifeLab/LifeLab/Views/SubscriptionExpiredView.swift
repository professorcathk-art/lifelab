import SwiftUI

/// SubscriptionExpiredView - Shown when user's subscription has expired
struct SubscriptionExpiredView: View {
    @EnvironmentObject var subscriptionManager: SubscriptionManager
    @EnvironmentObject var paymentService: PaymentService
    @StateObject private var viewModel = InitialScanViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        ScrollView {
            VStack(spacing: BrandSpacing.xxl) {
                Spacer()
                    .frame(height: 60)
                
                // Icon
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(BrandColors.brandAccent)
                    .padding(.bottom, BrandSpacing.lg)
                
                // Title
                Text("訂閱已過期")
                    .font(BrandTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(BrandColors.primaryText)
                    .multilineTextAlignment(.center)
                
                // Description
                Text("您的訂閱已過期，請續訂以繼續使用 LifeLab 的所有功能。")
                    .font(BrandTypography.body)
                    .foregroundColor(BrandColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.xl)
                
                // Expiry Date (if available)
                if let expiryDate = subscriptionManager.subscriptionExpiryDate {
                    VStack(spacing: BrandSpacing.xs) {
                        Text("過期日期")
                            .font(BrandTypography.caption)
                            .foregroundColor(BrandColors.tertiaryText)
                        Text(expiryDate, style: .date)
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                    .padding(BrandSpacing.md)
                    .background(BrandColors.surface)
                    .cornerRadius(BrandRadius.medium)
                }
                
                // Renew Button
                Button(action: {
                    // Navigate to payment page
                    viewModel.currentStep = .payment
                }) {
                    Text("立即續訂")
                        .font(BrandTypography.headline)
                        .fontWeight(.bold)
                        .foregroundColor(BrandColors.invertedText)
                        .frame(maxWidth: .infinity)
                        .frame(height: 50)
                        .background(BrandColors.actionAccent)
                        .clipShape(Capsule())
                        .shadow(
                            color: BrandColors.buttonShadow.color,
                            radius: BrandColors.buttonShadow.radius,
                            x: BrandColors.buttonShadow.x,
                            y: BrandColors.buttonShadow.y
                        )
                }
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.top, BrandSpacing.lg)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Restore Purchases Button
                Button(action: {
                    Task {
                        await paymentService.restorePurchases()
                        await subscriptionManager.checkSubscriptionStatus()
                    }
                }) {
                    Text("恢復購買")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.actionAccent)
                }
                .padding(.top, BrandSpacing.sm)
                
                Spacer()
            }
            .padding(.horizontal, ResponsiveLayout.horizontalPadding())
            .frame(maxWidth: ResponsiveLayout.maxContentWidth())
        }
        .background(BrandColors.background)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

#Preview {
    SubscriptionExpiredView()
        .environmentObject(SubscriptionManager.shared)
        .environmentObject(PaymentService.shared)
}
