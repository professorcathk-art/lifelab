import Foundation
import Combine

class DataService: ObservableObject {
    static let shared = DataService()
    
    @Published var userProfile: UserProfile?
    
    private let userDefaultsKey = "lifelab_user_profile"
    
    private init() {
        loadUserProfile()
    }
    
    func saveUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveToUserDefaults(profile)
    }
    
    func updateUserProfile(_ update: (inout UserProfile) -> Void) {
        var profile = userProfile ?? UserProfile()
        update(&profile)
        profile.updatedAt = Date()
        saveUserProfile(profile)
    }
    
    private func saveToUserDefaults(_ profile: UserProfile) {
        if let encoded = try? JSONEncoder().encode(profile) {
            UserDefaults.standard.set(encoded, forKey: userDefaultsKey)
        }
    }
    
    private func loadUserProfile() {
        if let data = UserDefaults.standard.data(forKey: userDefaultsKey),
           let profile = try? JSONDecoder().decode(UserProfile.self, from: data) {
            userProfile = profile
        }
    }
    
    func clearUserProfile() {
        userProfile = nil
        UserDefaults.standard.removeObject(forKey: userDefaultsKey)
    }
}
