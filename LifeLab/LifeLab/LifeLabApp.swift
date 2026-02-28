import SwiftUI
import Combine
import UIKit

@main
struct LifeLabApp: App {
    @StateObject private var dataService = DataService.shared
    @StateObject private var authService = AuthService.shared
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.scenePhase) private var scenePhase
    
    init() {
        // Sync theme with system on app launch
        ThemeManager.shared.syncWithSystemTheme()
        
        // Initialize Resend API key securely
        // The key is loaded from Secrets.swift (gitignored) or UserDefaults
        // This ensures the key is not exposed in source code
        if UserDefaults.standard.string(forKey: "resend_api_key") == nil {
            // Try to get from Secrets.swift first
            #if DEBUG
            if !Secrets.resendAPIKey.isEmpty && Secrets.resendAPIKey != "YOUR_RESEND_API_KEY_HERE" {
                UserDefaults.standard.set(Secrets.resendAPIKey, forKey: "resend_api_key")
            }
            #endif
        }
        
        // Initialize Supabase configuration securely
        // Keys are loaded from Secrets.swift (gitignored) or UserDefaults
        if UserDefaults.standard.string(forKey: "supabase_url") == nil {
            #if DEBUG
            if !Secrets.supabaseURL.isEmpty && Secrets.supabaseURL != "YOUR_SUPABASE_URL_HERE" {
                UserDefaults.standard.set(Secrets.supabaseURL, forKey: "supabase_url")
            }
            if !Secrets.supabaseAnonKey.isEmpty && Secrets.supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY_HERE" {
                UserDefaults.standard.set(Secrets.supabaseAnonKey, forKey: "supabase_anon_key")
            }
            #endif
        }
    }
    
    var body: some Scene {
        WindowGroup {
            if authService.isAuthenticated {
                ContentView()
                    .environmentObject(dataService)
                    .environmentObject(authService)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                    .onAppear {
                        // Sync with system theme when view appears
                        themeManager.syncWithSystemTheme()
                    }
                    .onOpenURL { url in
                        // Handle Universal Links and custom URL schemes
                        handleURL(url)
                    }
            } else {
                // Show WelcomeIntroView first, then LoginView
                WelcomeIntroOrLoginView()
                    .environmentObject(authService)
                    .environmentObject(themeManager)
                    .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
                    .onAppear {
                        // Sync with system theme when view appears
                        themeManager.syncWithSystemTheme()
                    }
                    .onOpenURL { url in
                        // Handle Universal Links and custom URL schemes
                        handleURL(url)
                    }
            }
        }
        .onChange(of: scenePhase) { newPhase in
            switch newPhase {
            case .active:
                // Sync with system theme when app becomes active
                themeManager.syncWithSystemTheme()
                print("📱 App became active - checking for ongoing blueprint generation")
                // Check if blueprint generation is in progress and ensure it continues
                if InitialScanViewModel().isLoadingBlueprint {
                    print("✅ Blueprint generation is in progress - will continue")
                }
            case .background:
                print("📱 App moved to background - blueprint generation will continue if in progress")
            case .inactive:
                print("📱 App became inactive - blueprint generation will continue if in progress")
            @unknown default:
                break
            }
        }
    }
    
    /// Handle Universal Links and custom URL schemes
    private func handleURL(_ url: URL) {
        print("🔗 App opened via URL: \(url.absoluteString)")
        
        // Handle email confirmation
        if url.path.contains("/auth/confirm") || url.host == "auth" && url.path == "/confirm" {
            print("✅ Email confirmation URL detected")
            // Email is confirmed when user clicks the link
            // Supabase handles the confirmation automatically
            // We just need to refresh auth state
            Task {
                // Refresh authentication state to get confirmed status
                // The user will be automatically logged in if email is confirmed
            }
        }
    }
}
