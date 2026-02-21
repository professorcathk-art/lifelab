import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var dataService = DataService.shared
    @StateObject private var viewModel = InitialScanViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @StateObject private var paymentService = PaymentService.shared
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
                    // Check subscription status before showing main app
                    if hasValidSubscription {
                        MainTabView()
                            .environmentObject(dataService)
                            .environmentObject(themeManager)
                            .onAppear {
                                configureTabBarAppearance()
                                // Check subscription status periodically
                                Task {
                                    await subscriptionManager.checkSubscriptionStatus()
                                }
                            }
                            .onChange(of: themeManager.isDarkMode) { _ in
                                configureTabBarAppearance()
                            }
                            .onChange(of: subscriptionManager.hasActiveSubscription) { hasActive in
                                if !hasActive {
                                    showSubscriptionExpiredAlert = true
                                }
                            }
                    } else {
                        // Subscription expired - show payment page directly for renewal
                        // This simplifies the renewal flow and avoids navigation issues
                        InitialScanView()
                            .environmentObject(viewModel)
                            .environmentObject(themeManager)
                            .onAppear {
                                // Set to payment step
                                viewModel.currentStep = .payment
                                // Load products
                                Task {
                                    await paymentService.loadProducts()
                                }
                            }
                    }
                } else {
                    InitialScanView()
                        .environmentObject(viewModel)
                        .environmentObject(themeManager)
                        .onAppear {
                            if let profile = dataService.userProfile {
                                viewModel.basicInfo = profile.basicInfo ?? BasicUserInfo()
                                viewModel.selectedInterests = profile.interests
                                viewModel.strengths = profile.strengths
                                viewModel.selectedValues = profile.values
                                
                                // Restore state based on completion progress
                                // Priority: blueprint > payment > aiSummary > values > strengths > interests > basicInfo
                                if profile.lifeBlueprint != nil {
                                    // User has completed everything
                                    viewModel.lifeBlueprint = profile.lifeBlueprint
                                    viewModel.currentStep = .blueprint
                                } else if !profile.values.isEmpty {
                                    // User completed questionnaire - determine where they should be
                                    // CRITICAL: Check subscription status FIRST before deciding to skip payment
                                    // We need to wait for subscription check to complete
                                    Task {
                                        // Wait for subscription status check to complete
                                        await subscriptionManager.checkSubscriptionStatus()
                                        await paymentService.refreshPurchasedProducts()
                                        
                                        // CRITICAL: Only use SubscriptionManager's hasActiveSubscription
                                        // It checks BOTH StoreKit AND Supabase
                                        // Do NOT use paymentService.hasActiveSubscription alone
                                        let hasActiveSubscription = subscriptionManager.hasActiveSubscription
                                        
                                        await MainActor.run {
                                            if hasActiveSubscription {
                                                // User has active subscription in BOTH StoreKit AND Supabase
                                                print("✅✅✅ User has VALID subscription (StoreKit + Supabase), skipping payment and generating blueprint")
                                                viewModel.hasPaid = true // Mark as paid to allow blueprint generation
                                                viewModel.generateLifeBlueprint()
                                                viewModel.currentStep = .loading // Show loading while generating
                                            } else {
                                                // User has NO valid subscription - show payment page
                                                print("❌❌❌ User has NO valid subscription, showing payment page")
                                                print("   SubscriptionManager.hasActiveSubscription: \(subscriptionManager.hasActiveSubscription)")
                                                print("   PaymentService.hasActiveSubscription: \(paymentService.hasActiveSubscription)")
                                                print("   User MUST pay before generating blueprint")
                                                viewModel.currentStep = .payment
                                            }
                                        }
                                    }
                                    
                                    // Set to loading initially while we check subscription
                                    viewModel.currentStep = .loading
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
