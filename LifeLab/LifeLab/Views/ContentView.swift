import SwiftUI
import UIKit

struct ContentView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var themeManager: ThemeManager
    @StateObject private var viewModel = InitialScanViewModel()
    // IMPORTANT: Use @ObservedObject for shared singletons, not @StateObject
    // @StateObject creates new instances, but singletons should be observed, not owned
    @ObservedObject private var subscriptionManager = SubscriptionManager.shared
    @ObservedObject private var paymentService = PaymentService.shared
    @State private var showSubscriptionExpiredAlert = false
    
    var hasCompletedInitialScan: Bool {
        dataService.userProfile?.lifeBlueprint != nil
    }
    
    var hasValidSubscription: Bool {
        // CRITICAL: Only use SubscriptionManager's hasActiveSubscription
        // It checks BOTH StoreKit AND Supabase
        // Do NOT use paymentService.hasActiveSubscription alone
        subscriptionManager.hasActiveSubscription
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BrandColors.background
                    .ignoresSafeArea()
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                
                // Use onChange to immediately react to blueprint changes
                if hasCompletedInitialScan {
                    // CRITICAL: If user has blueprint, they should ALWAYS see MainTabView
                    // Don't check subscription here - subscription check is for payment, not for access
                    // Once blueprint is generated, user has access to the app
                    MainTabView()
                        .environmentObject(dataService)
                        .environmentObject(themeManager)
                        .onAppear {
                            configureTabBarAppearance()
                            // Check subscription status periodically (for renewal reminders)
                            Task {
                                await subscriptionManager.checkSubscriptionStatus()
                            }
                        }
                        .onChange(of: themeManager.isDarkMode) { _ in
                            configureTabBarAppearance()
                        }
                        .onChange(of: subscriptionManager.hasActiveSubscription) { hasActive in
                            // CRITICAL: Only show alert if user already has blueprint AND subscription actually expired
                            // Don't show alert if:
                            // 1. User doesn't have blueprint yet (they're still in initial scan)
                            // 2. Subscription check fails due to network issues
                            // 3. User just purchased (subscription might not be synced yet)
                            
                            // Only check if user has completed initial scan (has blueprint)
                            guard hasCompletedInitialScan else {
                                print("ℹ️ User hasn't completed initial scan yet, skipping subscription expiry check")
                                return
                            }
                            
                            if !hasActive {
                                // Wait a bit before checking again (might be network issue or sync delay)
                                Task {
                                    try? await Task.sleep(nanoseconds: 2_000_000_000) // Wait 2 seconds
                                    // Re-check to see if it's a network issue or sync delay
                                    await subscriptionManager.checkSubscriptionStatus()
                                    
                                    // Only show alert if still false after re-check AND user has blueprint
                                    if !subscriptionManager.hasActiveSubscription && hasCompletedInitialScan {
                                        await MainActor.run {
                                            showSubscriptionExpiredAlert = true
                                        }
                                    }
                                }
                            }
                        }
                } else {
                    InitialScanView()
                        .environmentObject(viewModel)
                        .environmentObject(themeManager)
                        .onAppear {
                            // CRITICAL: Wait for data to load if authenticated
                            // This handles the case where data is loading from Supabase
                            if AuthService.shared.isAuthenticated && dataService.userProfile == nil {
                                print("⏳ ContentView: Waiting for profile to load from Supabase...")
                                // Data is loading, wait for onChange to handle it
                                return
                            }
                            
                            restoreProfileState()
                        }
                        .onChange(of: dataService.userProfile) { profile in
                            // CRITICAL: React when profile is loaded from Supabase
                            // This ensures we restore state even if onAppear ran before data loaded
                            if profile != nil {
                                print("✅ ContentView: Profile loaded, restoring state...")
                                restoreProfileState()
                            }
                        }
                }
            }
        }
        .onChange(of: dataService.userProfile?.lifeBlueprint) { blueprint in
            // Immediately react when blueprint is generated
            // This ensures smooth navigation without delay
            if blueprint != nil {
                print("✅ ContentView detected blueprint, switching to MainTabView")
                // Check subscription when blueprint is available
                Task {
                    await subscriptionManager.checkSubscriptionStatus()
                }
            }
        }
        .onAppear {
            // Check subscription status on app launch
            Task {
                await subscriptionManager.checkSubscriptionStatus()
            }
        }
        .alert("訂閱已過期", isPresented: $showSubscriptionExpiredAlert) {
            Button("續訂") {
                // Navigate to payment page
                viewModel.currentStep = .payment
            }
            Button("稍後", role: .cancel) { }
        } message: {
            Text("您的訂閱已過期，請續訂以繼續使用 LifeLab 的所有功能。")
        }
    }
    
    // MARK: - Helper Methods
    
    /// Restore profile state in InitialScanView based on completion progress
    private func restoreProfileState() {
        guard let profile = dataService.userProfile else {
            // No profile exists - reset to first page (basicInfo)
            // This happens when user clears all data or is a new user
            viewModel.resetInitialScan()
            viewModel.loadAIConsentStatus() // Reload consent status (should be false after clear)
            print("✅ ContentView: No profile found, resetting to initial scan (basicInfo)")
            return
        }
        
        // Reload consent status (may have changed, e.g. after login)
        viewModel.loadAIConsentStatus()
        
        print("🔍🔍🔍 restoreProfileState() called 🔍🔍🔍")
        print("   Profile has:")
        print("     - Interests: \(profile.interests.count)")
        print("     - Strengths: \(profile.strengths.count)")
        print("     - Values: \(profile.values.count)")
        print("     - lifeBlueprint: \(profile.lifeBlueprint != nil ? "YES ✅" : "NO ❌")")
        print("     - hasGivenAIConsent: \(viewModel.hasGivenAIConsent)")
        print("     - hasCompletedInitialScan: \(hasCompletedInitialScan)")
        
        // CRITICAL: Check if user has blueprint FIRST - if yes, skip all restoration logic
        // ContentView's hasCompletedInitialScan will automatically show MainTabView
        if profile.lifeBlueprint != nil {
            // User has completed everything - ContentView will show MainTabView
            // Don't set currentStep or restore any state - ContentView handles navigation automatically
            viewModel.lifeBlueprint = profile.lifeBlueprint
            print("✅✅✅ ContentView: User HAS blueprint - ContentView will show MainTabView automatically")
            print("   hasCompletedInitialScan = \(hasCompletedInitialScan)")
            print("   ⚠️ SKIPPING all restoration logic - user should see MainTabView, not InitialScanView")
            // CRITICAL: Don't restore form data or set currentStep - just return
            // This ensures user goes directly to MainTabView without seeing any questionnaire pages
            return
        }
        
        // Only restore form data if user doesn't have blueprint
        viewModel.basicInfo = profile.basicInfo ?? BasicUserInfo()
        viewModel.selectedInterests = profile.interests
        viewModel.strengths = profile.strengths
        viewModel.selectedValues = profile.values
        
        // Restore state based on completion progress
        // Priority: blueprint > aiConsent > aiSummary > payment > values > strengths > interests > basicInfo
        print("   No blueprint found, restoring to appropriate step...")
        if !profile.values.isEmpty {
            // User completed questionnaire
            // CRITICAL: Check AI consent FIRST - user must consent before we can generate AI summary
            // Flow: values → aiConsent (if no consent) → aiSummary → payment → blueprint
            if !viewModel.hasGivenAIConsent {
                // User hasn't given AI consent - show consent page first
                print("   📋 AI consent not given, showing AI consent page")
                viewModel.currentStep = .aiConsent
            } else if viewModel.aiSummary.isEmpty {
                // AI summary not generated yet, show AI summary page and generate
                print("   📋 AI summary not found, showing AI summary page")
                viewModel.currentStep = .aiSummary
                viewModel.generateAISummary()
            } else {
                // AI summary already exists, check if user has paid/generated blueprint
                print("   📋 AI summary exists, checking next step...")
                // Check subscription status to determine if should show payment or can generate blueprint
                Task {
                    await subscriptionManager.checkSubscriptionStatus()
                    await paymentService.refreshPurchasedProducts()
                    
                    let hasActiveSubscription = subscriptionManager.hasActiveSubscription
                    
                    await MainActor.run {
                        if hasActiveSubscription {
                            print("✅✅✅ User has VALID subscription (StoreKit + Supabase), skipping payment and generating blueprint")
                            viewModel.hasPaid = true
                            // CRITICAL: Only generate if blueprint doesn't exist
                            if profile.lifeBlueprint == nil {
                                viewModel.generateLifeBlueprint()
                                viewModel.currentStep = .loading
                            } else {
                                // Blueprint already exists, just show it
                                viewModel.lifeBlueprint = profile.lifeBlueprint
                                viewModel.currentStep = .blueprint
                            }
                        } else {
                            print("❌❌❌ User has NO valid subscription, showing payment page")
                            viewModel.currentStep = .payment
                        }
                    }
                }
                viewModel.currentStep = .loading
            }
        } else if !profile.strengths.isEmpty {
            viewModel.currentStep = .values
        } else if !profile.interests.isEmpty {
            viewModel.currentStep = .strengths
        } else if profile.basicInfo != nil {
            viewModel.currentStep = .interests
        } else {
            viewModel.currentStep = .basicInfo
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        if themeManager.isDarkMode {
            // Dark Mode: Pure black background
            appearance.backgroundColor = UIColor.black
            appearance.shadowColor = UIColor(hex: "333333")
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: "8E8E93")
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(hex: "8E8E93")
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(hex: "FFC107") // Golden yellow
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(hex: "FFC107")
            ]
        } else {
            // Day Mode: Pure white or ultraThinMaterial
            appearance.backgroundColor = UIColor.white
            appearance.shadowColor = UIColor(hex: "E5E5EA") // Very light gray divider
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(hex: "8E8E93")
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [
                .foregroundColor: UIColor(hex: "8E8E93")
            ]
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(hex: "6B4EFF") // Periwinkle blue
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [
                .foregroundColor: UIColor(hex: "6B4EFF")
            ]
        }
        
        appearance.shadowImage = UIImage()
        appearance.selectionIndicatorTintColor = .clear
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

struct MainTabView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        TabView {
            DashboardView()
                .environmentObject(themeManager)
                .tabItem {
                    Label("首頁", systemImage: "house.fill")
                }
            
            DeepeningExplorationView()
                .environmentObject(themeManager)
                .tabItem {
                    Label("深化探索", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            TaskManagementView()
                .environmentObject(themeManager)
                .tabItem {
                    Label("任務", systemImage: "checkmark.circle.fill")
                }
            
            ProfileView()
                .environmentObject(themeManager)
                .tabItem {
                    Label("個人檔案", systemImage: "person.fill")
                }
            
            SettingsView()
                .environmentObject(themeManager)
                .tabItem {
                    Label("設定", systemImage: "gearshape.fill")
                }
        }
        .accentColor(themeManager.isDarkMode ? BrandColors.brandAccent : BrandColors.actionAccent)
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
    }
}

#Preview {
    ContentView()
}

// MARK: - UIColor Extension for Hex
extension UIColor {
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}
