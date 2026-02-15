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
    private let supabaseService = SupabaseService.shared
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
    }
    
    /// Load from Supabase (background, non-blocking)
    func loadFromSupabase(userId: String) async {
        // IMPORTANT: Load user-specific data from local storage first
        // This ensures data isolation between different users
        
        // Load user-specific local data (if exists)
        loadUserProfileForUser(userId: userId)
        
        guard isOnline else {
            print("⚠️ Offline: Using cached local data")
            return
        }
        
        do {
            if let profile = try await supabaseService.fetchUserProfile(userId: userId) {
                await MainActor.run {
                    // Merge strategy: Keep local data if it exists, merge with Supabase
                    if let localProfile = self.userProfile {
                        // Local data exists - merge intelligently
                        if localProfile.updatedAt > profile.updatedAt {
                            // Local is newer, keep local but sync to Supabase
                            print("📱 Local data is newer, keeping local version")
                            Task {
                                await self.syncToSupabase(profile: localProfile)
                            }
                        } else {
                            // Supabase is newer, merge with local (preserve local changes)
                            var mergedProfile = profile
                            // Preserve local changes that might not be in Supabase
                            mergedProfile.interests = localProfile.interests.isEmpty ? profile.interests : localProfile.interests
                            mergedProfile.strengths = localProfile.strengths.isEmpty ? profile.strengths : localProfile.strengths
                            mergedProfile.values = localProfile.values.isEmpty ? profile.values : localProfile.values
                            
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
            print("⚠️ Failed to load from Supabase: \(error.localizedDescription)")
            // Continue using local data (offline support)
            // Ensure local data is loaded
            loadUserProfile()
        }
    }
    
    /// Sync to Supabase (background, non-blocking)
    func syncToSupabase(profile: UserProfile? = nil) async {
        guard isOnline else {
            print("⚠️ Offline: Data saved locally, will sync when online")
            return
        }
        
        guard let userId = AuthService.shared.currentUser?.id else {
            print("⚠️ Not authenticated, skipping sync")
            return
        }
        
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
            // IMPORTANT: Ensure profile has correct user ID before saving
            try await supabaseService.saveUserProfile(profileToSave)
            await MainActor.run {
                self.lastSyncTime = Date()
                let syncKey = "lifelab_last_sync_time_\(userId)"
                UserDefaults.standard.set(Date(), forKey: syncKey)
                self.isSyncing = false
            }
            print("✅ Successfully synced profile to Supabase for user \(userId)")
        } catch {
            await MainActor.run {
                self.isSyncing = false
            }
            print("❌ Failed to sync to Supabase: \(error.localizedDescription)")
            print("   Error details: \(error)")
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
    private func loadUserProfileForUser(userId: String) {
        let userKey = "lifelab_user_profile_\(userId)"
        if let data = UserDefaults.standard.data(forKey: userKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
            
            // Load sync time
            let syncKey = "lifelab_last_sync_time_\(userId)"
            if let syncTime = UserDefaults.standard.object(forKey: syncKey) as? Date {
                lastSyncTime = syncTime
            }
            
            print("✅ Loaded user profile for user \(userId) from local cache")
        } else {
            print("📱 No local profile found for user \(userId)")
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
