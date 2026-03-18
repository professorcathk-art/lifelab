import SwiftUI

/// Unified OTP Auth view for Register and Forgot Password flows
/// Register: email → OTP → password → complete
/// Forgot: email → OTP → new password → complete
struct OTPAuthView: View {
    @StateObject private var viewModel = OTPAuthViewModel()
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var themeManager: ThemeManager
    @Environment(\.dismiss) private var dismiss
    
    let flowType: OTPAuthViewModel.OTPFlowType
    let initialEmail: String?
    let initialName: String?
    var onUserAlreadyExists: (() -> Void)?
    
    init(flowType: OTPAuthViewModel.OTPFlowType, initialEmail: String? = nil, initialName: String? = nil, onUserAlreadyExists: (() -> Void)? = nil) {
        self.flowType = flowType
        self.initialEmail = initialEmail
        self.initialName = initialName
        self.onUserAlreadyExists = onUserAlreadyExists
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                BrandColors.background
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: BrandSpacing.xxl) {
                        // Header
                        VStack(spacing: BrandSpacing.sm) {
                            Image(systemName: flowType == .register ? "person.badge.plus" : "lock.rotation")
                                .font(.system(size: 50))
                                .foregroundColor(BrandColors.actionAccent)
                            Text(flowType == .register ? "OTP 註冊" : "重設密碼")
                                .font(BrandTypography.largeTitle)
                                .foregroundColor(BrandColors.primaryText)
                            Text(flowType == .register
                                 ? "我們將發送驗證碼到您的電子郵件"
                                 : "我們將發送驗證碼到您的電子郵件以重設密碼")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.secondaryText)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                        }
                        .padding(.top, BrandSpacing.xxl)
                        
                        // Form
                        VStack(spacing: BrandSpacing.lg) {
                            switch viewModel.step {
                            case .enterEmail:
                                enterEmailStep
                            case .enterOTPAndPassword:
                                enterOTPAndPasswordStep
                            }
                        }
                        .padding(.horizontal, ResponsiveLayout.horizontalPadding())
                    }
                    .frame(maxWidth: ResponsiveLayout.maxContentWidth())
                    .frame(maxWidth: .infinity)
                }
            }
            .preferredColorScheme(themeManager.isDarkMode ? .dark : .light)
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(BrandColors.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") {
                        viewModel.reset()
                        dismiss()
                    }
                    .foregroundColor(BrandColors.actionAccent)
                }
            }
            .onAppear {
                viewModel.flowType = flowType
                viewModel.userAlreadyExists = false
                if let ie = initialEmail {
                    viewModel.email = ie
                    viewModel.name = initialName ?? ""
                    viewModel.step = .enterEmail
                    viewModel.errorMessage = nil
                    viewModel.showError = false
                    viewModel.showSuccess = false
                    viewModel.didSucceed = false
                } else {
                    viewModel.reset()
                }
            }
            .onChange(of: viewModel.didSucceed) { succeeded in
                if succeeded { dismiss() }
            }
            .alert("錯誤", isPresented: $viewModel.showError) {
                Button("確定") {
                    if viewModel.userAlreadyExists {
                        onUserAlreadyExists?()
                        dismiss()
                    }
                }
            } message: {
                Text(viewModel.errorMessage ?? "發生錯誤")
            }
            .alert("已發送", isPresented: $viewModel.showSuccess) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("驗證碼已發送到 \(viewModel.email)\n請檢查您的收件箱")
            }
        }
    }
    
    // MARK: - Register OTP / Forgot OTP - Step 1: Enter email
    private var enterEmailStep: some View {
        VStack(spacing: BrandSpacing.lg) {
            if flowType == .register {
                ModernTextField(
                    title: "姓名",
                    icon: "person.fill",
                    text: $viewModel.name,
                    placeholder: "請輸入您的姓名"
                )
            }
            
            ModernTextField(
                title: "電子郵件",
                icon: "envelope.fill",
                text: $viewModel.email,
                placeholder: "example@email.com",
                keyboardType: .emailAddress
            )
            .textInputAutocapitalization(.never)
            .autocorrectionDisabled()
            
            Button(action: {
                Task {
                    if flowType == .register {
                        await viewModel.sendRegisterOTP()
                    } else {
                        await viewModel.sendRecoveryOTP()
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: BrandColors.invertedText))
                            .scaleEffect(0.9)
                    } else {
                        Text("發送驗證碼")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.md)
                .foregroundColor(BrandColors.invertedText)
                .background(BrandColors.actionAccent)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading || viewModel.email.isEmpty)
            .opacity(viewModel.isLoading ? 0.8 : 1)
        }
    }
    
    // MARK: - Register OTP / Forgot OTP - Step 2: Enter OTP + password
    private var enterOTPAndPasswordStep: some View {
        VStack(spacing: BrandSpacing.lg) {
            // Back button - change email (light/dark: uses actionAccent for visibility)
            Button(action: { viewModel.goBackToEmailStep() }) {
                HStack(spacing: BrandSpacing.xs) {
                    Image(systemName: "chevron.left")
                    Text("更改電子郵件")
                        .font(BrandTypography.subheadline)
                }
                .foregroundColor(BrandColors.actionAccent)
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(.bottom, BrandSpacing.sm)
            
            ModernTextField(
                title: "驗證碼",
                icon: "number",
                text: $viewModel.otpCode,
                placeholder: "請輸入 6 位數驗證碼",
                keyboardType: .numberPad
            )
            
            ModernSecureField(
                title: flowType == .register ? "密碼" : "新密碼",
                icon: "lock.fill",
                text: $viewModel.password,
                placeholder: "至少 6 個字符"
            )
            
            ModernSecureField(
                title: "確認密碼",
                icon: "lock.fill",
                text: $viewModel.confirmPassword,
                placeholder: "再次輸入密碼"
            )
            
            Button(action: {
                Task {
                    if flowType == .register {
                        await viewModel.completeRegisterWithOTP()
                    } else {
                        await viewModel.completeRecoveryWithOTP()
                    }
                }
            }) {
                HStack {
                    if viewModel.isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: BrandColors.invertedText))
                            .scaleEffect(0.9)
                    } else {
                        Text(flowType == .register ? "完成註冊" : "重設密碼")
                            .fontWeight(.semibold)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, BrandSpacing.md)
                .foregroundColor(BrandColors.invertedText)
                .background(BrandColors.actionAccent)
                .clipShape(Capsule())
            }
            .buttonStyle(.plain)
            .disabled(viewModel.isLoading || viewModel.otpCode.isEmpty || viewModel.password.isEmpty || viewModel.confirmPassword.isEmpty)
            .opacity(viewModel.isLoading ? 0.8 : 1)
            
            Button("重新發送驗證碼") {
                Task {
                    if flowType == .register {
                        await viewModel.sendRegisterOTP()
                    } else {
                        await viewModel.sendRecoveryOTP()
                    }
                }
            }
            .font(BrandTypography.caption)
            .foregroundColor(BrandColors.actionAccent)
            .disabled(viewModel.isLoading)
            .opacity(viewModel.isLoading ? 0.6 : 1)
        }
    }
}

#Preview("Register OTP") {
    OTPAuthView(flowType: .register)
        .environmentObject(AuthService.shared)
        .environmentObject(ThemeManager.shared)
}

#Preview("Forgot Password OTP") {
    OTPAuthView(flowType: .forgotPassword)
        .environmentObject(AuthService.shared)
        .environmentObject(ThemeManager.shared)
}
