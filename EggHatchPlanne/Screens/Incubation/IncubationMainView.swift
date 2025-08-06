import SwiftUI

struct IncubationMainView: View {
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    /// ViewModel для управления инкубаторами
    @StateObject private var incubatorViewModel = IncubatorViewModel()
    
    var body: some View {
        NavigationStack(path: $appRouter.incubationRoute) {
            ZStack(alignment: .center) {
                MainBGView()
                
                VStack(alignment: .center, spacing: 0) {
                    
                    Spacer()
                    
                    // Если в UserDefaults нет экземпляров инкубаторов
                    if incubatorViewModel.allIncubators.isEmpty {
                        VStack(alignment: .center, spacing: 20) {
                            Image(.bigRedXmark)
                            
                            Text("THER'S NOTHING HERE YET")
                                .foregroundStyle(.white)
                                .font(.customFont(font: .bold, size: 20))
                        }
                    } else {
                        // Если есть инкубаторы, показываем скролл
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 20) {
                                ForEach(incubatorViewModel.allIncubators, id: \.id) { incubator in
                                    IncubatorItemView(incubator: incubator)
                                }
                            }
                        }
                    }
                    
                    Spacer()
                    
                    UniversalButton(color: .customYellow, isDisabled: false, text: "Add incubation", size: 20, pading: 52) {
                        tabbarService.isTabbarVisible = false
                        appRouter.incubationRoute.append(.addincubation)
                    }
                }
                .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 140 : 80)
                //.padding(.bottom, 180)
                .padding(.bottom, AppConfig.isIPhoneSE3rdGeneration ? 220 : 180)
                .padding(.horizontal, 20)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationDestination(for: IncubationScreen.self) { screen in
                switch screen {
                case .main:
                    IncubationMainView()
                        .environmentObject(incubatorViewModel)
                case .addincubation:
                    AddIncubationView()
                        .environmentObject(incubatorViewModel)
                case .detail(let incubatorId):
                    IncubationDetailView(incubatorId: incubatorId)
                        .environmentObject(incubatorViewModel)
                case .edit(let incubatorId):
                    EditIncubationView(incubatorId: incubatorId)
                        .environmentObject(incubatorViewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(.incubationSetupTitle)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        IncubationMainView()
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
            .environmentObject(IncubatorViewModel())
            .environmentObject(IncubatorViewModel())
    }
}
