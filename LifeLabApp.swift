import SwiftUI
import Combine

@main
struct LifeLabApp: App {
    @StateObject private var dataService = DataService.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(dataService)
        }
    }
}
