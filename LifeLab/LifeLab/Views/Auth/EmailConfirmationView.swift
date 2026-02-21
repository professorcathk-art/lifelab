import SwiftUI

/// EmailConfirmationView - Shown when user confirms email via Universal Link
struct EmailConfirmationView: View {
    @State private var isConfirmed = false
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: BrandSpacing.xxl) {
            Spacer()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.5)
            } else {
                // Success Icon
                Image(systemName: isConfirmed ? "checkmark.circle.fill" : "xmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundColor(isConfirmed ? .green : .red)
                
                // Title
                Text(isConfirmed ? "郵箱已確認" : "確認失敗")
                    .font(BrandTypography.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(BrandColors.primaryText)
                
                // Message
                Text(isConfirmed ? "您的郵箱已成功確認。\n現在可以開始使用 LifeLab 了！" : "郵箱確認失敗。\n請檢查確認連結是否正確。")
                    .font(BrandTypography.body)
                    .foregroundColor(BrandColors.secondaryText)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, BrandSpacing.xl)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(BrandColors.background)
        .onAppear {
            // Check confirmation status
            checkConfirmationStatus()
        }
    }
    
    private func checkConfirmationStatus() {
        // Simulate checking confirmation status
        // In production, you would check with Supabase
        Task {
            try? await Task.sleep(nanoseconds: 1_000_000_000) // 1 second
            await MainActor.run {
                // For now, assume confirmed if we reach this view
                // In production, verify with Supabase API
                isConfirmed = true
                isLoading = false
            }
        }
    }
}

#Preview {
    EmailConfirmationView()
}
