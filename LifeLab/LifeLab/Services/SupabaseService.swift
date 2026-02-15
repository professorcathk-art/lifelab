import Foundation
import Combine

/// Supabase Service - Handles all Supabase operations
/// Uses SupabaseConfig for secure key management
/// Uses URLSession for API calls (no external SDK required)
class SupabaseService: ObservableObject {
    static let shared = SupabaseService()
    
    private init() {
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
        return try await makeAuthRequest(
            endpoint: "/auth/v1/signup",
            body: [
                "email": email,
                "password": password,
                "data": name != nil ? ["name": name!] : [:]
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
        // Supabase expects the token in the Authorization header
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
            "id_token": token
        ]
        
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
        guard UserDefaults.standard.string(forKey: "supabase_access_token") != nil,
              let data = UserDefaults.standard.data(forKey: "supabase_user_data"),
              let user = try? JSONDecoder().decode(AuthUser.self, from: data) else {
            return nil
        }
        return user
    }
    
    // MARK: - Database Operations
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
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
            return nil
        }
        
        print("✅ Found profile in Supabase for user \(userId)")
        return try decodeUserProfile(from: firstProfile)
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        // IMPORTANT: Ensure profile ID matches authenticated user ID
        // Get current authenticated user ID from AuthService
        guard let currentUserId = AuthService.shared.currentUser?.id else {
            throw NSError(domain: "SupabaseService", code: -10, userInfo: [NSLocalizedDescriptionKey: "Not authenticated"])
        }
        
        // Create profile dict with correct user ID
        var profileDict = try encodeUserProfile(profile)
        
        // Ensure id field matches authenticated user ID
        profileDict["id"] = currentUserId
        
        // Check if profile exists
        let existing = try await fetchUserProfile(userId: currentUserId)
        
        if existing != nil {
            // Update existing
            print("📝 Updating existing profile in Supabase for user \(currentUserId)")
            _ = try await makeRequest(
                endpoint: "/rest/v1/user_profiles",
                method: "PATCH",
                body: profileDict,
                queryParams: ["id": "eq.\(currentUserId)"]
            )
            print("✅ Profile updated in Supabase")
        } else {
            // Insert new
            print("➕ Creating new profile in Supabase for user \(currentUserId)")
            _ = try await makeRequest(
                endpoint: "/rest/v1/user_profiles",
                method: "POST",
                body: profileDict
            )
            print("✅ Profile created in Supabase")
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
        
        request.httpBody = try JSONSerialization.data(withJSONObject: body)
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard httpResponse.statusCode == 200 || httpResponse.statusCode == 201 else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "SupabaseService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "Auth error: \(errorMessage)"])
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
    
    private func makeRequest(
        endpoint: String,
        method: String,
        body: [String: Any]? = nil,
        queryParams: [String: String]? = nil
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
        
        // Use access token if available, otherwise use anon key
        let token = UserDefaults.standard.string(forKey: "supabase_access_token") ?? SupabaseConfig.anonKey
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue(SupabaseConfig.anonKey, forHTTPHeaderField: "apikey")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        request.setValue("prefer", forHTTPHeaderField: "return=representation")
        
        if let body = body {
            request.httpBody = try JSONSerialization.data(withJSONObject: body)
        }
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NSError(domain: "SupabaseService", code: -2, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
            throw NSError(domain: "SupabaseService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: "API error (\(httpResponse.statusCode)): \(errorMessage)"])
        }
        
        guard let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            // For GET requests, response might be an array
            if let array = try? JSONSerialization.jsonObject(with: data) as? [[String: Any]] {
                return ["data": array]
            }
            throw NSError(domain: "SupabaseService", code: -3, userInfo: [NSLocalizedDescriptionKey: "Failed to parse response"])
        }
        
        return json
    }
    
    // MARK: - Encoding/Decoding Helpers
    
    private func decodeAuthUser(from dict: [String: Any]) throws -> AuthUser {
        return AuthUser(
            id: dict["id"] as? String ?? "",
            email: dict["email"] as? String,
            name: (dict["user_metadata"] as? [String: Any])?["name"] as? String
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
        guard let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "SupabaseService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to encode UserProfile"])
        }
        
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
