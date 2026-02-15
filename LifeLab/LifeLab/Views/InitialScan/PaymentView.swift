import SwiftUI
import StoreKit

struct PaymentView: View {
    @EnvironmentObject var viewModel: InitialScanViewModel
    @StateObject private var paymentService = PaymentService.shared
    @State private var selectedPackage: SubscriptionPackage = .yearly
    @State private var isProcessing = false
    @State private var showError = false
    @State private var showSuccess = false
    @State private var showPromoCodeSheet = false
    @State private var promoCode = ""
    @State private var promoCodeError = ""
    @State private var promoCodeVerified = false
    
    // Secret promo code (change this to your desired code)
    private let secretPromoCode = "LIFELAB2024"
    
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
            case .yearly: return "com.resonance.lifelab.yearly"
            case .quarterly: return "com.resonance.lifelab.quarterly"
            case .monthly: return "com.resonance.lifelab.monthly"
            }
        }
        
        var price: String {
            // Will be updated from StoreKit products
            switch self {
            case .yearly: return "$7.9"
            case .quarterly: return "$9.9"
            case .monthly: return "$18.99"
            }
        }
        
        var period: String {
            switch self {
            case .yearly: return "/月（年付）"
            case .quarterly: return "/月（季付，90天週期）"
            case .monthly: return "/月（月付）"
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
                return product.displayPrice
            }
            return price // Fallback
        }
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 32) {
                VStack(spacing: BrandSpacing.lg) {
                    Image(systemName: "lock.shield.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(BrandColors.primaryGradient)
                    
                    Text("解鎖初版生命藍圖")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("選擇訂閱方案，即可查看AI為您生成的個人化生命藍圖")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.xxxl)
                }
                .padding(.top, BrandSpacing.xxxl)
                
                // Subscription packages
                VStack(spacing: 16) {
                    if paymentService.isLoading {
                        ProgressView("載入產品中...")
                            .padding()
                    } else if paymentService.products.isEmpty {
                        // Fallback: Show packages with default prices
                        ForEach(SubscriptionPackage.allCases, id: \.self) { package in
                            PackageCard(
                                package: package,
                                isSelected: selectedPackage == package,
                                price: package.price(from: paymentService.products),
                                onSelect: {
                                    selectedPackage = package
                                }
                            )
                        }
                    } else {
                        // Show packages with real prices from StoreKit
                        ForEach(SubscriptionPackage.allCases, id: \.self) { package in
                            PackageCard(
                                package: package,
                                isSelected: selectedPackage == package,
                                price: package.price(from: paymentService.products),
                                onSelect: {
                                    selectedPackage = package
                                }
                            )
                        }
                    }
                }
                .padding(.horizontal, 20)
                .onAppear {
                    // Load products when view appears
                    Task {
                        await paymentService.loadProducts()
                    }
                }
                
                // Promo code button
                Button(action: {
                    showPromoCodeSheet = true
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "ticket.fill")
                        Text("使用優惠碼")
                    }
                    .font(BrandTypography.subheadline)
                    .foregroundColor(BrandColors.primaryBlue)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.md)
                    .background(BrandColors.primaryBlue.opacity(0.1))
                    .cornerRadius(BrandRadius.medium)
                }
                .buttonStyle(.plain)
                .padding(.horizontal, BrandSpacing.xxxl)
                
                // Subscribe button with StoreKit integration
                Button(action: {
                    Task {
                        await handlePurchase()
                    }
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        if isProcessing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "lock.open.fill")
                        }
                        Text(isProcessing ? "處理中..." : "訂閱並解鎖")
                    }
                    .font(BrandTypography.subheadline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.md)
                    .background(BrandColors.primaryGradient)
                    .cornerRadius(BrandRadius.medium)
                    .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(isProcessing || viewModel.isLoadingBlueprint || paymentService.isLoading)
                .padding(.horizontal, BrandSpacing.xxxl)
                
                Text("註：可使用優惠碼功能")
                    .font(BrandTypography.caption)
                    .foregroundColor(BrandColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.xxxl)
                    .padding(.bottom, BrandSpacing.xxxl)
            }
        }
        .sheet(isPresented: $showPromoCodeSheet) {
            PromoCodeSheet(
                promoCode: $promoCode,
                errorMessage: $promoCodeError,
                onVerify: {
                    verifyPromoCode()
                },
                onDismiss: {
                    showPromoCodeSheet = false
                    promoCode = ""
                    promoCodeError = ""
                }
            )
        }
        .alert("購買成功", isPresented: $showSuccess) {
            Button("確定") {
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
        .alert("優惠碼驗證成功", isPresented: $promoCodeVerified) {
            Button("確定") {
                isProcessing = true
                viewModel.completePayment()
                showPromoCodeSheet = false
                promoCode = ""
                promoCodeError = ""
                promoCodeVerified = false
            }
        } message: {
            Text("優惠碼驗證成功！正在為您生成生命藍圖...")
        }
    }
    
    private func verifyPromoCode() {
        let enteredCode = promoCode.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if enteredCode.isEmpty {
            promoCodeError = "請輸入優惠碼"
            return
        }
        
        if enteredCode == secretPromoCode {
            promoCodeError = ""
            promoCodeVerified = true
        } else {
            promoCodeError = "優惠碼無效，請重新輸入"
        }
    }
    
    private func handlePurchase() async {
        isProcessing = true
        
        // Find the selected product
        let productID = selectedPackage.productID
        guard let product = paymentService.products.first(where: { $0.id == productID }) else {
            // If product not loaded, use skip payment for testing
            print("⚠️ Product not loaded, using skip payment")
            await MainActor.run {
                isProcessing = false
                viewModel.completePayment()
            }
            return
        }
        
        do {
            let success = try await paymentService.purchase(product)
            await MainActor.run {
                isProcessing = false
                if success {
                    showSuccess = true
                    // Payment successful, complete payment will be called from alert
                } else {
                    // User cancelled or pending
                    if paymentService.errorMessage != nil {
                        showError = true
                    }
                }
            }
        } catch {
            await MainActor.run {
                isProcessing = false
                showError = true
            }
        }
    }
}

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
    
    var body: some View {
        Button(action: onSelect) {
            HStack {
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    HStack {
                        Text(package.title)
                            .font(BrandTypography.headline)
                            .foregroundColor(BrandColors.primaryText)
                        
                        if let savings = package.savings {
                            Text(savings)
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.primaryBlue)
                                .fontWeight(.semibold)
                                .padding(.horizontal, BrandSpacing.sm)
                                .padding(.vertical, BrandSpacing.xs)
                                .background(BrandColors.primaryBlue.opacity(0.15))
                                .cornerRadius(BrandRadius.small)
                        }
                    }
                    
                    HStack(alignment: .firstTextBaseline, spacing: BrandSpacing.xs) {
                        Text(price)
                            .font(BrandTypography.title2)
                            .foregroundColor(BrandColors.primaryText)
                        Text(package.period)
                            .font(BrandTypography.subheadline)
                            .foregroundColor(BrandColors.secondaryText)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? BrandColors.primaryBlue : BrandColors.tertiaryText)
            }
            .padding()
            .background(isSelected ? BrandColors.primaryBlue.opacity(0.15) : BrandColors.secondaryBackground)
            .cornerRadius(BrandRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: BrandRadius.medium)
                    .stroke(isSelected ? BrandColors.primaryBlue : Color.clear, lineWidth: 2)
            )
            .shadow(color: isSelected ? BrandColors.primaryBlue.opacity(0.2) : BrandShadow.small.color, 
                   radius: isSelected ? 8 : BrandShadow.small.radius, 
                   x: 0, 
                   y: isSelected ? 4 : BrandShadow.small.y)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Promo Code Sheet

struct PromoCodeSheet: View {
    @Binding var promoCode: String
    @Binding var errorMessage: String
    let onVerify: () -> Void
    let onDismiss: () -> Void
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        NavigationView {
            VStack(spacing: BrandSpacing.xl) {
                VStack(spacing: BrandSpacing.md) {
                    Image(systemName: "ticket.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(BrandColors.primaryGradient)
                    
                    Text("輸入優惠碼")
                        .font(BrandTypography.largeTitle)
                        .foregroundColor(BrandColors.primaryText)
                    
                    Text("輸入優惠碼即可跳過付款，直接生成生命藍圖")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.secondaryText)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, BrandSpacing.lg)
                }
                .padding(.top, BrandSpacing.xxxl)
                
                VStack(alignment: .leading, spacing: BrandSpacing.sm) {
                    Text("優惠碼")
                        .font(BrandTypography.headline)
                        .foregroundColor(BrandColors.primaryText)
                    
                    TextField("請輸入優惠碼", text: $promoCode)
                        .textFieldStyle(.plain)
                        .font(BrandTypography.body)
                        .padding(BrandSpacing.md)
                        .background(
                            RoundedRectangle(cornerRadius: BrandRadius.medium)
                                .fill(BrandColors.secondaryBackground)
                                .overlay(
                                    RoundedRectangle(cornerRadius: BrandRadius.medium)
                                        .stroke(errorMessage.isEmpty ? BrandColors.primaryBlue.opacity(0.2) : Color.red.opacity(0.5), lineWidth: 1)
                                )
                        )
                        .autocapitalization(.allCharacters)
                        .autocorrectionDisabled()
                        .focused($isTextFieldFocused)
                        .onSubmit {
                            onVerify()
                        }
                    
                    if !errorMessage.isEmpty {
                        HStack(spacing: BrandSpacing.xs) {
                            Image(systemName: "exclamationmark.circle.fill")
                                .foregroundColor(.red)
                                .font(.system(size: 14))
                            Text(errorMessage)
                                .font(BrandTypography.caption)
                                .foregroundColor(.red)
                        }
                        .padding(.leading, BrandSpacing.sm)
                    }
                }
                .padding(.horizontal, BrandSpacing.xxxl)
                
                Spacer()
                
                Button(action: {
                    onVerify()
                }) {
                    HStack(spacing: BrandSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                        Text("驗證優惠碼")
                    }
                    .font(BrandTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.lg)
                    .background(BrandColors.primaryGradient)
                    .cornerRadius(BrandRadius.medium)
                    .shadow(color: BrandColors.primaryBlue.opacity(0.3), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
                .disabled(promoCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(promoCode.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
                .padding(.horizontal, BrandSpacing.xxxl)
                .padding(.bottom, BrandSpacing.xxxl)
            }
            .navigationTitle("優惠碼")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        onDismiss()
                    }
                    .foregroundColor(BrandColors.primaryBlue)
                }
            }
            .onAppear {
                // Auto-focus text field when sheet appears
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    isTextFieldFocused = true
                }
            }
        }
    }
}

#Preview {
    PaymentView()
        .environmentObject(InitialScanViewModel())
}

#Preview {
    PaymentView()
        .environmentObject(InitialScanViewModel())
}
