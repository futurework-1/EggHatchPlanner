import SwiftUI

struct SplashMainView: View {
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    
    var body: some View {
        ZStack {
            MainBGView()
            Image(.eggHatchPlannerTitle)
        }
        .onReceive(NotificationCenter.default.publisher(for: .splashTransition)) { _ in
            withAnimation {
                self.appRouter.currentMainScreen = .tabbar
                self.appRouter.showMainScreen = true
            }
        }
    }
}

#Preview {
    SplashMainView()
        .environmentObject(AppRouter())
}
