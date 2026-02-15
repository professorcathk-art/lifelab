import Foundation
import Combine
import AuthenticationServices
import SwiftUI

class AuthService: ObservableObject {
    static let shared = AuthService()
    
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var isLoading = false
    
    private let userDefaultsKey = "lifelab_current_user"
    private let supabaseService = SupabaseService.shared
    
    private init() {
        loadUser()
        // Check if we have a valid Supabase session
        checkSupabaseSession()
    }
    
    struct User: Codable {
        let id: String
        let email: String?
        let name: String?
        let authProvider: AuthProvider
        
        enum AuthProvider: String, Codable {
            case email = "email"
            case apple = "apple"
        }
    }
    
    // MARK: - Email Authentication
    
    func signInWithEmail(email: String, password: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Authenticate with Supabase
            let response = try await supabaseService.signIn(email: email, password: password)
            let supabaseUser = response.user
            
            // Create local user object
            let user = User(
                id: supabaseUser.id,
                email: supabaseUser.email,
                name: supabaseUser.name,
                authProvider: .email
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
            }
            
            // IMPORTANT: Load user-specific profile from Supabase
            // Clear any previous user's data from memory first to ensure data isolation
            Task {
                await MainActor.run {
                    DataService.shared.userProfile = nil
                }
                // Load new user's data
                await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
            }
            
            print("✅ Email sign in successful: \(email)")
        } catch {
            print("❌ Email sign in error: \(error.localizedDescription)")
            throw error
        }
    }
    
    func signUpWithEmail(email: String, password: String, name: String) async throws {
        isLoading = true
        defer { isLoading = false }
        
        do {
            // Register with Supabase
            let response = try await supabaseService.signUp(email: email, password: password, name: name)
            let supabaseUser = response.user
            
            // Create local user object
            let user = User(
                id: supabaseUser.id,
                email: supabaseUser.email,
                name: name,
                authProvider: .email
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
            }
            
            // IMPORTANT: Clear any previous user's data and create new profile
            Task {
                await MainActor.run {
                    DataService.shared.userProfile = nil
                }
                // Create user profile in Supabase (in background)
                await DataService.shared.createUserProfileInSupabase(userId: supabaseUser.id)
            }
            
            print("✅ Email sign up successful: \(email)")
        } catch {
            print("❌ Email sign up error: \(error.localizedDescription)")
            throw error
        }
    }
    
    // MARK: - Apple Sign In
    
    func signInWithApple(authorization: ASAuthorization) async throws {
        isLoading = true
        defer { isLoading = false }
        
        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid Apple ID credential"])
        }
        
        // Get identity token from Apple
        guard let identityTokenData = appleIDCredential.identityToken,
              let identityToken = String(data: identityTokenData, encoding: .utf8) else {
            throw NSError(domain: "AuthService", code: -2, userInfo: [NSLocalizedDescriptionKey: "无法获取 Apple 身份令牌。请确保设备已启用双重认证"])
        }
        
        do {
            // For Apple Sign In with Supabase, we need to use the OAuth flow
            // This requires a web-based redirect, but for iOS we'll use a simplified approach
            // Note: Full OAuth flow may require additional setup in Supabase
            
            // Try to sign in with Supabase using the identity token
            let response = try await supabaseService.signInWithOAuth(
                provider: "apple",
                token: identityToken
            )
            let supabaseUser = response.user
            
            // Extract user info from Apple credential
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let name = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            // Create local user object
            let user = User(
                id: supabaseUser.id,
                email: email ?? supabaseUser.email,
                name: name.isEmpty ? nil : name,
                authProvider: .apple
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
            }
            
            // IMPORTANT: Load user-specific profile from Supabase
            // Clear any previous user's data from memory first to ensure data isolation
            Task {
                await MainActor.run {
                    DataService.shared.userProfile = nil
                }
                // Load new user's data
                await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
            }
            
            print("✅ Apple Sign In successful")
        } catch {
            print("❌ Apple Sign In Supabase error: \(error.localizedDescription)")
            
            // Re-throw authorization errors (don't fallback)
            let nsError = error as NSError
            if nsError.domain == "ASAuthenticationServices" {
                throw error
            }
            
            // Fallback: Create local session even if Supabase fails
            // This ensures the app works even if OAuth isn't fully configured
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let name = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            let user = User(
                id: userIdentifier,
                email: email,
                name: name.isEmpty ? nil : name,
                authProvider: .apple
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
            }
            
            print("⚠️ Using local session (Supabase OAuth may need configuration)")
        }
    }
    
    // MARK: - Password Reset
    
    func resetPassword(email: String) async throws {
        try await supabaseService.resetPassword(email: email)
    }
    
    // MARK: - Sign Out
    
    func signOut() {
        // IMPORTANT: Save current user's data to local storage BEFORE clearing
        // This ensures data persists for this specific user
        if let profile = DataService.shared.userProfile, let userId = currentUser?.id {
            // Save to user-specific UserDefaults before clearing
            DataService.shared.saveUserProfile(profile)
            print("✅ Saved user profile for user \(userId) to local storage before logout")
        }
        
        Task {
            do {
                // Sign out from Supabase
                try await supabaseService.signOut()
            } catch {
                print("⚠️ Supabase sign out error: \(error.localizedDescription)")
            }
        }
        
        // Clear authentication state
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        // IMPORTANT: Clear current user's profile from memory
        // Data is preserved in UserDefaults with user-specific key, but cleared from memory
        // This ensures next user doesn't see previous user's data
        DataService.shared.userProfile = nil
        DataService.shared.lastSyncTime = nil
        
        print("✅ Signed out successfully (user data preserved in user-specific local storage)")
    }
    
    // MARK: - Session Management
    
    private func checkSupabaseSession() {
        // Check if we have a valid Supabase session
        if let supabaseUser = supabaseService.getCurrentUser() {
            // Restore session from Supabase
            let user = User(
                id: supabaseUser.id,
                email: supabaseUser.email,
                name: supabaseUser.name,
                authProvider: .email // Default, could be improved
            )
            
            // Update on main thread (required for @Published properties)
            Task { @MainActor in
                self.currentUser = user
                self.isAuthenticated = true
            }
            
            // Load profile in background
            Task {
                await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUser() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let user = try? JSONDecoder().decode(User.self, from: data) {
            self.currentUser = user
            self.isAuthenticated = true
        }
    }
}
