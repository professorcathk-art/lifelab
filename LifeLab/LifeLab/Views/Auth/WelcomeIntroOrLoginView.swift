import SwiftUI

/// View that decides whether to show WelcomeIntroView or LoginView
struct WelcomeIntroOrLoginView: View {
    @AppStorage("hasSeenWelcomeIntro") private var hasSeenWelcomeIntro = false
    @EnvironmentObject var authService: AuthService
    @EnvironmentObject var themeManager: ThemeManager
    
    var body: some View {
        Group {
            if hasSeenWelcomeIntro {
                LoginView()
            } else {
                WelcomeIntroView()
            }
        }
    }
}
