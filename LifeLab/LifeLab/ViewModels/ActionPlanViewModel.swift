import Foundation
import SwiftUI
import Combine

@MainActor
class ActionPlanViewModel: ObservableObject {
    @Published var actionPlan: ActionPlan?
    @Published var isLoading = false
    
    init() {
        loadActionPlan()
    }
    
    func loadActionPlan() {
        if let profile = DataService.shared.userProfile {
            actionPlan = profile.actionPlan
        }
    }
    
    func generateActionPlan() {
        guard let profile = DataService.shared.userProfile else { return }
        
        // Check if all deepening exploration steps are complete
        let isComplete = profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count >= 3 &&
                        profile.valuesQuestions != nil &&
                        profile.resourceInventory != nil &&
                        profile.acquiredStrengths != nil &&
                        profile.feasibilityAssessment != nil
        
        guard isComplete else { return }
        
        // Don't regenerate if already exists
        guard profile.actionPlan == nil else {
            actionPlan = profile.actionPlan
            return
        }
        
        isLoading = true
        Task {
            do {
                let plan = try await AIService.shared.generateActionPlan(profile: profile)
                await MainActor.run {
                    self.actionPlan = plan
                    self.isLoading = false
                    DataService.shared.updateUserProfile { profile in
                        profile.actionPlan = plan
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoading = false
                }
            }
        }
    }
    
    func updateActionPlan(_ plan: ActionPlan) {
        actionPlan = plan
        DataService.shared.updateUserProfile { profile in
            profile.actionPlan = plan
        }
    }
}
