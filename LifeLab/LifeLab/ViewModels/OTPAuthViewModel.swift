import Foundation
import SwiftUI
import Combine

/// ViewModel for email OTP flows: Register and Forgot Password
/// Uses Supabase signInWithOTP, verifyOTP, resetPasswordForEmail, updateUser
@MainActor
class OTPAuthViewModel: ObservableObject {
    @Published var email = ""
    @Published var otpCode = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var name = ""
    
    @Published var step: OTPStep = .enterEmail
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    /// Set to true when registration/recovery completes successfully; view should dismiss
    @Published var didSucceed = false
    
    @Published var flowType: OTPFlowType = .register
    
    enum OTPStep {
        case enterEmail
        case enterOTPAndPassword
    }
    
    enum OTPFlowType {
        case register
        case forgotPassword
    }
    
    private let supabaseService = SupabaseServiceV2.shared
    
    var isRegisterFlow: Bool { flowType == .register }
    
    // MARK: - Register OTP Flow
    
    /// Register - Step 1: Send OTP to email
    func sendRegisterOTP() async {
        guard isValidEmail(email) else {
            errorMessage = "請輸入有效的電子郵件地址"
            showError = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await supabaseService.sendSignUpOTP(email: email, name: name.isEmpty ? nil : name)
            step = .enterOTPAndPassword
            showSuccess = true
        } catch {
            let nsError = error as NSError
            errorMessage = nsError.localizedDescription
            showError = true
            if nsError.userInfo["userAlreadyExists"] != nil {
                userAlreadyExists = true
            }
        }
        isLoading = false
    }
    
    /// Set when signUp fails because user exists; triggers dismiss + switch to sign in
    @Published var userAlreadyExists = false
    
    /// Register - Step 2: Verify OTP and complete registration with password
    func completeRegisterWithOTP() async {
        guard validatePasswords() else { return }
        guard !otpCode.isEmpty else {
            errorMessage = "請輸入驗證碼"
            showError = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabaseService.verifySignUpOTP(
                email: email,
                token: otpCode.trimmingCharacters(in: .whitespaces),
                password: password,
                name: name.isEmpty ? nil : name
            )
            try await AuthService.shared.completeOTPSignUp(response: response)
            didSucceed = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    // MARK: - Forgot Password OTP Flow
    
    /// Forgot password - Step 1: Send recovery OTP to email
    func sendRecoveryOTP() async {
        guard isValidEmail(email) else {
            errorMessage = "請輸入有效的電子郵件地址"
            showError = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            try await supabaseService.sendRecoveryOTP(email: email)
            step = .enterOTPAndPassword
            showSuccess = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    /// Forgot password - Step 2: Verify OTP and set new password
    func completeRecoveryWithOTP() async {
        guard validatePasswords() else { return }
        guard !otpCode.isEmpty else {
            errorMessage = "請輸入驗證碼"
            showError = true
            return
        }
        isLoading = true
        errorMessage = nil
        do {
            let response = try await supabaseService.verifyRecoveryOTP(
                email: email,
                token: otpCode.trimmingCharacters(in: .whitespaces),
                newPassword: password
            )
            try await AuthService.shared.completeOTPSignIn(response: response)
            didSucceed = true
        } catch {
            errorMessage = error.localizedDescription
            showError = true
        }
        isLoading = false
    }
    
    // MARK: - Helpers
    
    private func isValidEmail(_ email: String) -> Bool {
        let pattern = #"^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        return email.range(of: pattern, options: .regularExpression) != nil
    }
    
    private func validatePasswords() -> Bool {
        guard password.count >= 6 else {
            errorMessage = "密碼至少需要 6 個字符"
            showError = true
            return false
        }
        guard password == confirmPassword else {
            errorMessage = "兩次輸入的密碼不一致"
            showError = true
            return false
        }
        return true
    }
    
    func reset() {
        email = ""
        otpCode = ""
        password = ""
        confirmPassword = ""
        name = ""
        step = .enterEmail
        errorMessage = nil
        showError = false
        showSuccess = false
        didSucceed = false
        userAlreadyExists = false
    }
    
    /// Go back to email step (keeps email/name, clears OTP and passwords)
    func goBackToEmailStep() {
        otpCode = ""
        password = ""
        confirmPassword = ""
        step = .enterEmail
        errorMessage = nil
        showError = false
    }
}
