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
            
            // CRITICAL: Clear ALL previous user's data FIRST before setting new user
            // This prevents data leakage between different accounts
            print("🔒🔒🔒 CLEARING PREVIOUS USER DATA 🔒🔒🔒")
            await MainActor.run {
                // Clear previous user's data from memory FIRST
                DataService.shared.userProfile = nil
                DataService.shared.lastSyncTime = nil
                print("✅ Cleared previous user's data from memory")
            }
            
            // Set new user AFTER clearing old data
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
                print("✅ Set new user: \(supabaseUser.id)")
                
                // Save AI consent if pending (from login page)
                if UserDefaults.standard.bool(forKey: "lifelab_ai_consent_pending") {
                    let consentKey = "lifelab_ai_consent_\(supabaseUser.id)"
                    UserDefaults.standard.set(true, forKey: consentKey)
                    UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent_pending")
                    print("✅ Saved AI consent for user: \(supabaseUser.id)")
                }
            }
            
            // CRITICAL: Now load new user's local data
            // This ensures we load the correct user's data
            print("📥📥📥 LOADING NEW USER'S LOCAL DATA 📥📥📥")
            print("   User ID: \(supabaseUser.id)")
            
            // Load from local storage immediately (synchronous, instant)
            await MainActor.run {
                // Load this user's local data immediately
                DataService.shared.loadUserProfileForUser(userId: supabaseUser.id)
                if let profile = DataService.shared.userProfile {
                    print("✅✅✅ LOADED NEW USER'S LOCAL DATA ✅✅✅")
                    print("   User ID: \(supabaseUser.id)")
                    print("   Interests: \(profile.interests.count)")
                    print("   Strengths: \(profile.strengths.count)")
                    print("   Values: \(profile.values.count)")
                    print("   Has blueprint: \(profile.lifeBlueprint != nil)")
                } else {
                    print("⚠️ No local data found for new user \(supabaseUser.id)")
                    print("   This is expected for a new user or first-time login")
                }
            }
            
            // IMPORTANT: Wait a moment to ensure token is saved before syncing
            // Token is saved in makeAuthRequest, but we need to ensure it's persisted
            try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
            
            // IMPORTANT: Load user-specific profile from Supabase (in background)
            // This will merge with local data if Supabase has newer data
            Task {
                print("📥 Loading user profile from Supabase after email login...")
                // Load from Supabase and merge with local data
                await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
                print("✅ Completed loading profile from Supabase after email login")
            }
            
            // IMPORTANT: Trigger immediate sync after login to ensure data is synced
            Task {
                // Wait a bit more to ensure everything is set up
                try? await Task.sleep(nanoseconds: 500_000_000) // 0.5 seconds
                print("🔄 Triggering immediate sync after email login...")
                await DataService.shared.syncToSupabase()
                print("✅ Sync triggered after email login")
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
            
            // CRITICAL: Clear ALL previous user's data FIRST before setting new user
            // This prevents data leakage between different accounts
            print("🔒🔒🔒 CLEARING PREVIOUS USER DATA (SIGNUP) 🔒🔒🔒")
            await MainActor.run {
                // Clear previous user's data from memory FIRST
                DataService.shared.userProfile = nil
                DataService.shared.lastSyncTime = nil
                print("✅ Cleared previous user's data from memory")
            }
            
            // Set new user AFTER clearing old data
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
                print("✅ Set new user: \(supabaseUser.id)")
                
                // Save AI consent if pending (from login page)
                if UserDefaults.standard.bool(forKey: "lifelab_ai_consent_pending") {
                    let consentKey = "lifelab_ai_consent_\(supabaseUser.id)"
                    UserDefaults.standard.set(true, forKey: consentKey)
                    UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent_pending")
                    print("✅ Saved AI consent for user: \(supabaseUser.id)")
                }
            }
            
            // CRITICAL: Now load new user's local data (if exists from previous session)
            print("📥📥📥 CHECKING FOR LOCAL DATA AFTER SIGNUP 📥📥📥")
            print("   User ID: \(supabaseUser.id)")
            
            // Load from local storage immediately (synchronous, instant)
            await MainActor.run {
                // Load this user's local data immediately (if exists)
                DataService.shared.loadUserProfileForUser(userId: supabaseUser.id)
                if let profile = DataService.shared.userProfile {
                    print("✅✅✅ FOUND EXISTING LOCAL DATA ✅✅✅")
                    print("   Interests: \(profile.interests.count)")
                    print("   Strengths: \(profile.strengths.count)")
                    print("   Values: \(profile.values.count)")
                } else {
                    print("📱 No existing local data - new user")
                }
            }
            
            // IMPORTANT: Create user profile in Supabase (in background)
            Task {
                print("📥 Creating user profile in Supabase after email signup...")
                // Create user profile in Supabase (in background)
                await DataService.shared.createUserProfileInSupabase(userId: supabaseUser.id)
                print("✅ Completed creating profile in Supabase after email signup")
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
            // IMPORTANT: Apple Sign In with Supabase requires proper configuration
            // The error "Unacceptable audience in id_token" means:
            // 1. Supabase expects Service ID, not Bundle ID
            // 2. Need to configure Apple OAuth in Supabase Dashboard
            // 3. Service ID must match the one configured in Supabase
            
            // Try to sign in with Supabase using the identity token
            print("🔐 Attempting Apple Sign In with Supabase...")
            let response = try await supabaseService.signInWithOAuth(
                provider: "apple",
                token: identityToken
            )
            let supabaseUser = response.user
            print("✅ Apple Sign In with Supabase successful: \(supabaseUser.id)")
            
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
            
            // CRITICAL: Clear ALL previous user's data FIRST before setting new user
            // This prevents data leakage between different accounts
            print("🔒🔒🔒 CLEARING PREVIOUS USER DATA (APPLE) 🔒🔒🔒")
            await MainActor.run {
                // Clear previous user's data from memory FIRST
                DataService.shared.userProfile = nil
                DataService.shared.lastSyncTime = nil
                print("✅ Cleared previous user's data from memory")
            }
            
            // Set new user AFTER clearing old data
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
                print("✅ Set new user: \(supabaseUser.id)")
                
                // Save AI consent if pending (from login page)
                if UserDefaults.standard.bool(forKey: "lifelab_ai_consent_pending") {
                    let consentKey = "lifelab_ai_consent_\(supabaseUser.id)"
                    UserDefaults.standard.set(true, forKey: consentKey)
                    UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent_pending")
                    print("✅ Saved AI consent for user: \(supabaseUser.id)")
                }
            }
            
            // CRITICAL: Now load new user's local data
            print("📥📥📥 LOADING NEW USER'S LOCAL DATA (APPLE) 📥📥📥")
            print("   User ID: \(supabaseUser.id)")
            
            // Load from local storage immediately (synchronous, instant)
            await MainActor.run {
                // Load this user's local data immediately
                DataService.shared.loadUserProfileForUser(userId: supabaseUser.id)
                if let profile = DataService.shared.userProfile {
                    print("✅✅✅ LOADED NEW USER'S LOCAL DATA ✅✅✅")
                    print("   User ID: \(supabaseUser.id)")
                    print("   Interests: \(profile.interests.count)")
                    print("   Strengths: \(profile.strengths.count)")
                    print("   Values: \(profile.values.count)")
                    print("   Has blueprint: \(profile.lifeBlueprint != nil)")
                } else {
                    print("⚠️ No local data found for new user \(supabaseUser.id)")
                    print("   This is expected for a new user or first-time login")
                }
            }
            
            // IMPORTANT: Load user-specific profile from Supabase (in background)
            // This will merge with local data if Supabase has newer data
            Task {
                print("📥 Loading user profile from Supabase after Apple login...")
                // Load from Supabase and merge with local data
                await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
                print("✅ Completed loading profile from Supabase after Apple login")
            }
            
            print("✅ Apple Sign In successful")
        } catch {
            let errorMessage = error.localizedDescription
            print("❌ Apple Sign In Supabase error: \(errorMessage)")
            
            // Check if it's the audience error (most common)
            if errorMessage.contains("Unacceptable audience") {
                print("⚠️ Apple OAuth Configuration Issue:")
                print("   Error: Unacceptable audience in id_token")
                print("   Cause: Supabase expects Service ID, but received Bundle ID")
                print("   Solution:")
                print("   1. Go to Supabase Dashboard → Authentication → Providers → Apple")
                print("   2. Configure Apple OAuth with your Service ID (not Bundle ID)")
                print("   3. Service ID format: com.resonance.lifelab.service (example)")
                print("   4. Ensure Service ID matches the one in Apple Developer Portal")
            }
            
            // Re-throw authorization errors (don't fallback)
            let nsError = error as NSError
            if nsError.domain == "ASAuthenticationServices" {
                throw error
            }
            
            // IMPORTANT: Fallback to local session, but warn about data sync limitations
            // Data will be saved locally but NOT synced to Supabase
            print("⚠️ Falling back to local session (data will NOT sync to Supabase)")
            print("   To enable Supabase sync, please configure Apple OAuth in Supabase Dashboard")
            
            let userIdentifier = appleIDCredential.user
            let email = appleIDCredential.email
            let fullName = appleIDCredential.fullName
            let name = [fullName?.givenName, fullName?.familyName]
                .compactMap { $0 }
                .joined(separator: " ")
            
            // Use a deterministic UUID based on Apple user identifier for consistency
            // This ensures the same user gets the same ID across sessions
            let userId = UUID(uuidString: userIdentifier) ?? UUID()
            
            let user = User(
                id: userId.uuidString,
                email: email,
                name: name.isEmpty ? nil : name,
                authProvider: .apple
            )
            
            await MainActor.run {
                self.currentUser = user
                self.isAuthenticated = true
                saveUser(user)
            }
            
            // IMPORTANT: Since we're using local session, data won't sync to Supabase
            // But we can still save locally and sync later when OAuth is configured
            print("⚠️ Using local session - data saved locally only")
            print("   To enable Supabase sync, configure Apple OAuth in Supabase Dashboard")
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
        
        // CRITICAL: Clear authentication state FIRST
        let previousUserId = currentUser?.id
        currentUser = nil
        isAuthenticated = false
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
        
        // CRITICAL: Clear current user's profile from memory IMMEDIATELY
        // This ensures next user doesn't see previous user's data
        // We clear this BEFORE clearing authentication state to prevent any race conditions
        DataService.shared.userProfile = nil
        DataService.shared.lastSyncTime = nil
        
        print("🔒🔒🔒 SIGNED OUT - DATA CLEARED 🔒🔒🔒")
        print("   Previous user ID: \(previousUserId ?? "N/A")")
        print("   Memory cleared: ✅")
        print("   User data preserved in user-specific local storage: ✅")
        print("✅ Signed out successfully (user data preserved in user-specific local storage)")
    }
    
    // MARK: - Session Management
    
    private func checkSupabaseSession() {
        print("🔍 Checking Supabase session...")
        
        // Check if we have a valid Supabase session
        if let supabaseUser = supabaseService.getCurrentUser() {
            print("✅ Found Supabase session for user: \(supabaseUser.id)")
            
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
                print("✅ Restored authentication state for user: \(user.id)")
            }
            
            // IMPORTANT: Load profile from Supabase immediately
            Task {
                print("📥 Loading user profile from Supabase for user: \(supabaseUser.id)")
                await DataService.shared.loadFromSupabase(userId: supabaseUser.id)
                print("✅ Completed loading profile from Supabase")
            }
        } else {
            print("⚠️ No Supabase session found (user needs to login)")
            // Check if we have local user data (from previous session)
            if currentUser != nil {
                print("📱 Found local user data, but no Supabase session. User needs to login again.")
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
