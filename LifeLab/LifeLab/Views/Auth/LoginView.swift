import SwiftUI
import AuthenticationServices

struct LoginView: View {
    @EnvironmentObject var authService: AuthService
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
        VStack(spacing: BrandSpacing.xl) {
            VStack(spacing: BrandSpacing.md) {
                Image(systemName: "person.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(BrandColors.primaryGradient)
                
                Text(isSignUp ? "註冊" : "登錄")
                    .font(BrandTypography.largeTitle)
                    .foregroundColor(BrandColors.primaryText)
                
                Text("請登錄以保存您的數據")
                    .font(BrandTypography.subheadline)
                    .foregroundColor(BrandColors.secondaryText)
            }
            .padding(.top, BrandSpacing.xxxl)
            
            VStack(spacing: BrandSpacing.lg) {
                if isSignUp {
                    TextField("姓名", text: $name)
                        .textFieldStyle(.roundedBorder)
                        .autocapitalization(.words)
                }
                
                TextField("電子郵件", text: $email)
                    .textFieldStyle(.roundedBorder)
                    .keyboardType(.emailAddress)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                
                SecureField("密碼", text: $password)
                    .textFieldStyle(.roundedBorder)
                
                if !isSignUp {
                    Button(action: {
                        showForgotPassword = true
                    }) {
                        HStack {
                            Spacer()
                            Text("忘記密碼？")
                                .font(BrandTypography.caption)
                                .foregroundColor(BrandColors.primaryBlue)
                        }
                    }
                    .buttonStyle(.plain)
                }
                
                Button(action: {
                    Task {
                        await handleEmailAuth()
                    }
                }) {
                    HStack {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .scaleEffect(0.8)
                        }
                        Text(isSignUp ? "註冊" : "登錄")
                    }
                    .font(BrandTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, BrandSpacing.lg)
                    .background(BrandColors.primaryGradient)
                    .cornerRadius(BrandRadius.medium)
                }
                .buttonStyle(.plain)
                .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                
                Button(action: {
                    isSignUp.toggle()
                }) {
                    Text(isSignUp ? "已有帳號？登錄" : "沒有帳號？註冊")
                        .font(BrandTypography.subheadline)
                        .foregroundColor(BrandColors.primaryBlue)
                }
                .buttonStyle(.plain)
                
                Divider()
                    .padding(.vertical, BrandSpacing.md)
                
                // Apple Sign In
                SignInWithAppleButton(
                    onRequest: { request in
                        request.requestedScopes = [.fullName, .email]
                    },
                    onCompletion: { result in
                        handleAppleSignIn(result: result)
                    }
                )
                .signInWithAppleButtonStyle(.black)
                .frame(height: 50)
                .cornerRadius(BrandRadius.medium)
            }
            .padding(.horizontal, BrandSpacing.xl)
            
            Spacer()
        }
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
                errorMessage = error.localizedDescription
                showError = true
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
                            errorMsg = "Apple Sign In 配置错误。\n\n请检查：\n1. Bundle ID 必须与 Apple Developer 中的 App ID 完全一致 (com.resonance.lifelab)\n2. 在 Xcode 的 Signing & Capabilities 中必须启用 'Sign In with Apple'\n3. 确保使用有效的开发证书\n4. 在真实设备上测试（模拟器可能不支持）"
                        case 1001:
                            errorMsg = "用户取消了 Apple Sign In"
                        default:
                            errorMsg = "Apple Sign In 错误 (代码: \(nsError.code)): \(error.localizedDescription)"
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
                    errorMsg = "Apple Sign In 配置错误。\n\n请检查：\n1. Bundle ID 必须与 Apple Developer 中的 App ID 完全一致 (com.resonance.lifelab)\n2. 在 Xcode 的 Signing & Capabilities 中必须启用 'Sign In with Apple'\n3. 确保使用有效的开发证书\n4. 在真实设备上测试（模拟器可能不支持）"
                }
                
                await MainActor.run {
                    errorMessage = errorMsg
                    showError = true
                }
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthService.shared)
}
