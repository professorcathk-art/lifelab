import Foundation
import StoreKit
import Combine

/// PaymentService - Simplest payment integration using StoreKit 2
/// This is the easiest way to integrate payments in iOS
@MainActor
class PaymentService: ObservableObject {
    static let shared = PaymentService()
    
    @Published var products: [Product] = []
    @Published var purchasedProductIDs: Set<String> = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    // Product IDs (must match App Store Connect configuration)
    private let productIDs: [String] = [
        "com.resonance.lifelab.annually",    // Annual subscription (USD 89.99/year)
        "com.resonance.lifelab.quarterly",   // Quarterly subscription
        "com.resonance.lifelab.monthly"       // Monthly subscription
    ]
    
    private init() {
        // Load purchased products on init
        Task {
            await loadPurchasedProducts()
        }
        
        // CRITICAL: Listen for transaction updates to catch successful purchases
        // This prevents missing purchases if app is closed during purchase
        Task {
            for await update in Transaction.updates {
                do {
                    let transaction = try checkVerified(update)
                    print("✅ Transaction update received: \(transaction.productID)")
                    await updatePurchasedProducts()
                    await saveSubscriptionToSupabase(
                        productID: transaction.productID,
                        transactionID: String(transaction.id),
                        purchaseDate: transaction.purchaseDate
                    )
                    await transaction.finish()
                } catch {
                    print("⚠️ Failed to process transaction update: \(error.localizedDescription)")
                }
            }
        }
    }
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            print("🔄 Requesting products from App Store...")
            print("📦 Product IDs: \(productIDs)")
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted { $0.price < $1.price }
            print("✅ Loaded \(products.count)/\(productIDs.count) products from App Store")
            
            if products.count < productIDs.count {
                let loadedIDs = Set(products.map { $0.id })
                let missingIDs = productIDs.filter { !loadedIDs.contains($0) }
                print("⚠️ Missing products: \(missingIDs)")
                print("💡 This may be normal if products are still syncing to sandbox environment")
            }
            
            // Log each loaded product
            for product in products {
                print("   - \(product.id): \(product.displayPrice) (\(product.type))")
            }
        } catch {
            let errorDescription = error.localizedDescription
            // Professional error message for product loading
            if errorDescription.contains("network") || errorDescription.contains("connection") {
                errorMessage = "無法連接到 App Store。\n\n請檢查：\n• 設備是否已連接到網絡\n• App Store 服務是否可用\n\n確認後請稍後再試。"
            } else {
                errorMessage = "無法載入產品資訊。\n\n\(errorDescription)\n\n請稍後再試，如問題持續存在，請聯繫客服。"
            }
            print("❌ Failed to load products: \(errorDescription)")
            print("   Error type: \(type(of: error))")
            print("   Error details: \(error)")
            
            // Provide more specific error messages
            if let storeKitError = error as? StoreKitError {
                print("   StoreKit error code: \(storeKitError)")
            }
        }
        
        isLoading = false
    }
    
    /// Purchase a product
    func purchase(_ product: Product) async throws -> Bool {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            print("🛒 Attempting to purchase: \(product.id) - \(product.displayPrice)")
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                print("✅ Transaction verified: \(transaction.productID)")
                print("   Transaction ID: \(transaction.id)")
                print("   Purchase Date: \(transaction.purchaseDate)")
                
                // Update purchased products
                await updatePurchasedProducts()
                
                // CRITICAL: Save subscription to Supabase FIRST
                // This ensures SubscriptionManager can find the subscription record
                // Note: transaction.id is UInt64, convert to String
                await saveSubscriptionToSupabase(productID: transaction.productID, transactionID: String(transaction.id), purchaseDate: transaction.purchaseDate)
                
                // CRITICAL: Refresh SubscriptionManager to update hasActiveSubscription
                // This ensures the subscription check works correctly after purchase
                await SubscriptionManager.shared.checkSubscriptionStatus()
                
                // IMPORTANT: After successful purchase, ensure user data is synced to Supabase
                // This ensures data persistence and allows data restoration after renewal
                if AuthService.shared.currentUser?.id != nil {
                    Task {
                        await DataService.shared.syncToSupabase()
                        print("✅ User data synced to Supabase after purchase")
                    }
                }
                
                // IMPORTANT: Load user data from Supabase after purchase
                // This restores any data that was saved during subscription period
                if let userId = AuthService.shared.currentUser?.id {
                    Task {
                        await DataService.shared.loadFromSupabase(userId: userId)
                        print("✅ User data loaded from Supabase after purchase")
                    }
                }
                
                // Finish the transaction (important: only finish after verification)
                await transaction.finish()
                
                print("✅ Purchase successful: \(product.id)")
                return true
                
            case .userCancelled:
                print("⚠️ User cancelled purchase")
                errorMessage = nil // Don't show error for user cancellation
                return false
                
            case .pending:
                errorMessage = "購買正在處理中。\n\n您的購買請求已提交，正在等待審核。完成後您將收到通知。"
                print("⚠️ Purchase pending - requires approval")
                return false
                
            @unknown default:
                errorMessage = "購買過程中發生未知錯誤。\n\n請稍後再試，如問題持續存在，請聯繫客服。"
                print("❌ Unknown purchase result")
                return false
            }
        } catch {
            let errorDescription = error.localizedDescription
            // Professional error message based on error type
            if errorDescription.contains("network") || errorDescription.contains("connection") {
                errorMessage = "無法連接到 App Store。\n\n請檢查：\n• 設備是否已連接到網絡\n• App Store 服務是否可用\n\n確認後請稍後再試。"
            } else if errorDescription.contains("payment") || errorDescription.contains("billing") {
                errorMessage = "支付處理失敗。\n\n請檢查：\n• Apple ID 是否已設置付款方式\n• 付款方式是否有效\n• 是否有足夠的餘額\n\n如需協助，請聯繫 Apple 客服。"
            } else {
                errorMessage = "購買失敗。\n\n\(errorDescription)\n\n請稍後再試，如問題持續存在，請聯繫客服。"
            }
            print("❌ Purchase failed: \(errorDescription)")
            print("   Error details: \(error)")
            throw error
        }
    }
    
    /// Restore purchases
    func restorePurchases() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        do {
            try await AppStore.sync()
            await updatePurchasedProducts()
            print("✅ Purchases restored")
        } catch {
            // Professional error message for restore purchases
            let errorDescription = error.localizedDescription
            if errorDescription.contains("network") || errorDescription.contains("connection") {
                errorMessage = "無法連接到 App Store。\n\n請檢查：\n• 設備是否已連接到網絡\n• App Store 服務是否可用\n\n確認後請稍後再試。"
            } else {
                errorMessage = "恢復購買失敗。\n\n\(errorDescription)\n\n請稍後再試，如問題持續存在，請聯繫客服。"
            }
            print("❌ Failed to restore purchases: \(error.localizedDescription)")
        }
    }
    
    /// Check if user has active subscription
    var hasActiveSubscription: Bool {
        !purchasedProductIDs.isEmpty
    }
    
    /// Check if specific product is purchased
    func isPurchased(_ productID: String) -> Bool {
        purchasedProductIDs.contains(productID)
    }
    
    /// Refresh purchased products (public method for external calls)
    func refreshPurchasedProducts() async {
        await updatePurchasedProducts()
    }
    
    // MARK: - Private Methods
    
    private func loadPurchasedProducts() async {
        await updatePurchasedProducts()
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        // Check current entitlements (active subscriptions)
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
                print("✅ Found active subscription: \(transaction.productID)")
            } catch {
                print("⚠️ Failed to verify transaction: \(error)")
            }
        }
        
        // Also check all transactions (including non-renewing subscriptions)
        for await result in Transaction.all {
            do {
                let transaction = try checkVerified(result)
                // Only add if it's a subscription product
                if productIDs.contains(transaction.productID) {
                    purchasedIDs.insert(transaction.productID)
                    print("✅ Found transaction: \(transaction.productID)")
                }
            } catch {
                print("⚠️ Failed to verify transaction: \(error)")
            }
        }
        
        purchasedProductIDs = purchasedIDs
        print("✅ Updated purchased products: \(purchasedIDs)")
    }
    
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw NSError(domain: "PaymentService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Transaction verification failed"])
        case .verified(let safe):
            return safe
        }
    }
    
    /// Save subscription to Supabase
    private func saveSubscriptionToSupabase(productID: String, transactionID: String, purchaseDate: Date) async {
        // Get user ID from AuthService (returns String UUID)
        guard let userIdString = AuthService.shared.currentUser?.id,
              let userId = UUID(uuidString: userIdString) else {
            print("⚠️ Cannot save subscription: User not authenticated or invalid user ID")
            return
        }
        
        // Determine plan type from product ID
        let planType: UserSubscription.PlanType
        if productID.contains("annually") || productID.contains("yearly") {
            planType = .yearly
        } else if productID.contains("quarterly") {
            planType = .quarterly
        } else {
            planType = .monthly
        }
        
        // Calculate end date based on plan type
        let calendar = Calendar.current
        let endDate: Date
        switch planType {
        case .yearly:
            endDate = calendar.date(byAdding: .year, value: 1, to: purchaseDate) ?? purchaseDate
        case .quarterly:
            endDate = calendar.date(byAdding: .month, value: 3, to: purchaseDate) ?? purchaseDate
        case .monthly:
            endDate = calendar.date(byAdding: .month, value: 1, to: purchaseDate) ?? purchaseDate
        }
        
        let subscription = UserSubscription(
            id: UUID(),
            userId: userId,
            planType: planType,
            status: .active,
            startDate: purchaseDate,
            endDate: endDate
        )
        
        do {
            try await SupabaseServiceV2.shared.saveUserSubscription(subscription)
            print("✅ Subscription saved to Supabase: \(planType.rawValue) plan for user \(userIdString)")
        } catch {
            print("⚠️ Failed to save subscription to Supabase: \(error.localizedDescription)")
            // Don't throw - subscription is still valid even if Supabase save fails
        }
    }
}
