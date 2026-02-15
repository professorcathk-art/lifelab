import Foundation

/// Secure configuration for Resend API
/// API key is loaded from Secrets.swift (gitignored) or UserDefaults
/// This ensures the key is not exposed in source code
struct ResendConfig {
    static var apiKey: String {
        // First try to get from Secrets.swift (for development)
        #if DEBUG
        if !Secrets.resendAPIKey.isEmpty && Secrets.resendAPIKey != "YOUR_RESEND_API_KEY_HERE" {
            return Secrets.resendAPIKey
        }
        #endif
        
        // Fallback to UserDefaults (set during app initialization for production)
        return UserDefaults.standard.string(forKey: "resend_api_key") ?? ""
    }
    
    static let apiURL = "https://api.resend.com/emails"
    static let recipientEmail = "professor.cat.hk@gmail.com"
    static let senderEmail = "onboarding@resend.dev" // Default Resend sender
}
