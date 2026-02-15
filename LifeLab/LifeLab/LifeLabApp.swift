import SwiftUI
import Combine

@main
struct LifeLabApp: App {
    @StateObject private var dataService = DataService.shared
    @StateObject private var authService = AuthService.shared
    
    init() {
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
            } else {
                LoginView()
                    .environmentObject(authService)
            }
        }
    }
}
