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
                            .foregroundColor(BrandColors.invertedText)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, BrandSpacing.md)
                            .background(
                                (isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                                    ? (themeManager.isDarkMode ? Color(hex: "333333") : Color(hex: "E2DDFF")) // Disabled: Dark gray (dark) or Light purple-gray (day)
                                    : (themeManager.isDarkMode ? BrandColors.primaryText : BrandColors.actionAccent) // Enabled: White (dark) or Purple (day)
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
        .alert("錯誤", isPresented: $showError) {
            Button("確定", role: .cancel) { }
        } message: {
            Text(errorMessage)
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
        isLoading = true
        do {
            if isSignUp {
                try await authService.signUpWithEmail(email: email, password: password, name: name)
            } else {
                try await authService.signInWithEmail(email: email, password: password)
            }
        } catch {
            await MainActor.run {
                let nsError = error as NSError
                
                // Check if this is a "user not found" or "invalid credentials" error
                // If so, suggest user to sign up instead
                if nsError.domain == "SupabaseService" {
                    let errorMsg = nsError.localizedDescription
                    if errorMsg.contains("Invalid login credentials") ||
                       errorMsg.contains("User not found") ||
                       errorMsg.contains("Email not confirmed") ||
                       nsError.code == 401 ||
                       nsError.userInfo["shouldShowSignUp"] != nil {
                        // User doesn't exist or account was deleted - suggest sign up
                        errorMessage = "帳號不存在或密碼錯誤。\n\n是否要建立新帳號？"
                        showError = true
                        // Automatically switch to sign up mode
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            isSignUp = true
                        }
                    } else {
                        errorMessage = errorMsg
                        showError = true
                    }
                } else if nsError.domain == NSURLErrorDomain {
                    // Network error
                    let networkErrorMsg = nsError.localizedDescription
                    if nsError.code == NSURLErrorNetworkConnectionLost ||
                       nsError.code == NSURLErrorNotConnectedToInternet ||
                       nsError.code == NSURLErrorTimedOut {
                        errorMessage = "網絡連接失敗。\n\n請檢查：\n1. 設備是否連接到互聯網\n2. 網絡信號是否穩定\n3. 稍後再試"
                    } else {
                        errorMessage = "網絡錯誤：\(networkErrorMsg)"
                    }
                    showError = true
                } else {
                    errorMessage = error.localizedDescription
                    showError = true
                }
                
                isLoading = false
            }
        }
    }
    
    private func handleAppleSignIn(result: Result<ASAuthorization, Error>) {
        Task {
            do {
                switch result {
                case .success(let authorization):
                    try await authService.signInWithApple(authorization: authorization)
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(BrandColors.actionAccent)
                    .font(.system(size: 14))
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(ThemeManager.shared.isDarkMode ? .bold : .medium)
                    .foregroundColor(BrandColors.primaryText)
            }
            
            TextField("", text: $text, prompt: Text(placeholder).foregroundColor(BrandColors.secondaryText))
                .keyboardType(keyboardType)
                .autocapitalization(keyboardType == .emailAddress ? .none : .words)
                .autocorrectionDisabled(keyboardType == .emailAddress)
                .foregroundColor(BrandColors.primaryText)
                .padding(BrandSpacing.md)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(
                            ThemeManager.shared.isDarkMode 
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
    
    var body: some View {
        VStack(alignment: .leading, spacing: BrandSpacing.sm) {
            HStack(spacing: BrandSpacing.sm) {
                Image(systemName: icon)
                    .foregroundColor(BrandColors.actionAccent)
                    .font(.system(size: 14))
                Text(title)
                    .font(BrandTypography.subheadline)
                    .fontWeight(ThemeManager.shared.isDarkMode ? .bold : .medium)
                    .foregroundColor(BrandColors.primaryText)
            }
            
            HStack {
                if isSecure {
                    SecureField("", text: $text, prompt: Text(placeholder).foregroundColor(BrandColors.secondaryText))
                        .foregroundColor(BrandColors.primaryText)
                } else {
                    TextField("", text: $text, prompt: Text(placeholder).foregroundColor(BrandColors.secondaryText))
                        .foregroundColor(BrandColors.primaryText)
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
                        ThemeManager.shared.isDarkMode 
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
