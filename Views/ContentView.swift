import SwiftUI

struct ContentView: View {
    @StateObject private var dataService = DataService.shared
    @StateObject private var viewModel = InitialScanViewModel()
    
    var hasCompletedInitialScan: Bool {
        dataService.userProfile?.lifeBlueprint != nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.systemBackground)
                    .ignoresSafeArea()
                
                if hasCompletedInitialScan {
                    MainTabView()
                        .environmentObject(dataService)
                } else {
                    InitialScanView()
                        .environmentObject(viewModel)
                        .onAppear {
                            if let profile = dataService.userProfile {
                                viewModel.selectedInterests = profile.interests
                                viewModel.strengths = profile.strengths
                                viewModel.selectedValues = profile.values
                                if profile.lifeBlueprint != nil {
                                    viewModel.lifeBlueprint = profile.lifeBlueprint
                                    viewModel.currentStep = .blueprint
                                } else if !profile.values.isEmpty {
                                    viewModel.currentStep = .aiSummary
                                } else if !profile.strengths.isEmpty {
                                    viewModel.currentStep = .values
                                } else if !profile.interests.isEmpty {
                                    viewModel.currentStep = .strengths
                                }
                            }
                        }
                }
            }
        }
    }
}

struct MainTabView: View {
    @EnvironmentObject var dataService: DataService
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("首頁", systemImage: "house.fill")
                }
            
            DeepeningExplorationView()
                .tabItem {
                    Label("深化探索", systemImage: "chart.line.uptrend.xyaxis")
                }
            
            TaskManagementView()
                .tabItem {
                    Label("任務", systemImage: "checkmark.circle.fill")
                }
            
            ProfileView()
                .tabItem {
                    Label("個人檔案", systemImage: "person.fill")
                }
        }
    }
}

#Preview {
    ContentView()
}
