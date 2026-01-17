import Foundation
import SwiftUI
import Combine

@MainActor
class AcquiredStrengthsViewModel: ObservableObject {
    @Published var strengths: AcquiredStrengths
    
    var isComplete: Bool {
        !(strengths.experience?.isEmpty ?? true) &&
        !(strengths.knowledge?.isEmpty ?? true) &&
        !(strengths.skills?.isEmpty ?? true) &&
        !(strengths.achievements?.isEmpty ?? true)
    }
    
    init() {
        if let existing = DataService.shared.userProfile?.acquiredStrengths {
            strengths = existing
        } else {
            strengths = AcquiredStrengths()
        }
    }
    
    func saveProgress() {
        DataService.shared.updateUserProfile { profile in
            profile.acquiredStrengths = strengths
        }
    }
    
    func completeAcquiredStrengths() {
        DataService.shared.updateUserProfile { profile in
            profile.acquiredStrengths = strengths
        }
    }
}
