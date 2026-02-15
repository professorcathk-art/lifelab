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
        "com.resonance.lifelab.yearly",
        "com.resonance.lifelab.quarterly",
        "com.resonance.lifelab.monthly"
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
            let result = try await product.purchase()
            
            switch result {
            case .success(let verification):
                // Verify the transaction
                let transaction = try checkVerified(verification)
                
                // Update purchased products
                await updatePurchasedProducts()
                
                // Finish the transaction
                await transaction.finish()
                
                print("✅ Purchase successful: \(product.id)")
                return true
                
            case .userCancelled:
                print("⚠️ User cancelled purchase")
                return false
                
            case .pending:
                errorMessage = "購買待處理中，請稍候"
                print("⚠️ Purchase pending")
                return false
                
            @unknown default:
                errorMessage = "未知錯誤"
                return false
            }
        } catch {
            errorMessage = "購買失敗：\(error.localizedDescription)"
            print("❌ Purchase failed: \(error.localizedDescription)")
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
    
    // MARK: - Private Methods
    
    private func loadPurchasedProducts() async {
        await updatePurchasedProducts()
    }
    
    private func updatePurchasedProducts() async {
        var purchasedIDs: Set<String> = []
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                purchasedIDs.insert(transaction.productID)
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
}
