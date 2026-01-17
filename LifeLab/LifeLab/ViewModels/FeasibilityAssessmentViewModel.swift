import Foundation
import SwiftUI
import Combine

@MainActor
class FeasibilityAssessmentViewModel: ObservableObject {
    @Published var assessment: FeasibilityAssessment
    
    var isComplete: Bool {
        !(assessment.path1?.isEmpty ?? true) &&
        !(assessment.path2?.isEmpty ?? true) &&
        !(assessment.path3?.isEmpty ?? true) &&
        !(assessment.path4?.isEmpty ?? true) &&
        !(assessment.path5?.isEmpty ?? true) &&
        !(assessment.path6?.isEmpty ?? true)
    }
    
    init() {
        if let existing = DataService.shared.userProfile?.feasibilityAssessment {
            assessment = existing
        } else {
            assessment = FeasibilityAssessment()
        }
    }
    
    func saveProgress() {
        DataService.shared.updateUserProfile { profile in
            profile.feasibilityAssessment = assessment
        }
    }
    
    func completeFeasibilityAssessment() {
        DataService.shared.updateUserProfile { profile in
            profile.feasibilityAssessment = assessment
            
            // Check if all deepening exploration is complete, then generate action plan
            let isComplete = profile.flowDiaryEntries.filter({ !$0.activity.isEmpty }).count >= 3 &&
                            profile.valuesQuestions != nil &&
                            profile.resourceInventory != nil &&
                            profile.acquiredStrengths != nil &&
                            profile.feasibilityAssessment != nil
            
            if isComplete && profile.actionPlan == nil {
                // Generate action plan
                let profileCopy = profile
                Task {
                    do {
                        let plan = try await AIService.shared.generateActionPlan(profile: profileCopy)
                        await MainActor.run {
                            DataService.shared.updateUserProfile { profile in
                                profile.actionPlan = plan
                            }
                        }
                    } catch {
                        print("Failed to generate action plan: \(error)")
                    }
                }
            }
        }
    }
}
