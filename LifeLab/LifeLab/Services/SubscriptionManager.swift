import Foundation
import StoreKit
import Combine

/// SubscriptionManager - Manages subscription status and expiration
/// Checks subscription status from StoreKit and Supabase
@MainActor
class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    @Published var hasActiveSubscription: Bool = false
    @Published var subscriptionExpiryDate: Date?
    @Published var currentPlanType: UserSubscription.PlanType?
    @Published var isCheckingSubscription: Bool = false
    
    private let paymentService = PaymentService.shared
    private let supabaseService = SupabaseService.shared
    
    private init() {
        // Check subscription status on init
        Task {
            await checkSubscriptionStatus()
        }
        
        // Periodically check subscription status (every 5 minutes)
        Timer.publish(every: 300, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                Task { @MainActor in
                    await self?.checkSubscriptionStatus()
                }
            }
            .store(in: &cancellables)
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    /// Check subscription status from StoreKit AND Supabase
    /// CRITICAL: User must have subscription in BOTH StoreKit AND Supabase to skip payment
    /// If Supabase has no record, even if StoreKit shows active, user must pay
    func checkSubscriptionStatus() async {
        isCheckingSubscription = true
        defer { isCheckingSubscription = false }
        
        // Check StoreKit
        await paymentService.refreshPurchasedProducts()
        let hasStoreKitSubscription = paymentService.hasActiveSubscription
        
        // CRITICAL: Check Supabase - this is REQUIRED
        var supabaseSubscription: UserSubscription?
        if let userId = AuthService.shared.currentUser?.id {
            do {
                supabaseSubscription = try await supabaseService.fetchUserSubscription(userId: userId)
                if supabaseSubscription != nil {
                    print("✅✅✅ Found subscription in Supabase for user \(userId)")
                    print("   Plan: \(supabaseSubscription!.planType.rawValue)")
                    print("   Status: \(supabaseSubscription!.status.rawValue)")
                    print("   End Date: \(supabaseSubscription!.endDate)")
                } else {
                    print("❌❌❌ NO subscription found in Supabase for user \(userId)")
                    print("   Supabase subscription table is empty or no active subscription")
                }
            } catch {
                print("❌❌❌ Failed to fetch subscription from Supabase: \(error.localizedDescription)")
                print("   This means NO subscription in Supabase")
                supabaseSubscription = nil
            }
        }
        
        // CRITICAL: User must have subscription in BOTH StoreKit AND Supabase
        // If Supabase has no record, user MUST pay, even if StoreKit shows active
        if hasStoreKitSubscription && supabaseSubscription != nil {
            // User has active subscription in BOTH StoreKit AND Supabase
            let subscription = supabaseSubscription!
            
            // Check if subscription is still active (not expired)
            if subscription.status == .active && subscription.endDate > Date() {
                hasActiveSubscription = true
                subscriptionExpiryDate = subscription.endDate
                currentPlanType = subscription.planType
                print("✅✅✅ VALID SUBSCRIPTION FOUND ✅✅✅")
                print("   StoreKit: ✅ Active")
                print("   Supabase: ✅ Active")
                print("   Plan: \(subscription.planType.rawValue)")
                print("   End Date: \(subscription.endDate)")
            } else {
                // Subscription expired in Supabase
                hasActiveSubscription = false
                subscriptionExpiryDate = subscription.endDate
                currentPlanType = subscription.planType
                print("❌❌❌ SUBSCRIPTION EXPIRED IN SUPABASE ❌❌❌")
                print("   StoreKit: ✅ Active")
                print("   Supabase: ❌ Expired (endDate: \(subscription.endDate))")
                print("   User MUST pay to renew")
            }
        } else {
            // User does NOT have subscription in BOTH places
            hasActiveSubscription = false
            subscriptionExpiryDate = nil
            currentPlanType = nil
            
            if hasStoreKitSubscription && supabaseSubscription == nil {
                print("❌❌❌ STOREKIT HAS SUBSCRIPTION BUT SUPABASE DOES NOT ❌❌❌")
                print("   StoreKit: ✅ Active")
                print("   Supabase: ❌ NO RECORD")
                print("   ⚠️ CRITICAL: User MUST pay - Supabase subscription table is empty")
                print("   This means subscription was not properly saved to Supabase")
            } else if !hasStoreKitSubscription && supabaseSubscription != nil {
                print("❌❌❌ SUPABASE HAS SUBSCRIPTION BUT STOREKIT DOES NOT ❌❌❌")
                print("   StoreKit: ❌ No subscription")
                print("   Supabase: ✅ Has record")
                print("   ⚠️ CRITICAL: User MUST pay - StoreKit subscription not found")
            } else {
                print("❌❌❌ NO SUBSCRIPTION FOUND ❌❌❌")
                print("   StoreKit: ❌ No subscription")
                print("   Supabase: ❌ No subscription")
                print("   User MUST pay")
            }
        }
        
        print("📊📊📊 FINAL SUBSCRIPTION STATUS 📊📊📊")
        print("   Has Active Subscription: \(hasActiveSubscription)")
        print("   Expiry Date: \(subscriptionExpiryDate?.description ?? "N/A")")
        print("   Plan Type: \(currentPlanType?.rawValue ?? "N/A")")
        print("   StoreKit Active: \(hasStoreKitSubscription)")
        print("   Supabase Record: \(supabaseSubscription != nil ? "YES" : "NO")")
    }
    
    /// Check if subscription is expired
    var isSubscriptionExpired: Bool {
        guard let expiryDate = subscriptionExpiryDate else {
            // No expiry date means no subscription
            return !hasActiveSubscription
        }
        return expiryDate < Date() && !hasActiveSubscription
    }
    
    /// Check if subscription is expiring soon (within 7 days)
    var isSubscriptionExpiringSoon: Bool {
        guard let expiryDate = subscriptionExpiryDate else {
            return false
        }
        let daysUntilExpiry = Calendar.current.dateComponents([.day], from: Date(), to: expiryDate).day ?? 0
        return daysUntilExpiry <= 7 && daysUntilExpiry > 0
    }
}
