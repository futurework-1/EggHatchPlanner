import SwiftUI

@main
struct EggHatchPlanneApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// Роутер для навигации
    @StateObject private var appRouter = AppRouter()
    
    /// Сервис управления таббаром
    @StateObject private var tabbarService = TabbarService()
    
    var body: some Scene {
        WindowGroup {
            BlackWindow(rootView: RootView()
                .environmentObject(appRouter)
                .environmentObject(tabbarService)
                .dynamicTypeSize(.large)
                .preferredColorScheme(.dark)
                .background(.black), remoteConfigKey: AppConstants.remoteConfigKey)
        }
    }
}

struct AppConstants {
    static let metricsBaseURL = "https://tchegglan.com/app/metrics"
    static let salt = "5vX3PcXIQJa28bpqvp24ogb2X13pzBOC"
    static let oneSignalAppID = "b055c83e-c1cf-4fcd-ae6e-ad5a3eb8f5bb"
    static let userDefaultsKey = "EggHatch"
    static let remoteConfigStateKey = "EggHatchConfig"
    static let remoteConfigKey = "isEnable"
}

