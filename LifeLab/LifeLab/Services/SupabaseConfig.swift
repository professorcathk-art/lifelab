import Foundation

/// Secure configuration for Supabase
/// Keys are loaded from Secrets.swift (gitignored) or UserDefaults
/// This ensures keys are not exposed in source code
struct SupabaseConfig {
    static var projectURL: String {
        // First try to get from Secrets.swift (for development)
        #if DEBUG
        if !Secrets.supabaseURL.isEmpty && Secrets.supabaseURL != "YOUR_SUPABASE_URL_HERE" {
            return Secrets.supabaseURL
        }
        #endif
        
        // Fallback to UserDefaults (set during app initialization for production)
        return UserDefaults.standard.string(forKey: "supabase_url") ?? ""
    }
    
    static var anonKey: String {
        // First try to get from Secrets.swift (for development)
        #if DEBUG
        if !Secrets.supabaseAnonKey.isEmpty && Secrets.supabaseAnonKey != "YOUR_SUPABASE_ANON_KEY_HERE" {
            return Secrets.supabaseAnonKey
        }
        #endif
        
        // Fallback to UserDefaults (set during app initialization for production)
        return UserDefaults.standard.string(forKey: "supabase_anon_key") ?? ""
    }
    
    static var serviceRoleKey: String {
        // Service role key should NEVER be exposed in client code
        // This is only for server-side operations
        // For client-side, we only use anon key
        #if DEBUG
        if !Secrets.supabaseServiceRoleKey.isEmpty && Secrets.supabaseServiceRoleKey != "YOUR_SUPABASE_SERVICE_ROLE_KEY_HERE" {
            return Secrets.supabaseServiceRoleKey
        }
        #endif
        
        return UserDefaults.standard.string(forKey: "supabase_service_role_key") ?? ""
    }
    
    static let projectId = "inlzhosqbccyynofbmjt"
}
