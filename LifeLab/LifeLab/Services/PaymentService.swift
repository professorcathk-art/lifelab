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
    }
    
    /// Load available products from App Store
    func loadProducts() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let products = try await Product.products(for: productIDs)
            self.products = products.sorted { $0.price < $1.price }
            print("✅ Loaded \(products.count) products from App Store")
        } catch {
            errorMessage = "無法載入產品：\(error.localizedDescription)"
            print("❌ Failed to load products: \(error.localizedDescription)")
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
                if let userId = AuthService.shared.currentUser?.id {
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
                errorMessage = "購買待處理中，請稍候"
                print("⚠️ Purchase pending - requires approval")
                return false
                
            @unknown default:
                errorMessage = "未知錯誤"
                print("❌ Unknown purchase result")
                return false
            }
        } catch {
            let errorDescription = error.localizedDescription
            errorMessage = "購買失敗：\(errorDescription)"
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
            errorMessage = "恢復購買失敗：\(error.localizedDescription)"
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
            try await SupabaseService.shared.saveUserSubscription(subscription)
            print("✅ Subscription saved to Supabase: \(planType.rawValue) plan for user \(userIdString)")
        } catch {
            print("⚠️ Failed to save subscription to Supabase: \(error.localizedDescription)")
            // Don't throw - subscription is still valid even if Supabase save fails
        }
    }
}
