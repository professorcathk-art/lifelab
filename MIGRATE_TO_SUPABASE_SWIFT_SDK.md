# 遷移到官方 Supabase Swift SDK 指南

## 🔍 問題診斷

**當前狀況：**
- ❌ 使用自定義 URLSession 實現（`SupabaseService.swift`）
- ❌ 數據沒有同步到 Supabase
- ✅ 用戶已登錄但數據未上傳

**根本原因：**
自定義實現可能有 bug 或認證處理不正確，導致數據無法同步。

**解決方案：**
使用官方的 `supabase-swift` SDK，這是 Supabase 官方維護的、經過測試的 Swift 客戶端庫。

---

## 📦 步驟 1: 添加 Supabase Swift SDK 依賴

### 在 Xcode 中添加 Package：

1. **打開 Xcode 專案**
2. **選擇專案** → **LifeLab** target
3. **進入 "Package Dependencies" 標籤**
4. **點擊 "+" 按鈕**
5. **輸入 Package URL**：
   ```
   https://github.com/supabase-community/supabase-swift.git
   ```
6. **選擇版本**：選擇 "Up to Next Major Version" 並輸入 `2.0.0` 或最新版本
7. **點擊 "Add Package"**
8. **選擇模組**：確保選擇 `Supabase` 模組
9. **點擊 "Add Package"**

### 或者使用命令行（如果使用 Swift Package Manager）：

在專案根目錄創建或更新 `Package.swift`：

```swift
// swift-tools-version:5.9
import PackageDescription

let package = Package(
    name: "LifeLab",
    dependencies: [
        .package(url: "https://github.com/supabase-community/supabase-swift.git", from: "2.0.0")
    ],
    targets: [
        .target(
            name: "LifeLab",
            dependencies: [
                .product(name: "Supabase", package: "supabase-swift")
            ]
        )
    ]
)
```

---

## 🔧 步驟 2: 創建新的 SupabaseService（使用官方 SDK）

創建新文件 `LifeLab/LifeLab/Services/SupabaseServiceV2.swift`：

```swift
import Foundation
import Supabase

class SupabaseServiceV2: ObservableObject {
    static let shared = SupabaseServiceV2()
    
    let client: SupabaseClient
    
    private init() {
        let url = SupabaseConfig.projectURL
        let anonKey = SupabaseConfig.anonKey
        
        guard !url.isEmpty, !anonKey.isEmpty,
              let supabaseURL = URL(string: url) else {
            fatalError("❌ Invalid Supabase configuration")
        }
        
        self.client = SupabaseClient(
            supabaseURL: supabaseURL,
            supabaseKey: anonKey
        )
        
        print("✅ Supabase client initialized")
    }
    
    // MARK: - Authentication
    
    func signUp(email: String, password: String, name: String?) async throws -> AuthResponse {
        let response = try await client.auth.signUp(
            email: email,
            password: password,
            data: name != nil ? ["name": .string(name!)] : [:]
        )
        
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
        let response = try await client.auth.signIn(
            email: email,
            password: password
        )
        
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
                name: nil
            )
        )
    }
    
    func signOut() async throws {
        try await client.auth.signOut()
    }
    
    func getCurrentUser() async throws -> AuthUser? {
        let user = try await client.auth.user
        
        return AuthUser(
            id: user.id.uuidString,
            email: user.email,
            name: user.userMetadata?["name"] as? String
        )
    }
    
    // MARK: - User Profile
    
    func fetchUserProfile(userId: String) async throws -> UserProfile? {
        let response: [UserProfileRow] = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        guard let row = response.first else {
            return nil
        }
        
        return try decodeUserProfile(from: row)
    }
    
    func saveUserProfile(_ profile: UserProfile) async throws {
        guard let userId = AuthService.shared.currentUser?.id else {
            throw NSError(
                domain: "SupabaseService",
                code: -10,
                userInfo: [NSLocalizedDescriptionKey: "Not authenticated"]
            )
        }
        
        let row = try encodeUserProfile(profile, userId: userId)
        
        // Check if exists
        let existing: [UserProfileRow] = try await client
            .from("user_profiles")
            .select()
            .eq("id", value: userId)
            .execute()
            .value
        
        if existing.isEmpty {
            // Insert
            try await client
                .from("user_profiles")
                .insert(row)
                .execute()
            print("✅ Profile created in Supabase")
        } else {
            // Update
            try await client
                .from("user_profiles")
                .update(row)
                .eq("id", value: userId)
                .execute()
            print("✅ Profile updated in Supabase")
        }
    }
    
    // MARK: - Private Helpers
    
    private struct UserProfileRow: Codable {
        let id: String
        let basicInfo: [String: AnyCodable]?
        let interests: [String]?
        let strengths: [[String: AnyCodable]]?
        let values: [[String: AnyCodable]]?
        let flowDiaryEntries: [[String: AnyCodable]]?
        let valuesQuestions: [String: AnyCodable]?
        let resourceInventory: [String: AnyCodable]?
        let acquiredStrengths: [String: AnyCodable]?
        let feasibilityAssessment: [String: AnyCodable]?
        let lifeBlueprint: [String: AnyCodable]?
        let lifeBlueprints: [[String: AnyCodable]]?
        let actionPlan: [String: AnyCodable]?
        let lastBlueprintGenerationTime: String?
    }
    
    private func encodeUserProfile(_ profile: UserProfile, userId: String) throws -> [String: AnyCodable] {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.keyEncodingStrategy = .convertToSnakeCase
        
        let jsonData = try encoder.encode(profile)
        guard let dict = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            throw NSError(domain: "SupabaseService", code: -5, userInfo: [NSLocalizedDescriptionKey: "Failed to encode UserProfile"])
        }
        
        var row: [String: AnyCodable] = [
            "id": .string(userId)
        ]
        
        // Convert each field to AnyCodable
        if let basicInfo = dict["basic_info"] {
            row["basic_info"] = try AnyCodable.from(basicInfo)
        }
        if let interests = dict["interests"] as? [String] {
            row["interests"] = .array(interests.map { .string($0) })
        }
        // ... 其他字段類似處理
        
        return row
    }
    
    private func decodeUserProfile(from row: UserProfileRow) throws -> UserProfile {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        // Convert row back to UserProfile
        // 這裡需要將 AnyCodable 轉換回具體類型
        // ...
        
        // 簡化版本：直接從 JSON 解碼
        let jsonData = try JSONSerialization.data(withJSONObject: row)
        return try decoder.decode(UserProfile.self, from: jsonData)
    }
}
```

---

## 🔄 步驟 3: 更新 DataService 使用新 SDK

更新 `DataService.swift` 中的 `syncToSupabase` 方法：

```swift
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
    
    await MainActor.run {
        self.isSyncing = true
    }
    
    do {
        print("💾 Starting sync to Supabase using official SDK...")
        try await SupabaseServiceV2.shared.saveUserProfile(profileToSave)
        
        await MainActor.run {
            self.lastSyncTime = Date()
            self.isSyncing = false
        }
        print("✅✅✅ SYNC SUCCESSFUL ✅✅✅")
    } catch {
        await MainActor.run {
            self.isSyncing = false
        }
        print("❌ Failed to sync: \(error.localizedDescription)")
    }
}
```

---

## 🧪 步驟 4: 測試數據同步

1. **登錄用戶**
2. **填寫基本資料**
3. **檢查控制台日誌**：
   - 應該看到 `✅ Profile created in Supabase` 或 `✅ Profile updated in Supabase`
4. **在 Supabase Dashboard 中驗證**：
   - Table Editor → user_profiles
   - 應該看到數據

---

## 📝 注意事項

1. **認證 Token 管理**：
   - 官方 SDK 會自動管理 token
   - 不需要手動保存到 UserDefaults

2. **錯誤處理**：
   - 官方 SDK 提供更好的錯誤信息
   - 更容易調試問題

3. **性能**：
   - 官方 SDK 經過優化
   - 更好的網絡錯誤處理和重試邏輯

---

## 🚀 遷移檢查清單

- [ ] 添加 supabase-swift 依賴到 Xcode 專案
- [ ] 創建新的 SupabaseServiceV2 使用官方 SDK
- [ ] 更新 DataService 使用新服務
- [ ] 測試登錄功能
- [ ] 測試數據同步功能
- [ ] 在 Supabase Dashboard 中驗證數據
- [ ] 移除舊的 SupabaseService.swift（備份後）

---

## 📚 參考文檔

- [Supabase Swift SDK 文檔](https://supabase.com/docs/reference/swift/introduction)
- [GitHub Repository](https://github.com/supabase-community/supabase-swift)
- [Swift Package Manager 指南](https://swift.org/package-manager/)
