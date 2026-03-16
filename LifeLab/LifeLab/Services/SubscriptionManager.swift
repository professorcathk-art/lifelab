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
    private let supabaseService = SupabaseServiceV2.shared
    
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
        // BUT: If network fails, fall back to StoreKit only (for better UX)
        var supabaseSubscription: UserSubscription?
        var supabaseCheckFailed = false
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
                // Check if this is a network error
                let nsError = error as NSError
                if nsError.domain == NSURLErrorDomain {
                    // Network error - Use StoreKit as fallback for better UX
                    // This allows users with valid StoreKit subscriptions to continue using the app
                    // even when network is temporarily unavailable
                    print("⚠️⚠️⚠️ Network error checking Supabase subscription")
                    print("   Error: \(error.localizedDescription)")
                    print("   Error code: \(nsError.code)")
                    print("   ⚠️ Using StoreKit as fallback for better user experience")
                    print("   ⚠️ User with StoreKit subscription can continue using app")
                    supabaseCheckFailed = true
                } else {
                    // Other error (e.g., authentication, not found)
                    print("❌❌❌ Failed to fetch subscription from Supabase: \(error.localizedDescription)")
                    print("   This means NO subscription in Supabase")
                    supabaseSubscription = nil
                }
            }
        }
        
        // CRITICAL: StoreKit is the AUTHORITATIVE source for subscription status
        // Apple's StoreKit automatically handles subscription expiration - if StoreKit shows active, it IS active
        // Supabase is only for syncing and record-keeping, NOT for access control
        
        // PRIORITY 1: If StoreKit shows active subscription, ALWAYS allow access
        // This prevents false blocking due to:
        // - Supabase sync delays after purchase
        // - Supabase database issues
        // - Network errors checking Supabase
        if hasStoreKitSubscription {
            // StoreKit shows active subscription - this is authoritative
            hasActiveSubscription = true
            
            // Try to get expiry date from Supabase if available
            if let subscription = supabaseSubscription {
                subscriptionExpiryDate = subscription.endDate
                currentPlanType = subscription.planType
                print("✅✅✅ VALID SUBSCRIPTION (StoreKit + Supabase) ✅✅✅")
                print("   StoreKit: ✅ Active (AUTHORITATIVE)")
                print("   Supabase: ✅ Active")
                print("   Plan: \(subscription.planType.rawValue)")
                print("   End Date: \(subscription.endDate)")
            } else {
                // StoreKit active but no Supabase record - still allow access
                // This can happen if:
                // - User just purchased (Supabase not synced yet)
                // - User restored purchases (Supabase not synced)
                // - Supabase database issue
                subscriptionExpiryDate = nil
                currentPlanType = nil
                if supabaseCheckFailed {
                    print("⚠️⚠️⚠️ STOREKIT ACTIVE - SUPABASE NETWORK ERROR ⚠️⚠️⚠️")
                    print("   StoreKit: ✅ Active (AUTHORITATIVE)")
                    print("   Supabase: ⚠️ Network error")
                    print("   ✅ User access granted based on StoreKit (Apple's authority)")
                } else {
                    print("⚠️⚠️⚠️ STOREKIT ACTIVE - NO SUPABASE RECORD ⚠️⚠️⚠️")
                    print("   StoreKit: ✅ Active (AUTHORITATIVE)")
                    print("   Supabase: ❌ No record (may be sync delay)")
                    print("   ✅ User access granted based on StoreKit (Apple's authority)")
                    print("   ℹ️ Supabase record will be created on next purchase or sync")
                }
            }
        } else {
            // StoreKit shows NO active subscription
            // This is the ONLY case where we deny access
            hasActiveSubscription = false
            subscriptionExpiryDate = nil
            currentPlanType = nil
            
            if supabaseSubscription != nil {
                // Supabase has record but StoreKit doesn't - StoreKit is authoritative
                print("❌❌❌ NO STOREKIT SUBSCRIPTION (AUTHORITATIVE) ❌❌❌")
                print("   StoreKit: ❌ No subscription (AUTHORITATIVE)")
                print("   Supabase: ✅ Has record (but StoreKit is authoritative)")
                print("   ⚠️ Access denied - StoreKit shows no active subscription")
                print("   ℹ️ User must purchase or restore purchases")
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
