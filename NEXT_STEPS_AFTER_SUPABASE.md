# Supabase 部署完成后的下一步

## ✅ 已完成

- [x] Supabase 项目已创建
- [x] 数据库表已创建（user_profiles, user_subscriptions）
- [x] Apple Sign In 已配置
- [x] JWT Secret Key 已生成
- [x] Bundle ID 已更新为 `com.resonance.lifelab`

---

## 🔧 需要完成的集成工作

### 1. 更新 AuthService 以使用 Supabase

**当前状态**: `AuthService` 使用 mock 实现  
**需要**: 连接到 `SupabaseService` 进行真实认证

**文件**: `LifeLab/LifeLab/Services/AuthService.swift`

**需要更新的方法**:
- `signInWithEmail` - 使用 `SupabaseService.signIn`
- `signUpWithEmail` - 使用 `SupabaseService.signUp`
- `signInWithApple` - 使用 `SupabaseService.signInWithOAuth`
- `signOut` - 使用 `SupabaseService.signOut`

---

### 2. 更新 DataService 以同步到 Supabase

**当前状态**: `DataService` 只使用 UserDefaults（本地存储）  
**需要**: 同步数据到 Supabase 数据库

**文件**: `LifeLab/LifeLab/Services/DataService.swift`

**需要添加的功能**:
- 登录后自动从 Supabase 加载用户数据
- 保存数据时同步到 Supabase
- 处理离线/在线状态

---

### 3. 测试 Apple Sign In

**步骤**:
1. 在真实设备上测试（iPhone）
2. 验证登录流程
3. 验证数据同步

---

## 📋 详细步骤

### Step 1: 更新 AuthService

#### 1.1 更新 `signInWithEmail`

```swift
func signInWithEmail(email: String, password: String) async throws {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let response = try await SupabaseService.shared.signIn(
            email: email,
            password: password
        )
        
        guard let user = response.user else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])
        }
        
        let authUser = User(
            id: user.id,
            email: user.email,
            name: user.userMetadata?["name"],
            authProvider: .email
        )
        
        await MainActor.run {
            self.currentUser = authUser
            self.isAuthenticated = true
            saveUser(authUser)
        }
        
        // Load user profile from Supabase
        await loadUserProfileFromSupabase(userId: user.id)
    } catch {
        print("❌ Sign in error: \(error)")
        throw error
    }
}
```

#### 1.2 更新 `signUpWithEmail`

```swift
func signUpWithEmail(email: String, password: String, name: String) async throws {
    isLoading = true
    defer { isLoading = false }
    
    do {
        let response = try await SupabaseService.shared.signUp(
            email: email,
            password: password,
            name: name
        )
        
        guard let user = response.user else {
            throw NSError(domain: "AuthService", code: -1, userInfo: [NSLocalizedDescriptionKey: "No user returned"])
        }
        
        let authUser = User(
            id: user.id,
            email: user.email,
            name: name,
            authProvider: .email
        )
        
        await MainActor.run {
            self.currentUser = authUser
            self.isAuthenticated = true
            saveUser(authUser)
        }
        
        // Create user profile in Supabase
        await createUserProfileInSupabase(userId: user.id)
    } catch {
        print("❌ Sign up error: \(error)")
        throw error
    }
}
```

#### 1.3 更新 `signInWithApple`

需要处理 Apple Sign In 的 OAuth flow，获取 identity token 后调用 Supabase。

---

### Step 2: 更新 DataService

#### 2.1 添加 Supabase 同步方法

```swift
func syncToSupabase() async {
    guard let profile = userProfile,
          let userId = AuthService.shared.currentUser?.id else {
        return
    }
    
    do {
        try await SupabaseService.shared.saveUserProfile(profile)
        print("✅ Profile synced to Supabase")
    } catch {
        print("❌ Failed to sync profile: \(error)")
    }
}

func loadFromSupabase() async {
    guard let userId = AuthService.shared.currentUser?.id else {
        return
    }
    
    do {
        if let profile = try await SupabaseService.shared.fetchUserProfile(userId: userId) {
            await MainActor.run {
                self.userProfile = profile
                saveToUserDefaults(profile)
            }
            print("✅ Profile loaded from Supabase")
        }
    } catch {
        print("❌ Failed to load profile: \(error)")
    }
}
```

#### 2.2 更新 `saveUserProfile` 以自动同步

```swift
func saveUserProfile(_ profile: UserProfile) {
    userProfile = profile
    saveToUserDefaults(profile)
    
    // Sync to Supabase if authenticated
    if AuthService.shared.isAuthenticated {
        Task {
            await syncToSupabase()
        }
    }
}
```

---

### Step 3: 测试流程

1. **测试 Email 登录**:
   - 注册新账户
   - 登录
   - 验证数据保存到 Supabase

2. **测试 Apple Sign In**:
   - 点击 Apple Sign In 按钮
   - 完成 Apple 认证
   - 验证数据同步

3. **测试数据同步**:
   - 创建/更新生命藍圖
   - 验证数据保存到 Supabase
   - 登出后重新登录
   - 验证数据恢复

---

## 🧪 测试清单

### 认证测试
- [ ] Email 注册功能正常
- [ ] Email 登录功能正常
- [ ] Apple Sign In 功能正常
- [ ] 登出功能正常
- [ ] 会话持久化正常

### 数据同步测试
- [ ] 用户数据保存到 Supabase
- [ ] 用户数据从 Supabase 加载
- [ ] 离线数据本地保存
- [ ] 在线时自动同步

### 功能测试
- [ ] 创建生命藍圖后数据同步
- [ ] 编辑生命藍圖后数据同步
- [ ] 多设备数据同步（如果测试）

---

## 🚀 快速开始

### 选项 1: 我可以帮您更新代码

告诉我您想先完成哪个部分：
1. 更新 AuthService（Email + Apple Sign In）
2. 更新 DataService（数据同步）
3. 两者都更新

### 选项 2: 先测试当前功能

即使代码还没完全集成，您也可以：
1. 测试应用的基本功能
2. 验证 UI 和用户体验
3. 检查是否有 bug

---

## 📝 注意事项

1. **Apple Sign In 测试**:
   - 必须在真实设备上测试（iPhone）
   - 模拟器不支持 Apple Sign In

2. **数据同步**:
   - 建议先实现基本同步
   - 后续可以添加冲突处理、离线支持等

3. **错误处理**:
   - 确保网络错误时应用不会崩溃
   - 提供用户友好的错误提示

---

## 🎯 建议的优先级

1. **高优先级**:
   - ✅ 更新 AuthService 使用 Supabase
   - ✅ 更新 DataService 同步数据

2. **中优先级**:
   - ⚠️ 添加错误处理和重试逻辑
   - ⚠️ 添加加载状态指示器

3. **低优先级**:
   - 📝 优化数据同步性能
   - 📝 添加离线支持

---

## ❓ 需要帮助？

告诉我您想：
1. **立即开始集成** - 我可以帮您更新代码
2. **先测试当前功能** - 验证基本功能是否正常
3. **了解具体实现细节** - 我可以详细解释每个步骤
