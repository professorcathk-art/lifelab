import Foundation
import SwiftUI
import Combine

@MainActor
class ResourceInventoryViewModel: ObservableObject {
    @Published var inventory: ResourceInventory
    
    var isComplete: Bool {
        !(inventory.time?.isEmpty ?? true) &&
        !(inventory.money?.isEmpty ?? true) &&
        !(inventory.items?.isEmpty ?? true) &&
        !(inventory.network?.isEmpty ?? true)
    }
    
    init() {
        if let existing = DataService.shared.userProfile?.resourceInventory {
            inventory = existing
        } else {
            inventory = ResourceInventory()
        }
    }
    
    func saveProgress() {
        DataService.shared.updateUserProfile { profile in
            profile.resourceInventory = inventory
        }
    }
    
    func completeResourceInventory() {
        DataService.shared.updateUserProfile { profile in
            profile.resourceInventory = inventory
        }
    }
}
