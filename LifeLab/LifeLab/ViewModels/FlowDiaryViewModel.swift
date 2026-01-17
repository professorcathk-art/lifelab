import Foundation
import SwiftUI
import Combine

@MainActor
class FlowDiaryViewModel: ObservableObject {
    @Published var entries: [FlowDiaryEntry] = []
    
    var completedEvents: Int {
        entries.filter { !$0.activity.isEmpty }.count
    }
    
    init() {
        loadEntries()
        // Ensure at least 3 empty entries for initial display
        while entries.count < 3 {
            entries.append(FlowDiaryEntry())
        }
    }
    
    func saveEntry(_ entry: FlowDiaryEntry, at index: Int) {
        guard index < entries.count else { return }
        entries[index] = entry
        saveEntries()
    }
    
    func addNewEntry() {
        entries.append(FlowDiaryEntry())
        saveEntries()
    }
    
    func deleteEntry(at index: Int) {
        guard index < entries.count else { return }
        entries.remove(at: index)
        saveEntries()
    }
    
    func completeFlowDiary() {
        DataService.shared.updateUserProfile { profile in
            profile.flowDiaryEntries = entries
        }
    }
    
    private func loadEntries() {
        if let profile = DataService.shared.userProfile,
           !profile.flowDiaryEntries.isEmpty {
            entries = profile.flowDiaryEntries
        }
    }
    
    private func saveEntries() {
        DataService.shared.updateUserProfile { profile in
            profile.flowDiaryEntries = entries
        }
    }
}
