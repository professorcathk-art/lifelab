import SwiftUI
import UIKit

struct SettingsView: View {
    @EnvironmentObject var dataService: DataService
    @State private var showExportAlert = false
    @State private var showDeleteAlert = false
    
    var body: some View {
        NavigationStack {
            List {
                Section("檢視與編輯") {
                    if dataService.userProfile?.lifeBlueprint != nil {
                        NavigationLink(destination: ReviewInitialScanView()) {
                            Label("檢視初步掃描", systemImage: "eye.fill")
                        }
                    }
                }
                
                Section("數據管理") {
                    Button(action: {
                        exportAllData()
                    }) {
                        Label("導出所有數據", systemImage: "square.and.arrow.up")
                    }
                    
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
                    
                    Link(destination: URL(string: "https://lifelab.app")!) {
                        Label("網站", systemImage: "globe")
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
        DataService.shared.updateUserProfile { profile in
            profile.interests = []
            profile.strengths = []
            profile.values = []
            profile.flowDiaryEntries = []
            profile.valuesQuestions = nil
            profile.resourceInventory = nil
            profile.acquiredStrengths = nil
            profile.feasibilityAssessment = nil
            profile.lifeBlueprint = nil
            profile.actionPlan = nil
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(DataService.shared)
}
