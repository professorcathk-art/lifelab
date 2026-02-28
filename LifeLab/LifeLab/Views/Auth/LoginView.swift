import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
    @StateObject private var themeManager = ThemeManager.shared
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUp = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var isLoading = false
    @State private var showForgotPassword = false
    @State private var forgotPasswordEmail = ""
    @State private var isResettingPassword = false
    @State private var showResetSuccess = false
    @State private var hasReadTerms = false
    @State private var showPrivacyPolicy = false
    
    var body: some View {
        ZStack {
            // Theme-aware background
            BrandColors.background
                .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: BrandSpacing.xxxl) {
                    // Theme Toggle Button (Top Right)
                    HStack {
                        Spacer()
                        Button(action: {
                            themeManager.toggleTheme()
                        }) {
                            Image(systemName: themeManager.isDarkMode ? "sun.max.fill" : "moon.fill")
                                .font(.title3)
                                .foregroundColor(BrandColors.actionAccent)
                                .padding(BrandSpacing.md)
                                .background(BrandColors.surface)
                                .cornerRadius(BrandRadius.medium)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.horizontal, BrandSpacing.xl)
                    .padding(.top, BrandSpacing.lg)
                    
                    // Hero Section - Welcome Block
                    VStack(spacing: BrandSpacing.lg) {
                        // Icon - Brand icon (Ikigai intersection or door)
                        ZStack {
                            if themeManager.isDarkMode {
                                // Dark mode: Use abstract geometric shape
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [BrandColors.actionAccent.opacity(0.3), BrandColors.brandAccent.opacity(0.2)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50))
                                    .foregroundColor(BrandColors.actionAccent)
                            } else {
                                // Day mode: Soft purple-gold gradient icon
                                Circle()
                                    .fill(
                                        LinearGradient(
                                            colors: [Color(hex: "6B4EFF").opacity(0.2), Color(hex: "F5A623").opacity(0.15)],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .frame(width: 100, height: 100)
                                
                                Image(systemName: "sparkles")
                                    .font(.system(size: 50))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "6B4EFF"), Color(hex: "F5A623")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                            }
                        }
                        .padding(.top, BrandSpacing.lg)
                        
                        VStack(spacing: BrandSpacing.sm) {
                            Text(isSignUp ? "建立帳號" : "歡迎回來，探索者")
                                .font(themeManager.isDarkMode ? BrandTypography.largeTitle : Font.title2.bold())
                                .foregroundColor(BrandColors.primaryText)
                            
                            Text(isSignUp ? "開始您的生命藍圖之旅" : "你的專屬人生藍圖正在等你，讓我們繼續這趟旅程。")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .lineSpacing(4)
                                .padding(.horizontal, BrandSpacing.lg)
                        }
                    }
                    
                    // Form Section
                    VStack(spacing: BrandSpacing.lg) {
                        // Name field (only for sign up)
                        if isSignUp {
                            ModernTextField(
                                title: "姓名",
                                icon: "person.fill",
                                text: $name,
                                placeholder: "請輸入您的姓名"
                            )
                            .transition(.move(edge: .top).combined(with: .opacity))
                        }
                        
                        // Email field
                        ModernTextField(
                            title: "電子郵件",
                            icon: "envelope.fill",
                            text: $email,
                            placeholder: "example@email.com",
                            keyboardType: .emailAddress
                        )
                        
                        // Password field
                        ModernSecureField(
                            title: "密碼",
                            icon: "lock.fill",
                            text: $password,
                            placeholder: "請輸入密碼"
                        )
                        
                        // Forgot password (only for sign in)
                        if !isSignUp {
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text("忘記密碼？")
                                        .font(BrandTypography.subheadline)
                                        .foregroundColor(BrandColors.actionAccent)
                                }
                            }
                        .buttonStyle(.plain)
                        .padding(.top, -BrandSpacing.sm)
                        }
                        
                        // AI Service Consent Checkbox
                        AIConsentCheckbox(
                            hasReadTerms: $hasReadTerms,
                            showPrivacyPolicy: $showPrivacyPolicy
                        )
                        .padding(.horizontal, BrandSpacing.xl)
                        .padding(.top, BrandSpacing.md)
                        
                        // Submit button - CTA Button
                        Button(action: {
                            Task {
                                await handleEmailAuth()
                            }
                        }) {
                            HStack(spacing: BrandSpacing.sm) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(
                                            tint: themeManager.isDarkMode ? BrandColors.invertedText : BrandColors.invertedText
                                        ))
                                        .scaleEffect(0.9)
                                }
                                Text(isSignUp ? "註冊" : "進入我的藍圖")
                                    .font(BrandTypography.headline)
                                    .fontWeight(.bold)
                                if !isLoading {
                                    Image(systemName: "arrow.right")
                                        .font(.system(size: 16, weight: .bold))
                                }
                            }
                            .foregroundColor(
                                // CRITICAL: Ensure proper contrast in both modes
                                // Dark mode: White background → Black text
                                // Light mode: Purple background → White text
                                (isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty) || !hasReadTerms)
                                    ? (themeManager.isDarkMode ? Color(hex: "9CA3AF") : Color(hex: "8E8E93")) // Disabled: Muted gray text
                                    : (themeManager.isDarkMode ? Color.black : Color.white) // Enabled: Black (dark) or White (light)
                            )
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, BrandSpacing.md)
                            .background(
                                (isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty) || !hasReadTerms)
                                    ? (themeManager.isDarkMode ? Color(hex: "333333") : Color(hex: "E2DDFF")) // Disabled: Dark gray (dark) or Light purple-gray (day)
                                    : (themeManager.isDarkMode ? Color.white : BrandColors.actionAccent) // Enabled: White (dark) or Purple (day)
                            )
                            .clipShape(Capsule())
                            .shadow(
                                color: (isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty)) 
                                    ? Color.clear 
                                    : BrandColors.buttonShadow.color,
                                radius: BrandColors.buttonShadow.radius,
                                x: BrandColors.buttonShadow.x,
                                y: BrandColors.buttonShadow.y
                            )
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                        .padding(.horizontal, BrandSpacing.xl)
                        
                        // Toggle sign up/sign in
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSignUp.toggle()
                            }
                        }) {
                            HStack(spacing: BrandSpacing.xs) {
                                Text(isSignUp ? "已有帳號？" : "沒有帳號？")
                                    .foregroundColor(BrandColors.secondaryText)
                                Text(isSignUp ? "登錄" : "註冊")
                                    .foregroundColor(BrandColors.actionAccent)
                                    .fontWeight(.semibold)
                            }
                            .font(BrandTypography.body)
                        }
                        .buttonStyle(.plain)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(BrandColors.borderColor)
                                .frame(height: 1)
                            Text("或")
                                .font(BrandTypography.footnote)
                                .foregroundColor(BrandColors.secondaryText)
                                .padding(.horizontal, BrandSpacing.md)
                            Rectangle()
                                .fill(BrandColors.borderColor)
                                .frame(height: 1)
                        }
                        .padding(.vertical, BrandSpacing.md)
                        
                        // Apple Sign In Button
                        SignInWithAppleButton(
                            onRequest: { request in
                                request.requestedScopes = [.fullName, .email]
                            },
                            onCompletion: { result in
                                handleAppleSignIn(result: result)
                            }
                        )
                        .signInWithAppleButtonStyle(themeManager.isDarkMode ? .white : .white)
                        .frame(height: 56)
                        .clipShape(RoundedRectangle(cornerRadius: BrandRadius.medium))
                        .overlay(
                            RoundedRectangle(cornerRadius: BrandRadius.medium)
                                .stroke(
                                    themeManager.isDarkMode ? Color.clear : BrandColors.borderColor,
                                    lineWidth: themeManager.isDarkMode ? 0 : 1
                                )
                        )
                        .shadow(
                            color: themeManager.isDarkMode ? Color.clear : BrandColors.cardShadow.color,
                            radius: themeManager.isDarkMode ? 0 : BrandColors.cardShadow.radius,
                            x: themeManager.isDarkMode ? 0 : BrandColors.cardShadow.x,
                            y: themeManager.isDarkMode ? 0 : BrandColors.cardShadow.y
                        )
                        .padding(.horizontal, BrandSpacing.xl)
                    }
                    .padding(.bottom, BrandSpacing.xxxl)
                }
            }
        }
        .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
        .alert("", isPresented: $showError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(errorMessage)
                .font(BrandTypography.body)
        }
        .alert("忘記密碼", isPresented: $showForgotPassword) {
            TextField("電子郵件", text: $forgotPasswordEmail)
                .keyboardType(.emailAddress)
                .autocapitalization(.none)
            
            Button("取消", role: .cancel) {
                forgotPasswordEmail = ""
            }
            Button("發送重置連結") {
                Task {
                    await handleForgotPassword()
                }
            }
            .disabled(forgotPasswordEmail.isEmpty || isResettingPassword)
        } message: {
            Text("請輸入您的電子郵件地址，我們將發送密碼重置連結給您。")
        }
        .alert("重置連結已發送", isPresented: $showResetSuccess) {
            Button("確定", role: .cancel) {
                forgotPasswordEmail = ""
            }
        } message: {
            Text("密碼重置連結已發送到您的電子郵件。請檢查您的收件箱。")
        }
        .sheet(isPresented: $showPrivacyPolicy) {
            PrivacyPolicyView()
        }
    }
    
    private func handleForgotPassword() async {
        guard !forgotPasswordEmail.isEmpty else { return }
        
        isResettingPassword = true
        do {
            try await authService.resetPassword(email: forgotPasswordEmail)
            await MainActor.run {
                isResettingPassword = false
                showForgotPassword = false
                showResetSuccess = true
            }
        } catch {
            await MainActor.run {
                isResettingPassword = false
                errorMessage = "無法發送重置連結：\(error.localizedDescription)"
                showError = true
            }
        }
    }
    
    private func handleEmailAuth() async {
        // CRITICAL: Save AI consent before authentication
        guard hasReadTerms else {
            await MainActor.run {
                errorMessage = "請先閱讀並同意 AI 服務使用條款"
                showError = true
            }
            return
        }
        
        // Save consent to UserDefaults (user-specific, will be set after login)
        if let userId = authService.currentUser?.id {
            let consentKey = "lifelab_ai_consent_\(userId)"
            UserDefaults.standard.set(true, forKey: consentKey)
        } else {
            // For new users, save with temporary key, will update after login
            UserDefaults.standard.set(true, forKey: "lifelab_ai_consent_pending")
        }
        
        isLoading = true
        do {
            if isSignUp {
                try await authService.signUpWithEmail(email: email, password: password, name: name)
                // After successful signup, save consent with actual user ID
                if let userId = authService.currentUser?.id {
                    let consentKey = "lifelab_ai_consent_\(userId)"
                    UserDefaults.standard.set(true, forKey: consentKey)
                    UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent_pending")
                }
            } else {
                try await authService.signInWithEmail(email: email, password: password)
                // After successful signin, save consent with actual user ID
                if let userId = authService.currentUser?.id {
                    let consentKey = "lifelab_ai_consent_\(userId)"
                    UserDefaults.standard.set(true, forKey: consentKey)
                    UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent_pending")
                }
            }
        } catch {
            await MainActor.run {
                let nsError = error as NSError
                
                // Professional error message handling
                if nsError.domain == "SupabaseService" {
                    let errorMsg = nsError.localizedDescription.lowercased()
                    let statusCode = nsError.code
                    
                    if isSignUp {
                        // Sign up errors
                        if nsError.userInfo["userAlreadyExists"] != nil ||
                           errorMsg.contains("user already registered") ||
                           errorMsg.contains("email already exists") ||
                           errorMsg.contains("already registered") ||
                           statusCode == 422 {
                            // User already exists - suggest sign in
                            errorMessage = "此電子郵件地址已被註冊。\n\n請使用「登錄」功能登入您的帳號，或使用其他電子郵件地址註冊。"
                            showError = true
                            // Automatically switch to sign in mode
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSignUp = false
                            }
                        } else if errorMsg.contains("password") && errorMsg.contains("weak") {
                            errorMessage = "密碼強度不足。\n\n請使用至少 6 個字符的密碼，建議包含字母和數字。"
                            showError = true
                        } else if errorMsg.contains("email") && errorMsg.contains("invalid") {
                            errorMessage = "電子郵件格式不正確。\n\n請檢查您輸入的電子郵件地址是否正確。"
                            showError = true
                        } else {
                            // Generic sign up error
                            errorMessage = "註冊失敗。\n\n\(nsError.localizedDescription)\n\n請稍後再試，或聯繫客服尋求協助。"
                            showError = true
                        }
                    } else {
                        // Sign in errors
                        if errorMsg.contains("invalid login credentials") ||
                           errorMsg.contains("user not found") ||
                           errorMsg.contains("email not confirmed") ||
                           statusCode == 401 ||
                           nsError.userInfo["shouldShowSignUp"] != nil {
                            // Wrong password or user doesn't exist
                            errorMessage = "電子郵件或密碼不正確。\n\n請檢查：\n• 電子郵件地址是否正確\n• 密碼是否正確（注意大小寫）\n• 是否已註冊帳號\n\n如果忘記密碼，請使用「忘記密碼？」功能。"
                            showError = true
                        } else {
                            // Generic sign in error
                            errorMessage = "登錄失敗。\n\n\(nsError.localizedDescription)\n\n請稍後再試，或聯繫客服尋求協助。"
                            showError = true
                        }
                    }
                } else if nsError.domain == NSURLErrorDomain {
                    // Network error - professional message
                    let networkErrorMsg = nsError.localizedDescription
                    if nsError.code == NSURLErrorNetworkConnectionLost ||
                       nsError.code == NSURLErrorNotConnectedToInternet ||
                       nsError.code == NSURLErrorTimedOut {
                        errorMessage = "無法連接到網絡。\n\n請檢查：\n• 設備是否已連接到 Wi‑Fi 或行動網絡\n• 網絡信號是否穩定\n• 是否開啟了飛行模式\n\n確認後請稍後再試。"
                    } else {
                        errorMessage = "網絡連接出現問題。\n\n\(networkErrorMsg)\n\n請檢查您的網絡連接後再試。"
                    }
                    showError = true
                } else {
                    // Generic error - professional message
                    errorMessage = "發生錯誤。\n\n\(error.localizedDescription)\n\n請稍後再試，如問題持續存在，請聯繫客服。"
                    showError = true
                }
                
                isLoading = false
            }
        }
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        // CRITICAL: Check consent before Apple Sign In
        guard hasReadTerms else {
            errorMessage = "請先閱讀並同意 AI 服務使用條款"
            showError = true
            return
        }
        
        // Save consent (will update with user ID after login)
        UserDefaults.standard.set(true, forKey: "lifelab_ai_consent_pending")
        
        Task {
            do {
                switch result {
                case .success(let authorization):
                    try await authService.signInWithApple(authorization: authorization)
                    // After successful signin, save consent with actual user ID
                    if let userId = authService.currentUser?.id {
                        let consentKey = "lifelab_ai_consent_\(userId)"
                        UserDefaults.standard.set(true, forKey: consentKey)
                        UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent_pending")
                    }
                case .failure(let error):
                    let nsError = error as NSError
                    var errorMsg = error.localizedDescription
                    
                    // Enhanced error messages for Apple Sign In
                    if nsError.domain == "ASAuthenticationServices" {
                        switch nsError.code {
                        case 1000:
                            errorMsg = "Apple Sign In 配置錯誤。\n\n請檢查：\n1. Bundle ID 必須與 Apple Developer 中的 App ID 完全一致 (com.resonance.lifelab)\n2. 在 Xcode 的 Signing & Capabilities 中必須啟用 'Sign In with Apple'\n3. 確保使用有效的開發證書\n4. 在真實設備上測試（模擬器可能不支持）"
                        case 1001:
                            errorMsg = "用戶取消了 Apple Sign In"
                        default:
                            errorMsg = "Apple Sign In 錯誤 (代碼: \(nsError.code)): \(error.localizedDescription)"
                        }
                    }
                    
                    await MainActor.run {
                        errorMessage = errorMsg
                        showError = true
                    }
                }
            } catch {
                let nsError = error as NSError
                var errorMsg = error.localizedDescription
                
                // Enhanced error messages
                if nsError.domain == "ASAuthenticationServices" && nsError.code == 1000 {
                    errorMsg = "Apple Sign In 配置錯誤。\n\n請檢查：\n1. Bundle ID 必須與 Apple Developer 中的 App ID 完全一致 (com.resonance.lifelab)\n2. 在 Xcode 的 Signing & Capabilities 中必須啟用 'Sign In with Apple'\n3. 確保使用有效的開發證書\n4. 在真實設備上測試（模擬器可能不支持）"
                }
                
                await MainActor.run {
                    errorMessage = errorMsg
                    showError = true
                }
            }
        }
    }
}

// Modern Text Field Component - Theme-Aware (Daylight Healing Soft-Minimalist)
struct ModernTextField: View {
    let title: String
    let icon: String
    @Binding var text: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    // CRITICAL: Observe theme changes to ensure proper updates
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(BrandColors.actionAccent)
                    .font(.system(size: 14))
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(themeManager.isDarkMode ? .bold : .medium)
                    .foregroundColor(
                        // CRITICAL: Use explicit theme-aware color to ensure proper contrast
                        // Dark mode: White text
                        // Light mode: Dark charcoal text
                        themeManager.isDarkMode ? Color.white : Color(hex: "2C2C2E")
                    )
            }
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(BrandColors.secondaryText))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .autocorrectionDisabled(keyboardType == .emailAddress)
                .foregroundColor(
                    // CRITICAL: Use explicit theme-aware color
                    themeManager.isDarkMode ? Color.white : Color(hex: "2C2C2E")
                )
                .padding(BrandSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            themeManager.isDarkMode 
                                ? BrandColors.surface // Dark charcoal in dark mode
                                : BrandColors.dayModeInputBackground // Very light gray #F0F0F5 in day mode
                        )
                )
                // NO stroke/border in day mode per design requirements
        }
        .padding(.horizontal, BrandSpacing.xl)
    }
}

// Modern Secure Field Component - Theme-Aware (Daylight Healing Soft-Minimalist)
struct ModernSecureField: View {
    let title: String
    let icon: String
    @Binding var text: String
    let placeholder: String
    @State private var isSecure = true
    
    // CRITICAL: Observe theme changes to ensure proper updates
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(BrandColors.actionAccent)
                    .font(.system(size: 14))
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(themeManager.isDarkMode ? .bold : .medium)
                    .foregroundColor(
                        // CRITICAL: Use explicit theme-aware color to ensure proper contrast
                        // Dark mode: White text
                        // Light mode: Dark charcoal text
                        themeManager.isDarkMode ? Color.white : Color(hex: "2C2C2E")
                    )
            }
            
            HStack {
                if isSecure {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(BrandColors.secondaryText))
                        .foregroundColor(
                            // CRITICAL: Use explicit theme-aware color
                            themeManager.isDarkMode ? Color.white : Color(hex: "2C2C2E")
                        )
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(BrandColors.secondaryText))
                        .foregroundColor(
                            // CRITICAL: Use explicit theme-aware color
                            themeManager.isDarkMode ? Color.white : Color(hex: "2C2C2E")
                        )
                }
                
                Button(action: {
                    withAnimation(.spring(response: 0.2)) {
                        isSecure.toggle()
                    }
                }) {
                    Image(systemName: isSecure ? "eye.slash.fill" : "eye.fill")
                        .foregroundColor(BrandColors.secondaryText)
                        .font(.system(size: 14))
                }
                .buttonStyle(.plain)
            }
            .padding(BrandSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(
                        themeManager.isDarkMode 
                            ? BrandColors.surface // Dark charcoal in dark mode
                            : BrandColors.dayModeInputBackground // Very light gray #F0F0F5 in day mode
                    )
            )
            // NO stroke/border in day mode per design requirements
        }
        .padding(.horizontal, BrandSpacing.xl)
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService.shared)
}
