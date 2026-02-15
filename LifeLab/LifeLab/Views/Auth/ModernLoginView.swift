import SwiftUI
import AuthenticationServices

struct ModernLoginView: View {
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
        ZStack {
            // Modern gradient background
            LinearGradient(
                colors: [
                    Color(hex: "667eea"),
                    Color(hex: "764ba2"),
                    Color(hex: "f093fb")
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: BrandSpacing.xxxl) {
                    // Logo and Title Section
                    VStack(spacing: BrandSpacing.lg) {
                        // Animated logo
                        ZStack {
                            Circle()
                                .fill(.white.opacity(0.2))
                                .frame(width: 120, height: 120)
                            
                            Image(systemName: "sparkles")
                                .font(.system(size: 60))
                                .foregroundStyle(.white)
                        }
                        .shadow(color: .black.opacity(0.2), radius: 20, x: 0, y: 10)
                        
                        VStack(spacing: BrandSpacing.sm) {
                            Text(isSignUp ? "開始您的旅程" : "歡迎回來")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)
                            
                            Text(isSignUp ? "創建帳號以開始探索" : "登錄以繼續您的生命藍圖")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.9))
                                .multilineTextAlignment(.center)
                        }
                    }
                    .padding(.top, BrandSpacing.xxxl)
                    
                    // Form Card
                    VStack(spacing: BrandSpacing.lg) {
                        if isSignUp {
                            ModernTextField(
                                title: "姓名",
                                text: $name,
                                icon: "person.fill",
                                placeholder: "請輸入您的姓名"
                            )
                        }
                        
                        ModernTextField(
                            title: "電子郵件",
                            text: $email,
                            icon: "envelope.fill",
                            placeholder: "your.email@example.com",
                            keyboardType: .emailAddress
                        )
                        
                        ModernSecureField(
                            title: "密碼",
                            text: $password,
                            icon: "lock.fill",
                            placeholder: "請輸入密碼"
                        )
                        
                        if !isSignUp {
                            Button(action: {
                                showForgotPassword = true
                            }) {
                                HStack {
                                    Spacer()
                                    Text("忘記密碼？")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(Color(hex: "667eea"))
                                }
                            }
                            .buttonStyle(.plain)
                        }
                        
                        // Primary Action Button
                        Button(action: {
                            Task {
                                await handleEmailAuth()
                            }
                        }) {
                            HStack(spacing: BrandSpacing.sm) {
                                if isLoading {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        .scaleEffect(0.9)
                                }
                                Text(isSignUp ? "創建帳號" : "登錄")
                                    .font(.system(size: 18, weight: .semibold))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, BrandSpacing.lg)
                            .background(
                                LinearGradient(
                                    colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 8)
                        }
                        .buttonStyle(.plain)
                        .disabled(isLoading || email.isEmpty || password.isEmpty || (isSignUp && name.isEmpty))
                        .scaleEffect(isLoading ? 0.98 : 1.0)
                        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isLoading)
                        
                        // Toggle Sign Up/In
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                isSignUp.toggle()
                                showError = false
                            }
                        }) {
                            HStack(spacing: BrandSpacing.xs) {
                                Text(isSignUp ? "已有帳號？" : "沒有帳號？")
                                    .foregroundColor(.white.opacity(0.8))
                                Text(isSignUp ? "登錄" : "註冊")
                                    .foregroundColor(.white)
                                    .fontWeight(.semibold)
                            }
                            .font(.system(size: 15))
                        }
                        .buttonStyle(.plain)
                        
                        // Divider
                        HStack {
                            Rectangle()
                                .fill(.white.opacity(0.3))
                                .frame(height: 1)
                            Text("或")
                                .foregroundColor(.white.opacity(0.8))
                                .font(.system(size: 14))
                                .padding(.horizontal, BrandSpacing.md)
                            Rectangle()
                                .fill(.white.opacity(0.3))
                                .frame(height: 1)
                        }
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
                        .signInWithAppleButtonStyle(.white)
                        .frame(height: 56)
                        .cornerRadius(16)
                        .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
                    }
                    .padding(BrandSpacing.xl)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(.ultraThinMaterial)
                            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 10)
                    )
                    .padding(.horizontal, BrandSpacing.lg)
                }
                .padding(.bottom, BrandSpacing.xxxl)
            }
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
                    await MainActor.run {
                        errorMessage = error.localizedDescription
                        showError = true
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
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
}

// Modern Text Field Component
struct ModernTextField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    var keyboardType: UIKeyboardType = .default
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .autocapitalization(.none)
                    .autocorrectionDisabled()
                    .foregroundColor(.white)
            }
            .padding(BrandSpacing.md)
            .background(.white.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

// Modern Secure Field Component
struct ModernSecureField: View {
    let title: String
    @Binding var text: String
    let icon: String
    let placeholder: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.9))
            
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundColor(.white.opacity(0.6))
                    .frame(width: 20)
                
                SecureField(placeholder, text: $text)
                    .foregroundColor(.white)
            }
            .padding(BrandSpacing.md)
            .background(.white.opacity(0.15))
            .cornerRadius(12)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(.white.opacity(0.2), lineWidth: 1)
            )
        }
    }
}

#Preview {
    ModernLoginView()
        .environmentObject(AuthService.shared)
}
