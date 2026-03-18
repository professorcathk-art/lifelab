import Foundation
import Supabase

/// Supabase Service using official supabase-swift SDK
/// This replaces the custom URLSession implementation for better reliability
class SupabaseServiceV2 {
    static let shared = SupabaseServiceV2()
    
    let client: SupabaseClient
    
    private init() {
        let url = SupabaseConfig.projectURL
        let anonKey = SupabaseConfig.anonKey
        
        guard !url.isEmpty, !anonKey.isEmpty,
              let supabaseURL = URL(string: url) else {
            fatalError("❌ Invalid Supabase configuration. URL: \(url), Key: \(anonKey.prefix(20))...")
        }
        
        // Initialize Supabase client with default configuration
        // Note: The SDK warning about initial session emission is expected behavior
        // and will be fixed in the next major release. Our code handles session checks properly.
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: anonKey
        )
        
        print("✅ Supabase client initialized with official SDK")
        print("   URL: \(url)")
        print("   Key (first 20 chars): \(anonKey.prefix(20))...")
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, name: String?) async throws -> AuthResponse {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: name != nil ? ["name": .string(name!)] : [:]
        )
        
        // signUp may return nil session if email confirmation is required
        guard let session = response.session else {
            throw NSError(
                domain: "SupabaseService",
                code: -4,
                userInfo: [NSLocalizedDescriptionKey: "Please check your email to confirm your account"]
            )
        }
        
        return AuthResponse(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            user: AuthUser(
                id: response.user.id.uuidString,
                email: response.user.email,
                name: name
            )
        )
    }
    
    func signIn(email: String, password: String) async throws -> AuthResponse {
        do {
            let session = try await client.auth.signIn(
                email: email,
                password: password
            )
            return AuthResponse(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: AuthUser(
                    id: session.user.id.uuidString,
                    email: session.user.email,
                    name: nil
                )
            )
        } catch {
            let msg = error.localizedDescription.lowercased()
            let underlying = (error as NSError).userInfo[NSUnderlyingErrorKey] as? NSError
            let underlyingMsg = underlying?.localizedDescription.lowercased() ?? ""
            let full = msg + " " + underlyingMsg
            if full.contains("invalid login credentials") || full.contains("invalid_grant") ||
               full.contains("user not found") || full.contains("invalid_credentials") {
                throw NSError(
                    domain: "SupabaseService",
                    code: 401,
                    userInfo: [
                        NSLocalizedDescriptionKey: "Invalid login credentials",
                        "shouldShowSignUp": true
                    ]
                )
            }
            throw error
        }
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async throws -> AuthUser? {
        do {
            // Use session to get current user
            let session = try await client.auth.session
            let user = session.user
            
            // Extract name from userMetadata
            // userMetadata is [String: AnyJSON], access values directly
            var name: String? = nil
            if let nameValue = user.userMetadata["name"] {
                // AnyJSON can be accessed via stringValue property or pattern matching
                if case .string(let userName) = nameValue {
                    name = userName
                } else if let userName = nameValue.stringValue {
                    name = userName
                }
            }
            
            return AuthUser(
                id: user.id.uuidString,
                email: user.email,
                name: name
            )
        } catch {
            return nil
        }
    }
    
    func signInWithOAuth(provider: String, token: String) async throws -> AuthResponse {
        // For Apple Sign In, use signInWithIdToken
        if provider.lowercased() == "apple" {
            let credentials = OpenIDConnectCredentials(
                provider: .apple,
                idToken: token,
                nonce: nil
            )
            
            let session = try await client.auth.signInWithIdToken(credentials: credentials)
            let user = session.user
            
            // Extract name from userMetadata
            // userMetadata is [String: AnyJSON], access values directly
            var name: String? = nil
            if let nameValue = user.userMetadata["name"] {
                // AnyJSON can be accessed via stringValue property or pattern matching
                if case .string(let userName) = nameValue {
                    name = userName
                } else if let userName = nameValue.stringValue {
                    name = userName
                }
            }
            
            return AuthResponse(
                accessToken: session.accessToken,
                refreshToken: session.refreshToken,
                user: AuthUser(
                    id: user.id.uuidString,
                    email: user.email,
                    name: name
                )
            )
        } else {
            // For other OAuth providers, use the standard OAuth flow
            throw NSError(
                domain: "SupabaseService",
                code: -5,
                userInfo: [NSLocalizedDescriptionKey: "OAuth provider \(provider) not supported"]
            )
        }
    }
    
    func resetPassword(email: String) async throws {
        // resetPasswordForEmail sends a password recovery email
        // For mobile apps, redirectTo can be a custom URL scheme
        guard let redirectTo = URL(string: "lifelab://reset-password") else {
            throw NSError(
                domain: "SupabaseService",
                code: -6,
                userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URL"]
            )
        }
        try await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo)
    }
    
    // MARK: - Email OTP Authentication
    
    /// Register OTP - Step 1: Send OTP to email
    /// Uses signUp (not signInWithOTP) to trigger Confirm signup template.
    /// signInWithOTP always uses Magic Link template; signUp uses Confirm signup template.
    /// We pass a temporary password; user sets real password after OTP verification.
    func sendSignUpOTP(email: String, name: String? = nil) async throws {
        let tempPassword = UUID().uuidString + "A1!" // Temporary; replaced after OTP verify
        var data: [String: AnyJSON] = [:]
        if let name = name, !name.isEmpty {
            data["name"] = .string(name)
        }
        do {
            _ = try await client.auth.signUp(
                email: email,
                password: tempPassword,
                data: data
            )
        } catch {
            let msg = error.localizedDescription.lowercased()
            if msg.contains("user already registered") || msg.contains("email already exists") ||
               msg.contains("already registered") {
                throw NSError(
                    domain: "SupabaseService",
                    code: 422,
                    userInfo: [
                        NSLocalizedDescriptionKey: "此電子郵件已被註冊，請使用登錄。",
                        "userAlreadyExists": true
                    ]
                )
            }
            throw error
        }
    }
    
    /// Forgot password OTP - Step 1: Send recovery OTP to email
    /// Uses resetPasswordForEmail; template must include {{ .Token }} for OTP display
    func sendRecoveryOTP(email: String) async throws {
        guard let redirectTo = URL(string: "lifelab://reset-password") else {
            throw NSError(domain: "SupabaseService", code: -6, userInfo: [NSLocalizedDescriptionKey: "Invalid redirect URL"])
        }
        try await client.auth.resetPasswordForEmail(email, redirectTo: redirectTo)
    }
    
    /// Register OTP - Step 2: Verify OTP and set password
    /// verifyOTP with .signup establishes session, then updateUser sets password
    func verifySignUpOTP(email: String, token: String, password: String, name: String? = nil) async throws -> AuthResponse {
        let response = try await client.auth.verifyOTP(
            email: email,
            token: token,
            type: .signup
        )
        guard let session = response.session else {
            throw NSError(domain: "SupabaseService", code: -7, userInfo: [NSLocalizedDescriptionKey: "OTP verification failed - no session"])
        }
        // Set password and name for the new user
        if !password.isEmpty {
            _ = try await client.auth.update(user: UserAttributes(password: password))
        }
        if let name = name, !name.isEmpty {
            _ = try await client.auth.update(user: UserAttributes(data: ["name": .string(name)]))
        }
        var userName: String? = name
        if userName == nil, let nameValue = session.user.userMetadata["name"] {
            if case .string(let n) = nameValue { userName = n } else { userName = nameValue.stringValue }
        }
        return AuthResponse(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            user: AuthUser(
                id: session.user.id.uuidString,
                email: session.user.email ?? email,
                name: userName
            )
        )
    }
    
    /// Forgot password OTP - Step 2: Verify OTP and set new password
    /// verifyOTP with .recovery establishes session, then updateUser sets password
    func verifyRecoveryOTP(email: String, token: String, newPassword: String) async throws -> AuthResponse {
        let response = try await client.auth.verifyOTP(
            email: email,
            token: token,
            type: .recovery
        )
        guard let session = response.session else {
            throw NSError(domain: "SupabaseService", code: -8, userInfo: [NSLocalizedDescriptionKey: "Recovery OTP verification failed - no session"])
        }
        _ = try await client.auth.update(user: UserAttributes(password: newPassword))
        return AuthResponse(
            accessToken: session.accessToken,
            refreshToken: session.refreshToken,
            user: AuthUser(
                id: session.user.id.uuidString,
                email: session.user.email ?? email,
                name: nil
            )
        )
    }
    
    // MARK: - User Profile Operations
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        print("🔍 Fetching user profile from Supabase for user: \(userId)")
        
        do {
            let response: [UserProfileRow] = try await client
                .from("user_profiles")
                .select()
                .eq("id", value: userId)
                .execute()
                .value
            
            guard let row = response.first else {
                print("📭 No profile found in Supabase for user \(userId)")
                return nil
            }
            
            print("✅ Found profile in Supabase")
            return try decodeUserProfile(from: row)
        } catch {
            print("❌ Failed to fetch profile: \(error.localizedDescription)")
            print("   Error details: \(error)")
            throw error
        }
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            print("❌ Cannot save profile: Not authenticated")
            throw NSError(
                domain: "SupabaseService",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }
        
        print("💾💾💾 SAVING PROFILE TO SUPABASE (Official SDK) 💾💾💾")
        print("   User ID: \(userId)")
        print("   Profile has:")
        print("     - \(profile.interests.count) interests")
        print("     - \(profile.strengths.count) strengths")
        print("     - \(profile.values.count) values")
        print("     - basicInfo: \(profile.basicInfo != nil ? "YES" : "NO")")
        print("     - lifeBlueprint: \(profile.lifeBlueprint != nil ? "YES" : "NO")")
        print("     - actionPlan: \(profile.actionPlan != nil ? "YES" : "NO")")
        
        let row = try encodeUserProfile(profile, userId: userId)
        
        // Check if profile exists
        let existing: [UserProfileRow] = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        if existing.isEmpty {
            // Insert new profile
            print("➕ Creating new profile in Supabase...")
            try await client
                .from("user_profiles")
                .insert(row)
                .execute()
            print("✅✅✅ PROFILE CREATED SUCCESSFULLY ✅✅✅")
        } else {
            // Update existing profile
            print("📝 Updating existing profile in Supabase...")
            try await client
                .from("user_profiles")
                .update(row)
                .eq("id", value: userId)
                .execute()
            print("✅✅✅ PROFILE UPDATED SUCCESSFULLY ✅✅✅")
        }
        
        // Verify save
        print("🔍 Verifying profile was saved...")
        if (try? await fetchUserProfile(userId: userId)) != nil {
            print("✅ Verification successful: Profile exists in Supabase")
        } else {
            print("⚠️ Verification warning: Profile not found immediately after save")
        }
    }
    
    // MARK: - User Subscription Operations
    
    func fetchUserSubscription(userId: String) async throws -> UserSubscription? {
        let response: [UserSubscriptionRow] = try await client
            .from("user_subscriptions")
            .select()
            .eq("user_id", value: userId)
            .eq("status", value: "active")
            .order("created_at", ascending: false, nullsFirst: false)
            .execute()
            .value
        
        guard let row = response.first else {
            return nil
        }
        
        return UserSubscription(
            id: UUID(uuidString: row.id) ?? UUID(),
            userId: UUID(uuidString: row.userId) ?? UUID(),
            planType: UserSubscription.PlanType(rawValue: row.planType) ?? .monthly,
            status: UserSubscription.Status(rawValue: row.status) ?? .expired,
            startDate: ISO8601DateFormatter().date(from: row.startDate) ?? Date(),
            endDate: ISO8601DateFormatter().date(from: row.endDate) ?? Date()
        )
    }
    
    func saveUserSubscription(_ subscription: UserSubscription) async throws {
        let formatter = ISO8601DateFormatter()
        let row = UserSubscriptionRow(
            id: subscription.id.uuidString,
            userId: subscription.userId.uuidString,
            planType: subscription.planType.rawValue,
            status: subscription.status.rawValue,
            startDate: formatter.string(from: subscription.startDate),
            endDate: formatter.string(from: subscription.endDate)
        )
        
        try await client
            .from("user_subscriptions")
            .insert(row)
            .execute()
        
        print("✅ Subscription saved to Supabase")
    }
    
    // MARK: - Delete User Data
    
    func deleteUserData(userId: String) async throws {
        print("🗑️ Deleting user data for user: \(userId)")
        
        // Delete user profile
        do {
            try await client
                .from("user_profiles")
                .delete()
                .eq("id", value: userId)
                .execute()
            print("✅ User profile deleted from Supabase")
        } catch {
            print("⚠️ Failed to delete user profile: \(error.localizedDescription)")
        }
        
        // Delete user subscriptions
        do {
            try await client
                .from("user_subscriptions")
                .delete()
                .eq("user_id", value: userId)
                .execute()
            print("✅ User subscriptions deleted from Supabase")
        } catch {
            print("⚠️ Failed to delete user subscriptions: \(error.localizedDescription)")
        }
        
        print("✅ User data deletion completed")
    }
    
    // MARK: - Private Models
    
    private struct UserSubscriptionRow: Codable {
        let id: String
        let userId: String
        let planType: String
        let status: String
        let startDate: String
        let endDate: String
        
        enum CodingKeys: String, CodingKey {
            case id
            case userId = "user_id"
            case planType = "plan_type"
            case status
            case startDate = "start_date"
            case endDate = "end_date"
        }
    }
    
    // MARK: - Private Helpers
    
    // Database row structure - SDK automatically handles JSONB conversion
    private struct UserProfileRow: Codable {
        let id: String
        let basicInfo: BasicUserInfo? // JSONB - SDK handles conversion
        let interests: [String]?
        let strengths: [StrengthResponse]? // JSONB - SDK handles conversion
        let values: [ValueRanking]? // JSONB - SDK handles conversion
        let flowDiaryEntries: [FlowDiaryEntry]? // JSONB - SDK handles conversion
        let valuesQuestions: ValuesQuestions? // JSONB - SDK handles conversion
        let resourceInventory: ResourceInventory? // JSONB - SDK handles conversion
        let acquiredStrengths: AcquiredStrengths? // JSONB - SDK handles conversion
        let feasibilityAssessment: FeasibilityAssessment? // JSONB - SDK handles conversion
        let lifeBlueprint: LifeBlueprint? // JSONB - SDK handles conversion
        let lifeBlueprints: [LifeBlueprint]? // JSONB - SDK handles conversion
        let actionPlan: ActionPlan? // JSONB - SDK handles conversion
        let lastBlueprintGenerationTime: String?
        
        enum CodingKeys: String, CodingKey {
            case id
            case basicInfo = "basic_info"
            case interests
            case strengths
            case values
            case flowDiaryEntries = "flow_diary_entries"
            case valuesQuestions = "values_questions"
            case resourceInventory = "resource_inventory"
            case acquiredStrengths = "acquired_strengths"
            case feasibilityAssessment = "feasibility_assessment"
            case lifeBlueprint = "life_blueprint"
            case lifeBlueprints = "life_blueprints"
            case actionPlan = "action_plan"
            case lastBlueprintGenerationTime = "last_blueprint_generation_time"
        }
    }
    
    private func encodeUserProfile(_ profile: UserProfile, userId: String) throws -> UserProfileRow {
        return UserProfileRow(
            id: userId,
            basicInfo: profile.basicInfo,
            interests: profile.interests.isEmpty ? nil : profile.interests,
            strengths: profile.strengths.isEmpty ? nil : profile.strengths,
            values: profile.values.isEmpty ? nil : profile.values,
            flowDiaryEntries: profile.flowDiaryEntries.isEmpty ? nil : profile.flowDiaryEntries,
            valuesQuestions: profile.valuesQuestions,
            resourceInventory: profile.resourceInventory,
            acquiredStrengths: profile.acquiredStrengths,
            feasibilityAssessment: profile.feasibilityAssessment,
            lifeBlueprint: profile.lifeBlueprint,
            lifeBlueprints: profile.lifeBlueprints.isEmpty ? nil : profile.lifeBlueprints,
            actionPlan: profile.actionPlan,
            lastBlueprintGenerationTime: profile.lastBlueprintGenerationTime != nil ? ISO8601DateFormatter().string(from: profile.lastBlueprintGenerationTime!) : nil
        )
    }
    
    private func decodeUserProfile(from row: UserProfileRow) throws -> UserProfile {
        var profile = UserProfile(id: UUID(uuidString: row.id) ?? UUID())
        
        // SDK automatically decodes JSONB fields
        profile.basicInfo = row.basicInfo
        profile.interests = row.interests ?? []
        profile.strengths = row.strengths ?? []
        profile.values = row.values ?? []
        profile.flowDiaryEntries = row.flowDiaryEntries ?? []
        profile.valuesQuestions = row.valuesQuestions
        profile.resourceInventory = row.resourceInventory
        profile.acquiredStrengths = row.acquiredStrengths
        profile.feasibilityAssessment = row.feasibilityAssessment
        profile.lifeBlueprint = row.lifeBlueprint
        profile.lifeBlueprints = row.lifeBlueprints ?? []
        profile.actionPlan = row.actionPlan
        
        if let timeString = row.lastBlueprintGenerationTime {
            profile.lastBlueprintGenerationTime = ISO8601DateFormatter().date(from: timeString)
        }
        
        return profile
    }
}
