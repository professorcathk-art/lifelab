import Foundation
import Combine
import Network

/// DataService with intelligent caching strategy
/// - Local-first: Loads from UserDefaults instantly (no delay)
/// - Background sync: Syncs with Supabase in background (non-blocking)
/// - Offline support: Works offline using cached data
/// - Smart updates: Only syncs when data changes
class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var userProfile: UserProfile?
    @Published var isSyncing = false
    @Published var lastSyncTime: Date?
    // CRITICAL: Shared state for action plan generation across multiple views
    // This ensures button disappears in both DeepeningExplorationView and TaskManagementView
    @Published var isGeneratingActionPlan: Bool = false
    
    // Use user-specific keys to ensure data isolation between users
    private var userDefaultsKey: String {
        if let userId = AuthService.shared.currentUser?.id {
            return "lifelab_user_profile_\(userId)"
        }
        return "lifelab_user_profile" // Fallback for unauthenticated state
    }
    
    private var lastSyncKey: String {
        if let userId = AuthService.shared.currentUser?.id {
            return "lifelab_last_sync_time_\(userId)"
        }
        return "lifelab_last_sync_time"
    }
    // Use official Supabase SDK
    private let supabaseService = SupabaseServiceV2.shared
    private let networkMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")
    private var isOnline = true
    
    private init() {
        // Start network monitoring
        startNetworkMonitoring()
        
        // Load from local cache if authenticated (user-specific)
        if AuthService.shared.isAuthenticated {
            loadUserProfile()
            // Auto-sync if authenticated and online
            Task {
                await syncIfNeeded()
            }
        } else {
            // Clear profile if not authenticated
            userProfile = nil
        }
    }
    
    // MARK: - Public Methods
    
    /// Save user profile (local-first, then sync in background)
    func saveUserProfile(_ profile: UserProfile) {
        // Update local state immediately (instant UI update)
        userProfile = profile
        saveToUserDefaults(profile)
        
        // IMPORTANT: Always sync to Supabase when authenticated
        // This ensures data is persisted even if app is closed
        if AuthService.shared.isAuthenticated && isOnline {
            Task {
                await syncToSupabase(profile: profile)
            }
        } else if AuthService.shared.isAuthenticated {
            // Even if offline, mark for sync when online
            print("📱 Offline: Data saved locally, will sync when online")
        }
    }
    
    /// Update user profile (local-first, then sync in background)
    func updateUserProfile(_ update: (inout UserProfile) -> Void) {
        var profile = userProfile ?? UserProfile()
        update(&profile)
        profile.updatedAt = Date()
        saveUserProfile(profile)
        
        // IMPORTANT: Force sync immediately after update (don't wait for background sync)
        // This ensures data is synced to Supabase right away
        if AuthService.shared.isAuthenticated && isOnline {
            Task {
                // Small delay to ensure UserDefaults is updated
                try? await Task.sleep(nanoseconds: 100_000_000) // 0.1 seconds
                await syncToSupabase(profile: profile)
            }
        }
    }
    
    /// Load from Supabase (background, non-blocking)
    /// LOCAL-FIRST: Always load from device storage first, then merge with Supabase
    func loadFromSupabase(userId: String) async {
        print("📥 DataService.loadFromSupabase called for user: \(userId)")
        
        // CRITICAL: Load local data FIRST on main thread - ensures UI has data immediately
        await MainActor.run {
            loadUserProfileForUser(userId: userId)
        }
        if let localProfile = userProfile {
            print("📱 Loaded local profile: \(localProfile.interests.count) interests, \(localProfile.strengths.count) strengths, blueprint: \(localProfile.lifeBlueprint != nil ? "YES" : "NO")")
        } else {
            print("📱 No local profile found")
        }
        
        guard isOnline else {
            print("⚠️ Offline: Using cached local data")
            return
        }
        
        print("🌐 Online: Fetching profile from Supabase...")
        do {
            if let profile = try await supabaseService.fetchUserProfile(userId: userId) {
                print("✅ Successfully fetched profile from Supabase: \(profile.interests.count) interests, \(profile.strengths.count) strengths, \(profile.values.count) values")
                print("   🔍 Has lifeBlueprint: \(profile.lifeBlueprint != nil ? "YES ✅" : "NO ❌")")
                if let blueprint = profile.lifeBlueprint {
                    print("   📋 Blueprint version: \(blueprint.version), created at: \(blueprint.createdAt)")
                }
                await MainActor.run {
                    // LOCAL-FIRST: Never overwrite local data with incomplete Supabase data
                    if let localProfile = self.userProfile {
                        // Local data exists - merge intelligently, ALWAYS preserve local critical data
                        if localProfile.updatedAt > profile.updatedAt {
                            // Local is newer, keep local but sync to Supabase
                            print("📱 Local data is newer, keeping local version")
                            Task {
                                await self.syncToSupabase(profile: localProfile)
                            }
                        } else {
                            // Supabase is newer - but CRITICAL: preserve local lifeBlueprint/actionPlan if Supabase lacks them
                            // (Supabase may lack these if column was missing or sync failed)
                            var mergedProfile = profile
                            mergedProfile.interests = localProfile.interests.isEmpty ? profile.interests : localProfile.interests
                            mergedProfile.strengths = localProfile.strengths.isEmpty ? profile.strengths : localProfile.strengths
                            mergedProfile.values = localProfile.values.isEmpty ? profile.values : localProfile.values
                            // CRITICAL: Never lose local blueprint - Supabase may not have it (column missing, sync failed)
                            if profile.lifeBlueprint == nil && localProfile.lifeBlueprint != nil {
                                mergedProfile.lifeBlueprint = localProfile.lifeBlueprint
                                mergedProfile.lifeBlueprints = localProfile.lifeBlueprints.isEmpty ? [] : localProfile.lifeBlueprints
                                print("📱 Preserved local lifeBlueprint (Supabase lacks it - sync may have failed)")
                            }
                            if profile.actionPlan == nil && localProfile.actionPlan != nil {
                                mergedProfile.actionPlan = localProfile.actionPlan
                                print("📱 Preserved local actionPlan (Supabase lacks it)")
                            }
                            
                            self.userProfile = mergedProfile
                            self.saveToUserDefaults(mergedProfile)
                            self.lastSyncTime = Date()
                            let syncKey = "lifelab_last_sync_time_\(userId)"
                            UserDefaults.standard.set(Date(), forKey: syncKey)
                            print("✅ Merged profile from Supabase with local data")
                        }
                    } else {
                        // No local data, use Supabase
                        self.userProfile = profile
                        self.saveToUserDefaults(profile)
                        self.lastSyncTime = Date()
                        let syncKey = "lifelab_last_sync_time_\(userId)"
                        UserDefaults.standard.set(Date(), forKey: syncKey)
                        print("✅ Loaded profile from Supabase")
                    }
                }
            } else {
                // No profile in Supabase, create one from local if exists
                await MainActor.run {
                    if self.userProfile != nil {
                        Task {
                            await self.createUserProfileInSupabase(userId: userId)
                        }
                    } else {
                        // No local data either, create new profile
                        let newProfile = UserProfile()
                        self.userProfile = newProfile
                        self.saveToUserDefaults(newProfile)
                        Task {
                            await self.createUserProfileInSupabase(userId: userId)
                        }
                    }
                }
            }
        } catch {
            print("❌ Failed to load from Supabase: \(error.localizedDescription)")
            print("   Error details: \(error)")
            // Continue using local data (offline support)
            // Ensure local data is loaded
            loadUserProfile()
            if let localProfile = userProfile {
                print("📱 Using local cached data: \(localProfile.interests.count) interests")
            } else {
                print("⚠️ No local data available either")
            }
        }
    }
    
    /// Sync to Supabase (background, non-blocking)
    func syncToSupabase(profile: UserProfile? = nil) async {
        // Debug: Log all sync conditions
        print("🔍🔍🔍 SYNC CHECK STARTED 🔍🔍🔍")
        print("   isOnline: \(isOnline)")
        print("   isAuthenticated: \(AuthService.shared.isAuthenticated)")
        print("   currentUser: \(AuthService.shared.currentUser?.id ?? "nil")")
        print("   profile provided: \(profile != nil)")
        print("   local userProfile exists: \(userProfile != nil)")
        
        guard isOnline else {
            print("⚠️ Offline: Data saved locally, will sync when online")
            return
        }
        
        guard let userId = AuthService.shared.currentUser?.id else {
            print("⚠️ Not authenticated, skipping sync")
            return
        }
        
        // Official SDK automatically manages authentication tokens
        // No need to check UserDefaults - SDK handles it internally
        
        let profileToSync = profile ?? userProfile
        
        guard let profileToSave = profileToSync else {
            print("⚠️ No profile to sync")
            return
        }
        
        // IMPORTANT: Profile ID will be corrected in SupabaseService.saveUserProfile
        // to match authenticated user ID
        
        // Check if sync is needed (avoid unnecessary syncs)
        // But don't skip if this is a forced sync
        if profile == nil, let lastSync = lastSyncTime,
           Date().timeIntervalSince(lastSync) < 5.0 {
            // Synced less than 5 seconds ago, skip (unless forced)
            print("⏳ Skipping sync: Too soon since last sync")
            return
        }
        
        await MainActor.run {
            self.isSyncing = true
        }
        
        do {
            print("💾💾💾 STARTING SYNC TO SUPABASE 💾💾💾")
            print("   User ID: \(userId)")
            print("   Profile has: \(profileToSave.interests.count) interests, \(profileToSave.strengths.count) strengths, \(profileToSave.values.count) values")
            print("   Has basicInfo: \(profileToSave.basicInfo != nil)")
            print("   Has lifeBlueprint: \(profileToSave.lifeBlueprint != nil)")
            print("   Has actionPlan: \(profileToSave.actionPlan != nil)")
            
            // IMPORTANT: Ensure profile has correct user ID before saving
            print("   Calling supabaseService.saveUserProfile...")
            try await supabaseService.saveUserProfile(profileToSave)
            
            await MainActor.run {
                self.lastSyncTime = Date()
                let syncKey = "lifelab_last_sync_time_\(userId)"
                UserDefaults.standard.set(Date(), forKey: syncKey)
                self.isSyncing = false
            }
            print("✅✅✅ SYNC SUCCESSFUL ✅✅✅")
            print("   Successfully synced profile to Supabase for user \(userId)")
            print("   ✅ Data is now persisted in Supabase database")
            print("   Sync time saved: \(Date())")
        } catch let error as NSError {
            await MainActor.run {
                self.isSyncing = false
            }
            
            // Check if it's a network error
            let isNetworkError = error.domain == NSURLErrorDomain && (
                error.code == NSURLErrorTimedOut ||
                error.code == NSURLErrorNetworkConnectionLost ||
                error.code == NSURLErrorNotConnectedToInternet ||
                error.code == NSURLErrorCannotConnectToHost
            )
            
            if isNetworkError {
                print("⚠️⚠️⚠️ NETWORK ERROR DURING SYNC ⚠️⚠️⚠️")
                print("   Error: \(error.localizedDescription)")
                print("   Error code: \(error.code)")
                print("   📡 Network status: \(isOnline ? "Online (but connection failed)" : "Offline")")
                print("   💾 Data saved locally: ✅")
                print("   🔄 Will retry automatically when network is available")
                print("   📱 App will continue working with local data")
                
                // Schedule automatic retry when network becomes available
                // Network monitor will trigger sync when connectivity is restored
            } else {
                print("❌❌❌ FAILED TO SYNC TO SUPABASE ❌❌❌")
                print("   Error: \(error.localizedDescription)")
                print("   Error details: \(error)")
                print("   Error code: \(error.code)")
                print("   Error domain: \(error.domain)")
                print("   💾 Data saved locally - your data is SAFE on this device")
                if (error.localizedDescription.contains("life_blueprint") || error.localizedDescription.contains("column")) {
                    print("   ⚠️ SCHEMA ERROR: Run SUPABASE_ADD_LIFE_BLUEPRINT_COLUMN.sql in Supabase Dashboard → SQL Editor")
                }
            }
            // Continue using local data (offline support)
        } catch {
            await MainActor.run {
                self.isSyncing = false
            }
            print("❌ Failed to sync to Supabase: \(error.localizedDescription)")
            print("   Error details: \(error)")
            print("   Data saved locally but NOT synced to Supabase")
            // Continue using local data (offline support)
        }
    }
    
    /// Create user profile in Supabase (background, non-blocking)
    func createUserProfileInSupabase(userId: String) async {
        guard isOnline else {
            print("⚠️ Offline: Will create profile when online")
            return
        }
        
        guard let profile = userProfile else {
            // Create a new profile
            let newProfile = UserProfile()
            await MainActor.run {
                self.userProfile = newProfile
                self.saveToUserDefaults(newProfile)
            }
            
            do {
                try await supabaseService.saveUserProfile(newProfile)
                print("✅ Created user profile in Supabase")
            } catch {
                print("⚠️ Failed to create profile in Supabase: \(error.localizedDescription)")
            }
            return
        }
        
        do {
            try await supabaseService.saveUserProfile(profile)
            await MainActor.run {
                self.lastSyncTime = Date()
                let syncKey = "lifelab_last_sync_time_\(userId)"
                UserDefaults.standard.set(Date(), forKey: syncKey)
            }
            print("✅ Created user profile in Supabase")
        } catch {
            print("⚠️ Failed to create profile in Supabase: \(error.localizedDescription)")
        }
    }
    
    /// Clear user profile for current user (local and Supabase)
    func clearUserProfile() {
        // Clear current user's data
        if let userId = AuthService.shared.currentUser?.id {
            let userKey = "lifelab_user_profile_\(userId)"
            let syncKey = "lifelab_last_sync_time_\(userId)"
            UserDefaults.standard.removeObject(forKey: userKey)
            UserDefaults.standard.removeObject(forKey: syncKey)
        } else {
            // Fallback: clear default keys
            UserDefaults.standard.removeObject(forKey: "lifelab_user_profile")
            UserDefaults.standard.removeObject(forKey: "lifelab_last_sync_time")
        }
        
        userProfile = nil
        lastSyncTime = nil
        print("✅ Cleared user profile data")
    }
    
    /// Clear all user profiles (for testing/debugging)
    func clearAllUserProfiles() {
        // Clear all user-specific keys
        let defaults = UserDefaults.standard
        let keys = defaults.dictionaryRepresentation().keys
        for key in keys {
            if key.hasPrefix("lifelab_user_profile_") || key.hasPrefix("lifelab_last_sync_time_") {
                defaults.removeObject(forKey: key)
            }
        }
        // Also clear default keys
        defaults.removeObject(forKey: "lifelab_user_profile")
        defaults.removeObject(forKey: "lifelab_last_sync_time")
        
        userProfile = nil
        lastSyncTime = nil
        print("✅ Cleared all user profiles")
    }
    
    // MARK: - Private Methods
    
    /// Load from local cache for current user (instant, no delay)
    private func loadUserProfile() {
        guard let userId = AuthService.shared.currentUser?.id else {
            userProfile = nil
            return
        }
        loadUserProfileForUser(userId: userId)
    }
    
    /// Load user-specific profile from local cache
    /// IMPORTANT: This is public so AuthService can call it immediately after login
    /// CRITICAL: This function MUST be called AFTER currentUser is set in AuthService
    /// to ensure we load the correct user's data
    func loadUserProfileForUser(userId: String) {
        // CRITICAL: Verify that AuthService.currentUser matches the userId we're loading
        // This prevents loading wrong user's data
        if let currentUserId = AuthService.shared.currentUser?.id {
            if currentUserId != userId {
                print("❌❌❌ CRITICAL ERROR: User ID mismatch! ❌❌❌")
                print("   AuthService.currentUser.id: \(currentUserId)")
                print("   Requested userId: \(userId)")
                print("   This should NEVER happen - aborting load to prevent data leakage")
                return
            }
        } else {
            print("⚠️ Warning: AuthService.currentUser is nil, but loading data for user \(userId)")
            print("   This might happen during logout/login transition")
        }
        
        let userKey = "lifelab_user_profile_\(userId)"
        print("🔍🔍🔍 LOADING LOCAL DATA FOR USER 🔍🔍🔍")
        print("   User ID: \(userId)")
        print("   UserDefaults key: \(userKey)")
        
        if let data = UserDefaults.standard.data(forKey: userKey) {
            print("   ✅ Found data in UserDefaults (\(data.count) bytes)")
            if let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
                // CRITICAL: Update on main thread for SwiftUI @Published
                userProfile = profile
                
                // Load sync time
                let syncKey = "lifelab_last_sync_time_\(userId)"
                if let syncTime = UserDefaults.standard.object(forKey: syncKey) as? Date {
                    lastSyncTime = syncTime
                }
                
                print("✅✅✅ LOADED USER PROFILE FROM LOCAL CACHE ✅✅✅")
                print("   User: \(userId)")
                print("   Interests: \(profile.interests.count)")
                print("   Strengths: \(profile.strengths.count)")
                print("   Values: \(profile.values.count)")
                print("   Has basicInfo: \(profile.basicInfo != nil)")
                print("   Has blueprint: \(profile.lifeBlueprint != nil)")
                print("   Has actionPlan: \(profile.actionPlan != nil)")
            } else {
                print("❌ Failed to decode profile data")
            }
        } else {
            print("📱 No local profile found for user \(userId)")
            print("   This is expected for a new user")
            // CRITICAL: Ensure userProfile is nil if no data found
            // This prevents showing old user's data
            userProfile = nil
        }
    }
    
    /// Save to user-specific local cache
    private func saveToUserDefaults(_ profile: UserProfile) {
        guard let userId = AuthService.shared.currentUser?.id else {
            print("⚠️ Cannot save profile: No authenticated user")
            return
        }
        
        let userKey = "lifelab_user_profile_\(userId)"
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userKey)
            print("✅ Saved user profile for user \(userId) to local cache")
        }
    }
    
    /// Sync if needed (smart sync strategy)
    private func syncIfNeeded() async {
        guard isOnline else {
            return
        }
        
        guard let userId = AuthService.shared.currentUser?.id else {
            return
        }
        
        // Check if we need to sync
        if let lastSync = lastSyncTime {
            let timeSinceLastSync = Date().timeIntervalSince(lastSync)
            // Sync if last sync was more than 30 seconds ago
            if timeSinceLastSync < 30 {
                return
            }
        }
        
        // Load from Supabase to check for updates
        await loadFromSupabase(userId: userId)
    }
    
    /// Start network monitoring
    private func startNetworkMonitoring() {
        networkMonitor.pathUpdateHandler = { [weak self] path in
            let wasOnline = self?.isOnline ?? false
            self?.isOnline = path.status == .satisfied
            
            if !wasOnline && self?.isOnline == true {
                // Just came online, sync data
                print("🌐 Network connected, syncing data...")
                Task {
                    await self?.syncIfNeeded()
                }
            }
        }
        networkMonitor.start(queue: monitorQueue)
    }
}
