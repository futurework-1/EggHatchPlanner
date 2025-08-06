import SwiftUI

struct TabbarMainView: View {
    
    /// Настройка таббара
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// Текущая выбранная вкладка
    @State private var selectedTab: AppTabScreen = .incubation
    
    var body: some View {
        ZStack(alignment: .center) {
            Group {
                switch selectedTab {
                case .incubation:
                    IncubationMainView()
                case .care:
                    CareMainView()
                case .hatching:
                    HatchigMainView()
                case .settings:
                    SettingsMainView()
                }
            }
            
            // Таббар поверх контента
            if tabbarService.isTabbarVisible {
                VStack(alignment: .center, spacing: 0) {
                    Spacer()
                    TabbarBottomView(selectedTab: $selectedTab)
                }
                .padding(.bottom, AppConfig.isIPhoneSE3rdGeneration
                         ? AppConfig.tabbarBottomPadding - 28
                         :  AppConfig.tabbarBottomPadding)
                .padding(.horizontal, AppConfig.tabbarHorizontalPadding)
            }
        }
        .ignoresSafeArea(.all, edges: .bottom)
    }
}

#Preview {
    TabbarMainView()
        .environmentObject(AppRouter())
        .environmentObject(TabbarService())
}
