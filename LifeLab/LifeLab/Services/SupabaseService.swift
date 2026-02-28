import Foundation
import Combine

/// Supabase Service - Handles all Supabase operations
/// Uses SupabaseConfig for secure key management
/// Uses URLSession for API calls (no external SDK required)
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    // Shared URLSession with optimized configuration
    private let urlSession: URLSession
    
    private init() {
        // Configure URLSession with longer timeout and retry support
        // IMPORTANT: Mobile networks can be slower, so we use longer timeouts
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 90.0 // 90 seconds (increased for unstable networks)
        config.timeoutIntervalForResource = 180.0 // 180 seconds (increased for unstable networks)
        config.waitsForConnectivity = true // Wait for network to become available
        config.requestCachePolicy = .reloadIgnoringLocalCacheData
        config.httpMaximumConnectionsPerHost = 6
        config.httpShouldUsePipelining = false
        config.urlCache = nil // Disable cache to avoid stale data
        config.allowsCellularAccess = true // Allow cellular network access
        config.networkServiceType = .default // Use default network service type
        config.httpShouldSetCookies = false // Don't use cookies
        config.httpCookieAcceptPolicy = .never // Don't accept cookies
        
        self.urlSession = URLSession(configuration: config)
        initializeSupabase()
    }
    
    private func initializeSupabase() {
        let url = SupabaseConfig.projectURL
        let anonKey = SupabaseConfig.anonKey
        
        guard !url.isEmpty, !anonKey.isEmpty else {
            print("⚠️ Supabase configuration missing. Please check Secrets.swift or UserDefaults.")
            return
        }
        
        guard URL(string: url) != nil else {
            print("❌ Invalid Supabase URL: \(url)")
            return
        }
        
        print("✅ Supabase initialized with URL: \(url)")
        print("✅ Using anon key (first 20 chars): \(anonKey.prefix(20))...")
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, name: String?) async throws -> AuthResponse {
        // IMPORTANT: Set redirect_to URL for email confirmation
        // Use Universal Link that points to your Vercel site, which will redirect to app
        // Format: https://yourdomain.com/auth/confirm
        // The Vercel page will show confirmation message and redirect to app via Universal Link
        let redirectURL = "https://lifelab-tau.vercel.app/auth/confirm"
        
        return try await makeAuthRequest(
            endpoint: "/auth/v1/signup",
            body: [
                "email": email,
                "password": password,
                "data": name != nil ? ["name": name!] : [:],
                "redirect_to": redirectURL  // IMPORTANT: Set redirect URL for email confirmation
            ]
        )
    }
    
    func signIn(email: String, password: String) async throws -> AuthResponse {
        return try await makeAuthRequest(
            endpoint: "/auth/v1/token?grant_type=password",
            body: [
                "email": email,
                "password": password
            ]
        )
    }
    
    func resetPassword(email: String) async throws {
        let urlString = "\(SupabaseConfig.projectURL)/auth/v1/recover"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "email": email
        ]
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "SupabaseService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Password reset error: \(errorMessage)"])
        }
    }
    
    func signInWithOAuth(provider: String, token: String) async throws -> AuthResponse {
        // For Apple Sign In, we need to exchange the identity token with Supabase
        // IMPORTANT: Supabase requires the redirect_uri to match the callback URL configured in Supabase Dashboard
        let callbackURL = "\(SupabaseConfig.projectURL)/auth/v1/callback"
        let urlString = "\(SupabaseConfig.projectURL)/auth/v1/token?grant_type=id_token&provider=\(provider)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        let body: [String: Any] = [
            "provider": provider,
            "id_token": token,
            "redirect_to": callbackURL  // IMPORTANT: Set redirect_uri to Supabase callback URL
        ]
        
        print("🔐 Apple Sign In OAuth request:")
        print("   Provider: \(provider)")
        print("   Callback URL: \(callbackURL)")
        print("   Token length: \(token.count) characters")
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "SupabaseService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "OAuth error: \(errorMessage)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "SupabaseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        // Save tokens
        if let accessToken = json["access_token"] as? String {
            UserDefaults.standard.set(accessToken, forKey: "supabase_access_token")
        }
        if let refreshToken = json["refresh_token"] as? String {
            UserDefaults.standard.set(refreshToken, forKey: "supabase_refresh_token")
        }
        if let user = json["user"] as? [String: Any] {
            if let userData = try? JSONSerialization.data(withJSONObject: user) {
                UserDefaults.standard.set(userData, forKey: "supabase_user_data")
            }
        }
        
        return AuthResponse(
            accessToken: json["access_token"] as? String ?? "",
            refreshToken: json["refresh_token"] as? String ?? "",
            user: try decodeAuthUser(from: json["user"] as? [String: Any] ?? [:])
        )
    }
    
    func signOut() async throws {
        // Clear local session
        UserDefaults.standard.removeObject(forKey: "supabase_access_token")
        UserDefaults.standard.removeObject(forKey: "supabase_refresh_token")
        UserDefaults.standard.removeObject(forKey: "supabase_user_data")
    }
    
    func getCurrentUser() -> AuthUser? {
        let hasToken = UserDefaults.standard.string(forKey: "supabase_access_token") != nil
        let hasUserData = UserDefaults.standard.data(forKey: "supabase_user_data") != nil
        
        print("🔍 getCurrentUser check:")
        print("   Has access token: \(hasToken)")
        print("   Has user data: \(hasUserData)")
        
        guard hasToken,
              let data = UserDefaults.standard.data(forKey: "supabase_user_data"),
              let user = try? JSONDecoder().decode(AuthUser.self, from: data) else {
            print("⚠️ No valid Supabase session found")
            return nil
        }
        
        print("✅ Found Supabase user: \(user.id), email: \(user.email ?? "none")")
        return user
    }
    
    // MARK: - Database Operations
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        print("🔍 fetchUserProfile called for user: \(userId)")
        
        // IMPORTANT: Use user_id instead of id for querying
        // Supabase user_profiles table uses id as primary key which references auth.users(id)
        let response = try await makeRequest(
            endpoint: "/rest/v1/user_profiles",
            method: "GET",
            queryParams: ["id": "eq.\(userId)"]
        )
        
        guard let data = response["data"] as? [[String: Any]],
              let firstProfile = data.first else {
            print("📭 No profile found in Supabase for user \(userId)")
            print("   This is normal for new users. Profile will be created on first save.")
            return nil
        }
        
        print("✅ Found profile in Supabase for user \(userId)")
        let profile = try decodeUserProfile(from: firstProfile)
        print("   Profile decoded: \(profile.interests.count) interests, \(profile.strengths.count) strengths")
        return profile
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        // IMPORTANT: Ensure profile ID matches authenticated user ID
        // Get current authenticated user ID from AuthService
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            print("❌ Cannot save profile: Not authenticated")
            throw NSError(domain: "SupabaseService", code: -10, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        print("💾💾💾 saveUserProfile CALLED 💾💾💾")
        print("   User ID: \(currentUserId)")
        print("   Profile has:")
        print("     - \(profile.interests.count) interests")
        print("     - \(profile.strengths.count) strengths")
        print("     - \(profile.values.count) values")
        print("     - basicInfo: \(profile.basicInfo != nil ? "YES" : "NO")")
        print("     - lifeBlueprint: \(profile.lifeBlueprint != nil ? "YES" : "NO")")
        print("     - actionPlan: \(profile.actionPlan != nil ? "YES" : "NO")")
        
        // Create profile dict with correct user ID
        var profileDict = try encodeUserProfile(profile)
        
        // Ensure id field matches authenticated user ID
        profileDict["id"] = currentUserId
        print("   Profile dict created with \(profileDict.keys.count) keys")
        
        // Check if profile exists
        print("   Checking if profile exists in Supabase...")
        let existing = try await fetchUserProfile(userId: currentUserId)
        
        if existing != nil {
            // Update existing
            print("📝📝📝 UPDATING EXISTING PROFILE 📝📝📝")
            print("   User ID: \(currentUserId)")
            do {
                let response = try await makeRequest(
                    endpoint: "/rest/v1/user_profiles",
                    method: "PATCH",
                    body: profileDict,
                    queryParams: ["id": "eq.\(currentUserId)"]
                )
                print("✅✅✅ PROFILE UPDATED SUCCESSFULLY ✅✅✅")
                print("   Response keys: \(response.keys.joined(separator: ", "))")
            } catch {
                print("❌❌❌ FAILED TO UPDATE PROFILE ❌❌❌")
                print("   Error: \(error.localizedDescription)")
                print("   Error details: \(error)")
                throw error
            }
        } else {
            // Insert new
            print("➕➕➕ CREATING NEW PROFILE ➕➕➕")
            print("   User ID: \(currentUserId)")
            do {
                let response = try await makeRequest(
                    endpoint: "/rest/v1/user_profiles",
                    method: "POST",
                    body: profileDict
                )
                print("✅✅✅ PROFILE CREATED SUCCESSFULLY ✅✅✅")
                print("   Response keys: \(response.keys.joined(separator: ", "))")
            } catch {
                print("❌❌❌ FAILED TO CREATE PROFILE ❌❌❌")
                print("   Error: \(error.localizedDescription)")
                print("   Error details: \(error)")
                throw error
            }
        }
        
        // IMPORTANT: Verify the save was successful by fetching the profile
        print("🔍 Verifying profile was saved...")
        do {
            let verified = try await fetchUserProfile(userId: currentUserId)
            if verified != nil {
                print("✅ Verification successful: Profile exists in Supabase")
            } else {
                print("⚠️ Verification warning: Profile not found immediately after save (might be eventual consistency)")
            }
        } catch {
            print("⚠️ Verification error: \(error.localizedDescription)")
            // Don't throw - save might have succeeded but verification failed
        }
    }
    
    func fetchUserSubscription(userId: String) async throws -> UserSubscription? {
        let response = try await makeRequest(
            endpoint: "/rest/v1/user_subscriptions",
            method: "GET",
            queryParams: [
                "user_id": "eq.\(userId)",
                "status": "eq.active",
                "order": "created_at.desc"
            ]
        )
        
        guard let data = response["data"] as? [[String: Any]],
              let first = data.first else {
            return nil
        }
        
        return try decodeUserSubscription(from: first)
    }
    
    func saveUserSubscription(_ subscription: UserSubscription) async throws {
        let subscriptionDict = try encodeUserSubscription(subscription)
        
        _ = try await makeRequest(
            endpoint: "/rest/v1/user_subscriptions",
            method: "POST",
            body: subscriptionDict
        )
    }
    
    // MARK: - Delete User Data
    
    func deleteUserData(userId: String) async throws {
        print("🗑️ Deleting user data for user: \(userId)")
        
        // Delete user profile
        do {
            _ = try await makeRequest(
                endpoint: "/rest/v1/user_profiles",
                method: "DELETE",
                queryParams: ["id": "eq.\(userId)"]
            )
            print("✅ User profile deleted from Supabase")
        } catch {
            print("⚠️ Failed to delete user profile: \(error.localizedDescription)")
            // Continue with other deletions even if profile deletion fails
        }
        
        // Delete user subscriptions
        do {
            _ = try await makeRequest(
                endpoint: "/rest/v1/user_subscriptions",
                method: "DELETE",
                queryParams: ["user_id": "eq.\(userId)"]
            )
            print("✅ User subscriptions deleted from Supabase")
        } catch {
            print("⚠️ Failed to delete user subscriptions: \(error.localizedDescription)")
        }
        
        // Note: Auth user deletion should be done through Supabase Dashboard or Admin API
        // Regular users cannot delete their own auth account via REST API
        print("✅ User data deletion completed")
    }
    
    // MARK: - Private Helpers
    
    private func makeAuthRequest(endpoint: String, body: [String: Any]) async throws -> AuthResponse {
        let urlString = "\(SupabaseConfig.projectURL)\(endpoint)"
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(SupabaseConfig.anonKey)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        
        // IMPORTANT: Increase timeout for mobile networks which may be slower
        request.timeoutInterval = 60.0 // 60 seconds (increased for mobile networks)
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        // IMPORTANT: Use URLSession with longer timeout for mobile networks
        let sessionConfig = URLSessionConfiguration.default
        sessionConfig.timeoutIntervalForRequest = 60.0
        sessionConfig.timeoutIntervalForResource = 120.0
        sessionConfig.waitsForConnectivity = true
        sessionConfig.allowsCellularAccess = true
        let session = URLSession(configuration: sessionConfig)
        
        print("🌐🌐🌐 MAKING AUTH REQUEST 🌐🌐🌐")
        print("   URL: \(urlString)")
        print("   Timeout: 60 seconds")
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            
            // Parse error message to check for specific error types
            var parsedError: NSError
            if let errorData = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
               let errorMsg = errorData["error_description"] as? String ?? errorData["error"] as? String {
                let errorMsgLower = errorMsg.lowercased()
                
                // Check for signup-specific errors (user already exists)
                if httpResponse.statusCode == 422 || 
                   errorMsgLower.contains("user already registered") ||
                   errorMsgLower.contains("email already exists") ||
                   errorMsgLower.contains("already registered") {
                    // User already exists - mark for sign in suggestion
                    parsedError = NSError(
                        domain: "SupabaseService",
                        code: httpResponse.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMsg,
                            "userAlreadyExists": true as Any
                        ]
                    )
                }
                // Check for signin-specific errors (wrong password or user not found)
                else if errorMsgLower.contains("invalid login credentials") || 
                        errorMsgLower.contains("email not confirmed") ||
                        errorMsgLower.contains("user not found") ||
                        httpResponse.statusCode == 401 {
                    // User doesn't exist or credentials are wrong - should redirect to sign up
                    parsedError = NSError(
                        domain: "SupabaseService",
                        code: httpResponse.statusCode,
                        userInfo: [
                            NSLocalizedDescriptionKey: errorMsg,
                            "shouldShowSignUp": true as Any
                        ]
                    )
                } else {
                    parsedError = NSError(
                        domain: "SupabaseService",
                        code: httpResponse.statusCode,
                        userInfo: [NSLocalizedDescriptionKey: errorMsg]
                    )
                }
            } else {
                parsedError = NSError(
                    domain: "SupabaseService",
                    code: httpResponse.statusCode,
                    userInfo: [NSLocalizedDescriptionKey: "Auth error: \(errorMessage)"]
                )
            }
            
            print("❌❌❌ AUTH ERROR ❌❌❌")
            print("   Status code: \(httpResponse.statusCode)")
            print("   Error message: \(parsedError.localizedDescription)")
            if parsedError.userInfo["shouldShowSignUp"] != nil {
                print("   ⚠️ User should be redirected to sign up page")
            }
            
            throw parsedError
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw NSError(domain: "SupabaseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        // Check if email confirmation is required
        // If Supabase has email confirmation enabled, signup response may not include access_token
        if let message = json["message"] as? String, message.lowercased().contains("confirmation") {
            // Email confirmation required - user needs to confirm email before login
            print("📧 Email confirmation required")
            print("   Message: \(message)")
            
            // Try to extract user info if available
            if let user = json["user"] as? [String: Any] {
                let userInfo = try decodeAuthUser(from: user)
                throw NSError(domain: "SupabaseService", code: -4, userInfo: [
                    NSLocalizedDescriptionKey: "Please check your email to confirm your account",
                    "requiresEmailConfirmation": true,
                    "user": userInfo
                ])
            }
            
            throw NSError(domain: "SupabaseService", code: -4, userInfo: [
                NSLocalizedDescriptionKey: "Please check your email to confirm your account",
                "requiresEmailConfirmation": true
            ])
        }
        
        // Check if access_token exists (required for login)
        guard let accessToken = json["access_token"] as? String else {
            print("❌ ERROR: No access_token in response")
            print("   Response keys: \(json.keys.joined(separator: ", "))")
            print("   Response content: \(json)")
            
            // If user exists but no token, might be email confirmation issue
            if let user = json["user"] as? [String: Any] {
                let userInfo = try decodeAuthUser(from: user)
                throw NSError(domain: "SupabaseService", code: -4, userInfo: [
                    NSLocalizedDescriptionKey: "Please check your email to confirm your account",
                    "requiresEmailConfirmation": true,
                    "user": userInfo
                ])
            }
            
            throw NSError(domain: "SupabaseService", code: -3, userInfo: [
                NSLocalizedDescriptionKey: "No access token in response. Please check Supabase settings - email confirmation might be enabled."
            ])
        }
        
        // Save tokens
        print("🔐 Saving authentication tokens...")
        UserDefaults.standard.set(accessToken, forKey: "supabase_access_token")
        print("✅ Saved access token to UserDefaults (first 20 chars): \(accessToken.prefix(20))...")
        
        if let refreshToken = json["refresh_token"] as? String {
            UserDefaults.standard.set(refreshToken, forKey: "supabase_refresh_token")
            print("✅ Saved refresh token to UserDefaults")
        } else {
            print("⚠️ Warning: No refresh_token in response")
        }
        
        guard let user = json["user"] as? [String: Any] else {
            print("❌ ERROR: No user data in response")
            print("   Response keys: \(json.keys.joined(separator: ", "))")
            throw NSError(domain: "SupabaseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "No user data in response"])
        }
        
        if let userData = try? JSONSerialization.data(withJSONObject: user) {
            UserDefaults.standard.set(userData, forKey: "supabase_user_data")
            print("✅ Saved user data to UserDefaults")
        }
        
        // Verify token was saved
        let savedToken = UserDefaults.standard.string(forKey: "supabase_access_token")
        if savedToken != nil {
            print("✅ Verified: Token exists in UserDefaults")
        } else {
            print("❌ Error: Token NOT saved to UserDefaults!")
        }
        
        // Decode user with better error handling
        let userInfo = try decodeAuthUser(from: user)
        if userInfo.id.isEmpty {
            print("❌ ERROR: User ID is empty!")
            print("   User dict keys: \(user.keys.joined(separator: ", "))")
            print("   User dict content: \(user)")
            throw NSError(domain: "SupabaseService", code: -5, userInfo: [NSLocalizedDescriptionKey: "User ID is empty in response"])
        }
        
        print("✅ Successfully decoded user: \(userInfo.id)")
        
        return AuthResponse(
            accessToken: accessToken,
            refreshToken: json["refresh_token"] as? String ?? "",
            user: userInfo
        )
    }
    
    private func makeRequest(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        queryParams: [String: String]? = nil,
        retryCount: Int = 3
    ) async throws -> [String: Any] {
        var urlString = "\(SupabaseConfig.projectURL)\(endpoint)"
        
        // Add query parameters
        if let params = queryParams, !params.isEmpty {
            let queryString = params.map { "\($0.key)=\($0.value)" }.joined(separator: "&")
            urlString += "?\(queryString)"
        }
        
        guard let url = URL(string: urlString) else {
            throw NSError(domain: "SupabaseService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // IMPORTANT: Increase timeout for mobile networks which may be slower
        request.timeoutInterval = 60.0 // 60 seconds (increased from default 30s)
        
        // Use access token if available, otherwise use anon key
        let token = UserDefaults.standard.string(forKey: "supabase_access_token") ?? SupabaseConfig.anonKey
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("prefer", forHTTPHeaderField: "return=representation")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
            // Log request body for debugging
            if let jsonString = String(data: request.httpBody!, encoding: .utf8) {
                print("📤 Request body: \(jsonString.prefix(500))...") // First 500 chars
            }
        }
        
        // Log request details
        print("🌐🌐🌐 MAKING REQUEST TO SUPABASE 🌐🌐🌐")
        print("   Method: \(method)")
        print("   URL: \(urlString)")
        print("   Has access token: \(UserDefaults.standard.string(forKey: "supabase_access_token") != nil)")
        print("   Using token: \(token.prefix(20))...")
        print("   Headers: Authorization=Bearer [token], apikey=[anonKey]")
        
        // Retry logic for network errors
        var lastError: Error?
        for attempt in 1...retryCount {
            do {
                print("🔄 Attempt \(attempt)/\(retryCount) for \(method) \(endpoint)")
                let (data, response) = try await urlSession.data(for: request)
                
                guard let httpResponse = response as? HTTPURLResponse else {
                    throw NSError(domain: "SupabaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
                }
                
                // Log response details
                print("📥📥📥 SUPABASE RESPONSE RECEIVED 📥📥📥")
                print("   Status: \(httpResponse.statusCode)")
                if let responseString = String(data: data, encoding: .utf8) {
                    print("   Response body (first 500 chars): \(responseString.prefix(500))...")
                    print("   Response body length: \(data.count) bytes")
                }
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                    print("❌❌❌ API ERROR ❌❌❌")
                    print("   Status code: \(httpResponse.statusCode)")
                    print("   Error message: \(errorMessage)")
                    throw NSError(domain: "SupabaseService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error (\(httpResponse.statusCode)): \(errorMessage)"])
                }
                
                guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
                    // For GET requests, response might be an array
                    if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                        print("✅ Response is array with \(array.count) items")
                        return ["data": array]
                    }
                    print("❌ Failed to parse response as JSON")
                    throw NSError(domain: "SupabaseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
                }
                
                print("✅✅✅ REQUEST SUCCESSFUL ✅✅✅")
                print("   Response parsed successfully")
                return json
            } catch let error as NSError {
                lastError = error
                
                // Check if it's a network error that can be retried
                let isNetworkError = error.domain == NSURLErrorDomain && (
                    error.code == NSURLErrorTimedOut ||
                    error.code == NSURLErrorNetworkConnectionLost ||
                    error.code == NSURLErrorNotConnectedToInternet ||
                    error.code == NSURLErrorCannotConnectToHost
                )
                
                if isNetworkError && attempt < retryCount {
                    let delay = Double(attempt) * 2.0 // Exponential backoff: 2s, 4s, 6s
                    print("⚠️⚠️⚠️ NETWORK ERROR (RETRYABLE) ⚠️⚠️⚠️")
                    print("   Attempt: \(attempt)/\(retryCount)")
                    print("   Error: \(error.localizedDescription)")
                    print("   Error code: \(error.code)")
                    print("   Error domain: \(error.domain)")
                    print("   Retrying in \(delay) seconds...")
                    try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
                    continue
                } else {
                    // Not a retryable error or max retries reached
                    print("❌❌❌ REQUEST FAILED (FINAL) ❌❌❌")
                    print("   Error: \(error.localizedDescription)")
                    print("   Error code: \(error.code)")
                    print("   Error domain: \(error.domain)")
                    print("   Attempts: \(attempt)/\(retryCount)")
                    if let urlError = error.userInfo[NSUnderlyingErrorKey] as? NSError {
                        print("   Underlying error: \(urlError.localizedDescription)")
                    }
                    throw error
                }
            }
        }
        
        // If we get here, all retries failed
        throw lastError ?? NSError(domain: "SupabaseService", code: -999, userInfo: [NSLocalizedDescriptionKey: "Request failed after \(retryCount) attempts"])
    }
    
    // MARK: - Encoding/Decoding Helpers
    
    private func decodeAuthUser(from dict: [String: Any]) throws -> AuthUser {
        guard let id = dict["id"] as? String, !id.isEmpty else {
            print("❌ ERROR: No 'id' field in user JSON or id is empty")
            print("   JSON keys: \(dict.keys.joined(separator: ", "))")
            print("   JSON content: \(dict)")
            throw NSError(domain: "SupabaseService", code: -5, userInfo: [
                NSLocalizedDescriptionKey: "No user ID in response",
                "jsonKeys": dict.keys.joined(separator: ", ")
            ])
        }
        
        let email = dict["email"] as? String
        let name = (dict["user_metadata"] as? [String: Any])?["name"] as? String
        
        print("✅ Decoded user: id=\(id), email=\(email ?? "nil"), name=\(name ?? "nil")")
        
        return AuthUser(
            id: id,
            email: email,
            name: name
        )
    }
    
    private func decodeUserProfile(from dict: [String: Any]) throws -> UserProfile {
        // Decode from database format
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        
        if let jsonData = try? JSONSerialization.data(withJSONObject: dict) {
            return try decoder.decode(UserProfile.self, from: jsonData)
        }
        
        throw NSError(domain: "SupabaseService", code: -4, userInfo: [NSLocalizedDescriptionKey: "Failed to decode UserProfile"])
    }
    
    private func encodeUserProfile(_ profile: UserProfile) throws -> [String: Any] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        
        let jsonData = try encoder.encode(profile)
        guard var dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "SupabaseService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to encode UserProfile"])
        }
        
        // CRITICAL: Remove createdAt and updatedAt if they don't exist in database schema
        // These fields may be managed by database triggers or may not exist yet
        // If you see "Could not find column" errors, either:
        // 1. Add these columns to database (see SUPABASE_DATABASE_MIGRATION.sql)
        // 2. Or remove them from the dict before sending (current approach)
        dict.removeValue(forKey: "createdAt")
        dict.removeValue(forKey: "updatedAt")
        
        // CRITICAL: Database schema must match UserProfile model
        // If you see "Could not find column" errors, run SUPABASE_DATABASE_MIGRATION.sql
        // This ensures all columns exist in the user_profiles table
        
        return dict
    }
    
    private func decodeUserSubscription(from dict: [String: Any]) throws -> UserSubscription {
        return UserSubscription(
            id: UUID(uuidString: dict["id"] as? String ?? "") ?? UUID(),
            userId: UUID(uuidString: dict["user_id"] as? String ?? "") ?? UUID(),
            planType: UserSubscription.PlanType(rawValue: dict["plan_type"] as? String ?? "") ?? .monthly,
            status: UserSubscription.Status(rawValue: dict["status"] as? String ?? "") ?? .expired,
            startDate: ISO8601DateFormatter().date(from: dict["start_date"] as? String ?? "") ?? Date(),
            endDate: ISO8601DateFormatter().date(from: dict["end_date"] as? String ?? "") ?? Date()
        )
    }
    
    private func encodeUserSubscription(_ subscription: UserSubscription) throws -> [String: Any] {
        let formatter = ISO8601DateFormatter()
        return [
            "id": subscription.id.uuidString,
            "user_id": subscription.userId.uuidString,
            "plan_type": subscription.planType.rawValue,
            "status": subscription.status.rawValue,
            "start_date": formatter.string(from: subscription.startDate),
            "end_date": formatter.string(from: subscription.endDate)
        ]
    }
}

// MARK: - Models

struct AuthResponse {
    let accessToken: String
    let refreshToken: String
    let user: AuthUser
}

struct AuthUser: Codable {
    let id: String
    let email: String?
    let name: String?
}

struct UserSubscription: Codable {
    let id: UUID
    let userId: UUID
    let planType: PlanType
    let status: Status
    let startDate: Date
    let endDate: Date
    
    enum PlanType: String, Codable {
        case yearly = "yearly"
        case quarterly = "quarterly"
        case monthly = "monthly"
    }
    
    enum Status: String, Codable {
        case active = "active"
        case expired = "expired"
        case cancelled = "cancelled"
    }
}
