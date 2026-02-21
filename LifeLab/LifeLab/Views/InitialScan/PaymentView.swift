import SwiftUI
import StoreKit

struct PaymentView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @EnvironmentObject var dataService: DataService
    @StateObject private var paymentService = PaymentService.shared
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedPackage: SubscriptionPackage = .yearly // Always yearly in this stage
    @State private var isProcessing = false
    @State private var showError = false
    @State private var showSuccess = false
    @State private var showWaitingTime = false
    @State private var hasCompletedPurchase = false // Track if purchase is completed
    // Promo code functionality removed - not allowed by Apple
    // Will be implemented after first version approval
    
    enum SubscriptionPackage: String, CaseIterable {
        case yearly = "yearly"
        case quarterly = "quarterly"
        case monthly = "monthly"
        
        var title: String {
            switch self {
            case .yearly: return "年付"
            case .quarterly: return "季付"
            case .monthly: return "月付"
            }
        }
        
        var productID: String {
            switch self {
            case .yearly: return "com.resonance.lifelab.annually"
            case .quarterly: return "com.resonance.lifelab.quarterly"
            case .monthly: return "com.resonance.lifelab.monthly"
            }
        }
        
        var price: String {
            // Fixed USD prices (monthly equivalent prices)
            // These are the exact prices to display, regardless of StoreKit product prices
            switch self {
            case .yearly: return "US$ 7.59"      // USD 7.59/month (paid annually)
            case .quarterly: return "US$ 9.99"   // USD 9.99/month (paid quarterly)
            case .monthly: return "US$ 17.99"    // USD 17.99/month (paid monthly)
            }
        }
        
        var period: String {
            switch self {
            case .yearly: return "/月（年付）"
            case .quarterly: return "/月（季付，90天週期）"
            case .monthly: return "/月"
            }
        }
        
        var savings: String? {
            switch self {
            case .yearly: return "節省 58%"
            case .quarterly: return "節省 48%"
            case .monthly: return nil
            }
        }
        
        func price(from products: [Product]) -> String {
            if let product = products.first(where: { $0.id == productID }) {
                // Convert product.price (Decimal) to USD format
                // StoreKit will handle currency conversion at payment time
                let priceDecimal = product.price
                let priceDouble = NSDecimalNumber(decimal: priceDecimal).doubleValue
                
                // Format as USD
                let formatter = NumberFormatter()
                formatter.numberStyle = .currency
                formatter.currencyCode = "USD"
                formatter.maximumFractionDigits = 2
                
                if let formattedPrice = formatter.string(from: NSNumber(value: priceDouble)) {
                    return formattedPrice
                }
                // Fallback: format manually with USD
                return String(format: "$%.2f", priceDouble)
            }
            return price // Fallback
        }
        
        // Return fixed USD monthly price
        // IMPORTANT: Always use fixed prices, do NOT calculate from StoreKit product prices
        // StoreKit will handle currency conversion at payment time, but we display fixed USD prices
        func monthlyPrice(from products: [Product]) -> String {
            // Always return fixed USD prices, regardless of StoreKit product prices
            // This ensures consistent display across all regions
            return price
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: BrandSpacing.xxxl) {
                // Hero Section - Vision Title Area
                VStack(spacing: BrandSpacing.lg) {
                    // Top Icon - Sparkles or Compass with soft gradient
                    ZStack {
                        if themeManager.isDarkMode {
                            // Dark mode: Purple glow background
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [BrandColors.actionAccent.opacity(0.3), BrandColors.brandAccent.opacity(0.2)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 50))
                                .foregroundColor(BrandColors.actionAccent)
                        } else {
                            // Day mode: Soft purple to gold gradient
                            Circle()
                                .fill(
                                    LinearGradient(
                                        colors: [Color(hex: "6B4EFF").opacity(0.2), Color(hex: "F5A623").opacity(0.15)],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                                .frame(width: 100, height: 100)
                                .blur(radius: 20)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 50))
                                .foregroundStyle(
                                    LinearGradient(
                                        colors: [Color(hex: "6B4EFF"), Color(hex: "F5A623")],
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    )
                                )
                        }
                    }
                    
                    // Main Title
                    Text("預見你的理想人生")
                        .font(Font.title.bold())
                        .foregroundColor(BrandColors.primaryText)
                    
                    // Subtitle
                    Text("解鎖專屬 AI 深度分析，從自我洞察到落地執行，一步步打造你真正渴望的生活。")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                }
                .padding(.top, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                
                // Value Proposition List - Core Marketing Block
                VStack(alignment: .leading, spacing: BrandSpacing.lg) {
                    // Item 1: Target
                    ValuePropositionItem(
                        icon: "target",
                        iconColor: themeManager.isDarkMode ? BrandColors.brandAccent : Color(hex: "F5A623"),
                        title: "精準定位天賦與方向",
                        description: "結合你熱愛、擅長與重視的事物，AI 將為你找出最佳的人生與職涯交集。"
                    )
                    
                    // Item 2: Map
                    ValuePropositionItem(
                        icon: "map",
                        iconColor: BrandColors.actionAccent,
                        title: "專屬行動路徑與里程碑",
                        description: "告別迷茫，獲得 AI 量身打造的具體行動計畫，讓夢想具備可執行性。"
                    )
                    
                    // Item 3: Key
                    ValuePropositionItem(
                        icon: "key",
                        iconColor: themeManager.isDarkMode ? BrandColors.brandAccent : Color(hex: "F5A623"),
                        title: "解鎖進階深度探索",
                        description: "開啟專屬自我洞察關卡，清理內在阻礙，全面釐清你的核心願景。"
                    )
                }
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Pricing Cards - Show all subscription options
                VStack(spacing: BrandSpacing.md) {
                    if paymentService.isLoading {
                        ProgressView("載入產品中...")
                            .padding()
                    } else {
                        // Show all subscription packages: yearly, quarterly, monthly
                        // All packages display monthly price
                        ForEach(SubscriptionPackage.allCases, id: \.self) { package in
                            PackageCard(
                                package: package,
                                isSelected: selectedPackage == package,
                                price: paymentService.products.isEmpty 
                                    ? package.monthlyPrice(from: []) // Use monthlyPrice for all packages
                                    : package.monthlyPrice(from: paymentService.products), // Use monthlyPrice for all packages
                                onSelect: {
                                    selectedPackage = package
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                .onAppear {
                    // Load products when view appears
                    Task {
                        await paymentService.loadProducts()
                    }
                }
                .onChange(of: paymentService.products) { products in
                    // Refresh UI when products are loaded
                    if !products.isEmpty {
                        print("✅ Products loaded: \(products.map { "\($0.id): \($0.displayPrice)" })")
                    }
                }
                
                // CTA Button - "開啟我的理想人生"
                Button(action: {
                    Task {
                        await handlePurchase()
                    }
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        if isProcessing || viewModel.isLoadingBlueprint {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(
                                    tint: BrandColors.invertedText
                                ))
                                .scaleEffect(0.8)
                        }
                        Text(getButtonText())
                            .font(BrandTypography.headline)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(BrandColors.invertedText)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(BrandColors.actionAccent) // Purple background
                    .clipShape(Capsule())
                    .shadow(
                        color: BrandColors.buttonShadow.color,
                        radius: BrandColors.buttonShadow.radius,
                        x: BrandColors.buttonShadow.x,
                        y: BrandColors.buttonShadow.y
                    )
                }
                .buttonStyle(.plain)
                .disabled(isProcessing || viewModel.isLoadingBlueprint || paymentService.isLoading || hasCompletedPurchase || dataService.userProfile?.lifeBlueprint != nil)
                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                .padding(.bottom, BrandSpacing.xxxl)
                .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                
                // Waiting time message
                if showWaitingTime || viewModel.isLoadingBlueprint {
                    VStack(spacing: BrandSpacing.sm) {
                        HStack(spacing: BrandSpacing.xs) {
                            Image(systemName: "clock.fill")
                                .foregroundColor(BrandColors.brandAccent)
                                .font(.system(size: 16))
                            Text("預計等待時間：2-3 分鐘")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                        }
                        Text("AI 正在為您生成專屬生命藍圖，完成後將自動跳轉至首頁")
                            .font(BrandTypography.caption)
                            .foregroundColor(BrandColors.tertiaryText)
                            .multilineTextAlignment(.center)
                    }
                    .padding(BrandSpacing.md)
                    .background(BrandColors.surface)
                    .cornerRadius(BrandRadius.medium)
                    .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    .padding(.bottom, BrandSpacing.lg)
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                }
            }
            .frame(maxWidth: .infinity)
        }
        .background(BrandColors.background)
        .alert("購買成功", isPresented: $showSuccess) {
            Button("確定") {
                hasCompletedPurchase = true // Mark purchase as completed
                viewModel.completePayment()
            }
        } message: {
            Text("訂閱成功！正在為您生成生命藍圖...")
        }
        .alert("購買失敗", isPresented: $showError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(paymentService.errorMessage ?? "未知錯誤")
        }
        .onChange(of: viewModel.isLoadingBlueprint) { isLoading in
            if isLoading {
                showWaitingTime = true
                hasCompletedPurchase = true // Keep button disabled during loading
            } else {
                // Loading completed - ContentView will automatically switch to MainTabView
                // when blueprint is detected in dataService.userProfile
                print("✅ PaymentView: Loading completed, waiting for ContentView to detect blueprint")
            }
        }
        .onChange(of: dataService.userProfile?.lifeBlueprint) { blueprint in
            // When blueprint is generated and saved to DataService,
            // ContentView will immediately detect it and switch to MainTabView
            if blueprint != nil {
                hasCompletedPurchase = true // Ensure button stays disabled
                print("✅ PaymentView: Blueprint detected in DataService, ContentView will navigate")
                // ContentView's hasCompletedInitialScan will become true immediately
                // and switch to MainTabView without delay
            }
        }
        .onAppear {
            // Check if user already has a blueprint (already purchased)
            if dataService.userProfile?.lifeBlueprint != nil {
                hasCompletedPurchase = true
                print("✅ PaymentView: User already has blueprint, marking as purchased")
                return
            }
            
            // CRITICAL: Check subscription status - must have BOTH StoreKit AND Supabase
            // Only use SubscriptionManager's hasActiveSubscription (checks both)
            Task {
                // Wait for subscription check to complete
                await SubscriptionManager.shared.checkSubscriptionStatus()
                await paymentService.refreshPurchasedProducts()
                
                let subscriptionManager = SubscriptionManager.shared
                let hasActiveSubscription = subscriptionManager.hasActiveSubscription
                
                await MainActor.run {
                    if hasActiveSubscription {
                        // User has valid subscription in BOTH StoreKit AND Supabase
                        hasCompletedPurchase = true
                        
                        // If user has active subscription but no blueprint, auto-generate
                        if dataService.userProfile?.lifeBlueprint == nil {
                            print("✅✅✅ PaymentView: User has VALID subscription (StoreKit + Supabase), auto-generating blueprint")
                            viewModel.hasPaid = true // Mark as paid to allow blueprint generation
                            viewModel.generateLifeBlueprint()
                        }
                    } else {
                        // User has NO valid subscription - show payment page
                        print("❌❌❌ PaymentView: User has NO valid subscription")
                        print("   SubscriptionManager.hasActiveSubscription: \(subscriptionManager.hasActiveSubscription)")
                        print("   PaymentService.hasActiveSubscription: \(paymentService.hasActiveSubscription)")
                        print("   User MUST pay before generating blueprint")
                        hasCompletedPurchase = false
                    }
                }
            }
        }
    }
    
    private func getButtonText() -> String {
        if isProcessing {
            return "處理中..."
        } else if viewModel.isLoadingBlueprint {
            return "正在生成生命藍圖..."
        } else {
            return "開啟我的理想人生"
        }
    }
    
    private func handlePurchase() async {
        isProcessing = true
        showWaitingTime = true
        
        // Get the product for yearly subscription
        let productID = selectedPackage.productID // "com.resonance.lifelab.yearly"
        
        // Ensure products are loaded
        if paymentService.products.isEmpty {
            print("📦 Products not loaded yet, loading now...")
            await paymentService.loadProducts()
        }
        
        // Find the product
        guard let product = paymentService.products.first(where: { $0.id == productID }) else {
            print("❌ Product not found: \(productID)")
            print("📦 Available products: \(paymentService.products.map { $0.id })")
            await MainActor.run {
                isProcessing = false
                showWaitingTime = false
                paymentService.errorMessage = "無法載入產品，請稍後再試"
                showError = true
            }
            return
        }
        
        print("✅ Found product: \(product.id) - \(product.displayPrice)")
        
        // Attempt purchase
        do {
            let success = try await paymentService.purchase(product)
            
            await MainActor.run {
                isProcessing = false
                
                if success {
                    print("✅ Purchase successful!")
                    // Show success alert, which will trigger completePayment()
                    showSuccess = true
                } else {
                    // User cancelled or purchase pending
                    showWaitingTime = false
                    if let errorMsg = paymentService.errorMessage, !errorMsg.isEmpty {
                        showError = true
                    }
                }
            }
        } catch {
            print("❌ Purchase error: \(error.localizedDescription)")
            await MainActor.run {
                isProcessing = false
                showWaitingTime = false
                paymentService.errorMessage = "購買失敗：\(error.localizedDescription)"
                showError = true
            }
        }
    }
}

// MARK: - Value Proposition Item Component
struct ValuePropositionItem: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    
    var body: some View {
        HStack(alignment: .top, spacing: BrandSpacing.md) {
            // Left Icon
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(iconColor)
                .frame(width: 32, height: 32)
            
            // Right Content
            VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                Text(title)
                    .font(BrandTypography.headline)
                    .fontWeight(.bold)
                    .foregroundColor(BrandColors.primaryText)
                
                Text(description)
                    .font(BrandTypography.body)
                    .foregroundColor(BrandColors.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            
            Spacer()
        }
    }
}

// MARK: - Package Card Component (Theme-Aware)
struct PackageCard: View {
    let package: PaymentView.SubscriptionPackage
    let isSelected: Bool
    let price: String
    let onSelect: () -> Void
    
    init(package: PaymentView.SubscriptionPackage, isSelected: Bool, price: String? = nil, onSelect: @escaping () -> Void) {
        self.package = package
        self.isSelected = isSelected
        self.price = price ?? package.price
        self.onSelect = onSelect
    }
    
    var isYearly: Bool {
        package == .yearly
    }
    
    var body: some View {
        Button(action: onSelect) {
            ZStack(alignment: .topTrailing) {
                HStack {
                    VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                        HStack {
                            Text(package.title)
                                .font(BrandTypography.headline)
                                .fontWeight(.bold)
                                .foregroundColor(BrandColors.primaryText)
                            
                            if let savings = package.savings {
                                Text(savings)
                                    .font(BrandTypography.caption)
                                    .foregroundColor(
                                        ThemeManager.shared.isDarkMode 
                                            ? BrandColors.brandAccent 
                                            : Color(hex: "F5A623")
                                    )
                                    .fontWeight(.semibold)
                                    .padding(.horizontal, BrandSpacing.sm)
                                    .padding(.vertical, BrandSpacing.xs)
                                    .background(
                                        ThemeManager.shared.isDarkMode 
                                            ? BrandColors.brandAccent.opacity(0.15)
                                            : Color(hex: "F5A623").opacity(0.15)
                                    )
                                    .cornerRadius(BrandRadius.small)
                            }
                        }
                        
                        HStack(alignment: .firstTextBaseline, spacing: BrandSpacing.xs) {
                            Text(price)
                                .font(BrandTypography.title2)
                                .fontWeight(.bold)
                                .foregroundColor(BrandColors.primaryText)
                            Text(package.period)
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                        .font(.title2)
                        .foregroundColor(
                            isSelected 
                                ? BrandColors.actionAccent 
                                : BrandColors.secondaryText
                        )
                }
                .padding(BrandSpacing.lg)
                .background(
                    isYearly && isSelected
                        ? (ThemeManager.shared.isDarkMode 
                            ? BrandColors.actionAccent.opacity(0.15)
                            : Color(hex: "F8F6FF")) // Very light purple background
                        : BrandColors.surface
                )
                .cornerRadius(BrandRadius.large)
                .overlay(
                    RoundedRectangle(cornerRadius: BrandRadius.large)
                        .stroke(
                            isYearly && isSelected
                                ? BrandColors.actionAccent // Purple border for yearly
                                : (isSelected 
                                    ? BrandColors.borderColor 
                                    : BrandColors.borderColor),
                            lineWidth: isYearly && isSelected ? 2 : 1
                        )
                )
                .shadow(
                    color: BrandColors.cardShadow.color,
                    radius: BrandColors.cardShadow.radius,
                    x: BrandColors.cardShadow.x,
                    y: BrandColors.cardShadow.y
                )
                
                // Best Value Badge (only for yearly when selected)
                if isYearly && isSelected {
                    HStack(spacing: BrandSpacing.xs) {
                        Text("🔥")
                            .font(.system(size: 12))
                        Text("最佳價值")
                            .font(BrandTypography.caption)
                            .fontWeight(.bold)
                    }
                    .foregroundColor(BrandColors.invertedText) // White text
                    .padding(.horizontal, BrandSpacing.sm)
                    .padding(.vertical, BrandSpacing.xs)
                    .background(BrandColors.actionAccent) // Purple background
                    .cornerRadius(BrandRadius.small)
                    .padding(BrandSpacing.sm)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Promo Code Sheet (Removed - not allowed by Apple)
// Will be implemented after first version approval if needed

#Preview {
    PaymentView()
        .environmentObject(InitialScanViewModel())
}
