import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var dataService: DataService
    @EnvironmentObject var authService: AuthService
    @StateObject private var themeManager = ThemeManager.shared
    @State private var showExportAlert = false
    @State private var showDeleteAlert = false
    @State private var showDeleteAccountAlert = false
    @State private var isDeletingAccount = false
    @State private var showFeedbackSheet = false
    @State private var feedbackText = ""
    @State private var isSubmittingFeedback = false
    @State private var showFeedbackSuccess = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("外觀") {
                    HStack {
                        Label("主題模式", systemImage: themeManager.isDarkMode ? "moon.fill" : "sun.max.fill")
                        Spacer()
                        Button(action: {
                            themeManager.toggleTheme()
                        }) {
                            Text(themeManager.isDarkMode ? "夜間模式" : "日間模式")
                                .font(BrandTypography.subheadline)
                                .foregroundColor(BrandColors.actionAccent)
                        }
                        .buttonStyle(.plain)
                    }
                }
                
                Section("檢視與編輯") {
                    if dataService.userProfile?.lifeBlueprint != nil {
                        NavigationLink(destination: ReviewInitialScanView()) {
                            Label("檢視初步掃描", systemImage: "eye.fill")
                        }
                        
                        NavigationLink(destination: LifeBlueprintEditView(blueprint: dataService.userProfile!.lifeBlueprint!)) {
                            Label("編輯生命藍圖", systemImage: "pencil")
                        }
                    }
                }
                
                Section("數據管理") {
                    // Temporarily hidden - export functionality not working
                    // Button(action: {
                    //     exportAllData()
                    // }) {
                    //     Label("導出所有數據", systemImage: "square.and.arrow.up")
                    // }
                    
                    Button(action: {
                        showDeleteAlert = true
                    }) {
                        Label("清除所有數據", systemImage: "trash")
                            .foregroundColor(.red)
                    }
                }
                
                Section("關於") {
                    HStack {
                        Text("版本")
                        Spacer()
                        Text("1.0.0")
                            .foregroundColor(.secondary)
                    }
                    
                    Button(action: {
                        showFeedbackSheet = true
                    }) {
                        Label("意見反饋", systemImage: "envelope")
                    }
                }
                
                Section("帳號") {
                    if let user = authService.currentUser {
                        HStack {
                            Text("登錄方式")
                            Spacer()
                            Text(user.authProvider == .email ? "電子郵件" : "Apple")
                                .foregroundColor(.secondary)
                        }
                        
                        if let email = user.email {
                            HStack {
                                Text("電子郵件")
                                Spacer()
                                Text(email)
                                    .foregroundColor(.secondary)
                            }
                        }
                        
                        Button(action: {
                            authService.signOut()
                        }) {
                            Label("登出", systemImage: "arrow.right.square")
                                .foregroundColor(.red)
                        }
                        
                        Button(action: {
                            showDeleteAccountAlert = true
                        }) {
                            Label("刪除帳號", systemImage: "trash.fill")
                                .foregroundColor(.red)
                        }
                        .disabled(isDeletingAccount)
                    }
                }
            }
            .navigationTitle("設定")
            .alert("數據已導出", isPresented: $showExportAlert) {
                Button("確定", role: .cancel) { }
            } message: {
                Text("您的數據已成功導出到文件")
            }
            .alert("確定要清除所有數據嗎？", isPresented: $showDeleteAlert) {
                Button("取消", role: .cancel) { }
                Button("清除", role: .destructive) {
                    clearAllData()
                }
            } message: {
                Text("此操作無法復原，所有數據將被永久刪除")
            }
            .alert("確定要刪除帳號嗎？", isPresented: $showDeleteAccountAlert) {
                Button("取消", role: .cancel) { }
                Button("刪除", role: .destructive) {
                    Task {
                        await deleteAccount()
                    }
                }
            } message: {
                Text("刪除帳號將永久刪除您的所有數據，包括個人檔案、生命藍圖和行動計劃。此操作無法復原。")
            }
            .sheet(isPresented: $showFeedbackSheet) {
                FeedbackView(
                    feedbackText: $feedbackText,
                    isSubmitting: $isSubmittingFeedback,
                    showSuccess: $showFeedbackSuccess,
                    onDismiss: { showFeedbackSheet = false }
                )
            }
            .alert("反饋已提交", isPresented: $showFeedbackSuccess) {
                Button("確定", role: .cancel) {
                    feedbackText = ""
                }
            } message: {
                Text("感謝您的反饋！我們會盡快處理。")
            }
        }
    }
    
    private func exportAllData() {
        guard let profile = dataService.userProfile else { return }
        
        var exportText = "LifeLab 數據導出\n"
        exportText += "導出時間：\(Date().formatted(date: .long, time: .standard))\n\n"
        
        // Interests
        if !profile.interests.isEmpty {
            exportText += "興趣：\n\(profile.interests.joined(separator: ", "))\n\n"
        }
        
        // Strengths
        if !profile.strengths.isEmpty {
            exportText += "優勢：\n"
            for strength in profile.strengths {
                exportText += "- \(strength.question)\n"
                if !strength.selectedKeywords.isEmpty {
                    exportText += "  關鍵詞：\(strength.selectedKeywords.joined(separator: ", "))\n"
                }
            }
            exportText += "\n"
        }
        
        // Values
        if !profile.values.isEmpty {
            exportText += "價值觀排序：\n"
            let sortedValues = profile.values.sorted { $0.rank > $1.rank }
            for (index, value) in sortedValues.prefix(5).enumerated() {
                exportText += "\(index + 1). \(value.value.rawValue)\n"
            }
            exportText += "\n"
        }
        
        // Flow Diary
        if !profile.flowDiaryEntries.isEmpty {
            exportText += "心流日記：\n"
            for (index, entry) in profile.flowDiaryEntries.enumerated() {
                if !entry.activity.isEmpty {
                    exportText += "第\(index + 1)天：\(entry.activity)\n"
                    if !entry.description.isEmpty {
                        exportText += "  描述：\(entry.description)\n"
                    }
                }
            }
            exportText += "\n"
        }
        
        // Life Blueprint
        if let blueprint = profile.lifeBlueprint {
            exportText += "生命藍圖：\n"
            for direction in blueprint.vocationDirections {
                exportText += "- \(direction.title)\n"
                exportText += "  \(direction.description)\n"
            }
            exportText += "\n"
        }
        
        exportText += "---\n由 LifeLab 生成"
        
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        let dateString = formatter.string(from: Date())
        let url = FileManager.default.temporaryDirectory.appendingPathComponent("LifeLab_數據_\(dateString).txt")
        
        do {
            try exportText.write(to: url, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let window = windowScene.windows.first,
               let rootViewController = window.rootViewController {
                // For iPad
                if let popover = activityVC.popoverPresentationController {
                    popover.sourceView = window
                    popover.sourceRect = CGRect(x: window.bounds.midX, y: window.bounds.midY, width: 0, height: 0)
                    popover.permittedArrowDirections = []
                }
                rootViewController.present(activityVC, animated: true)
            }
            
            showExportAlert = true
        } catch {
            print("Export failed: \(error)")
        }
    }
    
    private func clearAllData() {
        // Clear user profile data
        DataService.shared.clearUserProfile()
        
        // Clear AI consent status
        if let userId = authService.currentUser?.id {
            let consentKey = "lifelab_ai_consent_\(userId)"
            UserDefaults.standard.removeObject(forKey: consentKey)
        } else {
            // Fallback: clear consent for unauthenticated users
            UserDefaults.standard.removeObject(forKey: "lifelab_ai_consent")
        }
        
        // Clear any other user-specific data
        if let userId = authService.currentUser?.id {
            UserDefaults.standard.removeObject(forKey: "lifelab_last_sync_time_\(userId)")
        }
        
        // The ContentView will automatically detect that hasCompletedInitialScan is false
        // and will show InitialScanView with currentStep = .basicInfo (first page)
        print("✅ All data cleared. User will be redirected to initial scan.")
    }
    
    private func deleteAccount() async {
        isDeletingAccount = true
        
        do {
            // Delete user data from Supabase
            if let userId = authService.currentUser?.id {
                try await SupabaseService.shared.deleteUserData(userId: userId)
            }
            
            // Clear local data
            await MainActor.run {
                DataService.shared.clearUserProfile()
                authService.signOut()
            }
            
            print("✅ Account deleted successfully")
        } catch {
            await MainActor.run {
                print("❌ Failed to delete account: \(error.localizedDescription)")
                // Still clear local data even if Supabase deletion fails
                DataService.shared.clearUserProfile()
                authService.signOut()
            }
        }
        
        isDeletingAccount = false
    }
}

struct FeedbackView: View {
    @Binding var feedbackText: String
    @Binding var isSubmitting: Bool
    @Binding var showSuccess: Bool
    let onDismiss: () -> Void
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextEditor(text: $feedbackText)
                        .frame(minHeight: 200)
                } header: {
                    Text("請分享您的意見和建議")
                }
            }
            .navigationTitle("意見反饋")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("取消") {
                        feedbackText = ""
                        dismiss()
                        onDismiss()
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("提交") {
                        submitFeedback()
                    }
                    .disabled(feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || isSubmitting)
                }
            }
        }
    }
    
    private func submitFeedback() {
        guard !feedbackText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        isSubmitting = true
        
        Task {
            do {
                try await FeedbackService.shared.submitFeedback(text: feedbackText)
                await MainActor.run {
                    isSubmitting = false
                    showSuccess = true
                    feedbackText = ""
                    dismiss()
                    onDismiss()
                }
            } catch {
                await MainActor.run {
                    isSubmitting = false
                    print("Failed to submit feedback: \(error)")
                }
            }
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataService.shared)
}
