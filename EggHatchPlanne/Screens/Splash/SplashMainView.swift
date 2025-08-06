import SwiftUI

struct SplashMainView: View {
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    
    var body: some View {
        ZStack {
            MainBGView()
            Image(.eggHatchPlannerTitle)
        }
        .onAppear {
            Task {
                try? await Task.sleep(nanoseconds: 3_000_000_000)
                appRouter.currentMainScreen = .tabbar
                // Здесь можно запустить конфиг
                appRouter.showMainScreen = true
            }
        }
    }
}

#Preview {
    SplashMainView()
        .environmentObject(AppRouter())
}
