import SwiftUI
import StoreKit

struct PaymentView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @EnvironmentObject var dataService: DataService
    @ObservedObject private var paymentService = PaymentService.shared
    @ObservedObject private var themeManager = ThemeManager.shared
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
        
        // Fallback prices (USD) - only used if StoreKit products not available
        var fallbackPrice: String {
            switch self {
            case .yearly: return "89.99 USD"
            case .quarterly: return "29.99 USD"
            case .monthly: return "17.99 USD"
            }
        }
        
        // Billing period label
        var billingPeriod: String {
            switch self {
            case .yearly: return "年"
            case .quarterly: return "季"
            case .monthly: return "月"
            }
        }
        
        var savings: String? {
            switch self {
            case .yearly: return "節省 58%"
            case .quarterly: return "節省 48%"
            case .monthly: return nil
            }
        }
        
        // Get ACTUAL billed amount from StoreKit (most prominent)
        // IMPORTANT: This is the amount Apple will charge, formatted in user's locale/currency
        func billedAmount(from products: [Product]) -> String {
            if let product = products.first(where: { $0.id == productID }) {
                // Use StoreKit's displayPrice which handles:
                // - Currency conversion (USD, EUR, JPY, etc.)
                // - Locale formatting (commas, decimal separators)
                // - Currency symbols
                return product.displayPrice
            }
            // Fallback to fixed USD if StoreKit product not available
            return fallbackPrice
        }
        
        // Calculate monthly equivalent (subordinate, smaller text)
        // Only shown for yearly and quarterly subscriptions
        // IMPORTANT: This must be LESS prominent than billed amount
        // CRITICAL: Must use the SAME currency as the billed amount (from product.priceFormatStyle)
        func monthlyEquivalent(from products: [Product]) -> String? {
            guard let product = products.first(where: { $0.id == productID }) else {
                // Fallback calculation if StoreKit product not available
                switch self {
                case .yearly:
                    return "約 7.59 USD/月"
                case .quarterly:
                    return "約 9.99 USD/月"
                case .monthly:
                    return nil // No monthly equivalent for monthly subscription
                }
            }
            
            // Calculate monthly equivalent from actual StoreKit price
            let priceDecimal = product.price
            let priceDouble = NSDecimalNumber(decimal: priceDecimal).doubleValue
            
            let monthlyPrice: Double
            switch self {
            case .yearly:
                monthlyPrice = priceDouble / 12.0
            case .quarterly:
                monthlyPrice = priceDouble / 3.0
            case .monthly:
                return nil // No monthly equivalent for monthly subscription
            }
            
            // CRITICAL: Use product.priceFormatStyle to get the SAME currency as displayPrice
            // This ensures monthly equivalent uses the exact same currency formatting
            // product.priceFormatStyle contains the currency information used by displayPrice
            let priceFormatStyle = product.priceFormatStyle
            
            // Format the monthly price using the SAME format style as the product
            // This ensures currency code, symbol, and formatting match exactly
            let monthlyPriceDecimal = Decimal(monthlyPrice)
            let formattedMonthlyPrice = monthlyPriceDecimal.formatted(priceFormatStyle)
            
            return "約 \(formattedMonthlyPrice)/月"
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
                        // IMPORTANT: Display billed amount prominently, monthly equivalent subordinate
                        ForEach(SubscriptionPackage.allCases, id: \.self) { package in
                            PackageCard(
                                package: package,
                                isSelected: selectedPackage == package,
                                billedAmount: paymentService.products.isEmpty 
                                    ? package.billedAmount(from: [])
                                    : package.billedAmount(from: paymentService.products),
                                monthlyEquivalent: paymentService.products.isEmpty
                                    ? package.monthlyEquivalent(from: [])
                                    : package.monthlyEquivalent(from: paymentService.products),
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
                    // Load products when view appears with retry mechanism
                    Task {
                        await loadProductsWithRetry()
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
                    // CRITICAL: Immediately set processing state to prevent double-click
                    guard !isProcessing && !viewModel.isLoadingBlueprint && !paymentService.isLoading else {
                        return
                    }
                    isProcessing = true
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
                    .foregroundColor(Color.white) // CRITICAL: White text on purple background for proper contrast
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
        // REMOVED: Success alert - now we navigate immediately to loading page
        // This prevents users from being stuck on payment page while AI generates
        // .alert("購買成功", isPresented: $showSuccess) {
        //     Button("確定") {
        //         hasCompletedPurchase = true
        //         viewModel.completePayment()
        //     }
        // } message: {
        //     Text("訂閱成功！正在為您生成生命藍圖...")
        // }
        .alert("", isPresented: $showError) {
            Button("確定", role: .cancel) { }
            Button("重試") {
                Task {
                    await handlePurchase()
                }
            }
        } message: {
            Text(paymentService.errorMessage ?? "購買過程中發生錯誤。\n\n請稍後再試，如問題持續存在，請聯繫客服。")
                .font(BrandTypography.body)
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
                        
                        // If user has active subscription but no blueprint, redirect to loading page with progress bar
                        if dataService.userProfile?.lifeBlueprint == nil {
                            print("✅✅✅ PaymentView: User has VALID subscription (StoreKit + Supabase), redirecting to loading page with progress bar")
                            viewModel.hasPaid = true // Mark as paid to allow blueprint generation
                            // CRITICAL: Redirect to loading page immediately so user sees progress bar
                            viewModel.currentStep = .loading
                            // Start blueprint generation (will show progress bar on loading page)
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
    
    // CRITICAL: Load products with retry mechanism for Apple review
    // Products may not be immediately available in sandbox environment
    private func loadProductsWithRetry(maxRetries: Int = 3) async {
        for attempt in 1...maxRetries {
            print("🔄 Loading products (attempt \(attempt)/\(maxRetries))...")
            await paymentService.loadProducts()
            
            if !paymentService.products.isEmpty {
                print("✅ Products loaded successfully: \(paymentService.products.map { $0.id })")
                return
            }
            
            if attempt < maxRetries {
                print("⏳ Waiting 2 seconds before retry...")
                try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
            }
        }
        
        // All retries failed
        print("❌ Failed to load products after \(maxRetries) attempts")
        if paymentService.products.isEmpty {
            await MainActor.run {
                paymentService.errorMessage = "無法載入產品，請稍後再試"
            }
        }
    }
    
    private func handlePurchase() async {
        // Note: isProcessing is already set in button action to prevent double-click
        showWaitingTime = true
        
        // Get the product ID for selected package
        let productID = selectedPackage.productID
        
        // CRITICAL: Ensure products are loaded with retry mechanism
        // This is important for Apple review where products may not be immediately available
        if paymentService.products.isEmpty {
            print("📦 Products not loaded yet, loading with retry...")
            await loadProductsWithRetry()
        }
        
        // If still empty after retry, try one more time with delay
        if paymentService.products.isEmpty {
            print("⚠️ Products still empty after retry, trying once more...")
            await paymentService.loadProducts()
            // Wait a bit for StoreKit to sync
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
        }
        
        // Find the product
        guard let product = paymentService.products.first(where: { $0.id == productID }) else {
            print("❌ Product not found: \(productID)")
            print("📦 Available products: \(paymentService.products.map { $0.id })")
            print("📦 Expected product IDs:")
            print("   - com.resonance.lifelab.annually")
            print("   - com.resonance.lifelab.quarterly")
            print("   - com.resonance.lifelab.monthly")
            
            await MainActor.run {
                isProcessing = false
                showWaitingTime = false
                // Provide more helpful error message
                paymentService.errorMessage = "無法載入產品。請確保：\n1. 網絡連接正常\n2. App Store 服務可用\n3. 稍後再試"
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
                    // CRITICAL: Immediately navigate to loading page and start AI generation in background
                    // Don't wait for AI to finish - let it run in background
                    // Mark as paid immediately
                    viewModel.hasPaid = true
                    // Navigate to loading page immediately
                    viewModel.currentStep = .loading
                    // Start AI generation in background (non-blocking)
                    viewModel.generateLifeBlueprint()
                    // Don't show success alert - user is already on loading page
                    // showSuccess = true
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
// IMPORTANT: Apple Guideline 3.1.2(c) - Billed amount must be most prominent
struct PackageCard: View {
    let package: PaymentView.SubscriptionPackage
    let isSelected: Bool
    let billedAmount: String // The actual amount billed (most prominent)
    let monthlyEquivalent: String? // Monthly equivalent (subordinate, smaller)
    let onSelect: () -> Void
    
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
                        
                        // CRITICAL: Billed amount is MOST PROMINENT (large, bold)
                        VStack(alignment: .leading, spacing: BrandSpacing.xs) {
                            HStack(alignment: .firstTextBaseline, spacing: BrandSpacing.xs) {
                                Text(billedAmount)
                                    .font(BrandTypography.title) // Large, prominent font
                                    .fontWeight(.bold) // Bold for emphasis
                                    .foregroundColor(BrandColors.primaryText)
                                Text("/\(package.billingPeriod)")
                                    .font(BrandTypography.title3) // Smaller than billed amount
                                    .foregroundColor(BrandColors.secondaryText)
                            }
                            
                            // Monthly equivalent (subordinate, smaller, less prominent)
                            if let monthlyEq = monthlyEquivalent {
                                Text(monthlyEq)
                                    .font(BrandTypography.caption) // Much smaller font
                                    .foregroundColor(BrandColors.tertiaryText) // Less prominent color
                                    .padding(.top, 2) // Small spacing
                            }
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
                    .foregroundColor(Color.white) // CRITICAL: White text on purple background for proper contrast
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
