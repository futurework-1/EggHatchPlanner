import SwiftUI

struct HatchigMainView: View {
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// ViewModel для управления данными вылуплений
    @StateObject private var hatchingViewModel = HatchingViewModel()
    
    var body: some View {
        @ObservedObject var appRouter = appRouter
        
        NavigationStack(path: $appRouter.hatchingRoute) {
            ZStack(alignment: .center) {
                MainBGView()
                
                VStack(spacing: 16) {
                    
                    
                    if !hatchingViewModel.hatchings.isEmpty {
                        // Контент с данными
                        VStack(spacing: 20) {
                            // Статистика
                            let statistics = hatchingViewModel.getHatchingStatistics()
                            HStack(spacing: 16) {
                                StatisticsCardView(
                                    title: "Total Eggs",
                                    value: "\(statistics.totalEggs)",
                                    isPercentage: false
                                )

                                StatisticsCardView(
                                    title: "Hatched",
                                    value: "\(statistics.totalHatchings)",
                                    isPercentage: false
                                )

                                StatisticsCardView(
                                    title: "Success Rate",
                                    value: "\(Int(statistics.successRate))%",
                                    isPercentage: true
                                )
                            }

                            // Список записей
                            ScrollView {
                                LazyVStack(spacing: 16) {
                                    ForEach(hatchingViewModel.hatchings.sorted(by: { $0.hatchDate > $1.hatchDate })) { hatching in
                                        HatchingCardView(
                                            image: hatching.image,
                                            tag: hatching.tag,
                                            hatchDate: hatching.hatchDate.formattedDate,
                                            eggCount: "1"
                                        )
                                        .onTapGesture {
                                            // Сохраняем выбранную запись и переходим к детальному просмотру
                                            hatchingViewModel.selectHatching(withId: hatching.id)
                                            appRouter.hatchingRoute.append(.detail)
                                        }
                                    }
                                }
                            }
                            .scrollIndicators(.hidden)
                        }
                    } else {
                        EmptyStateView(imageName: "bigRedXmark", text: "There's nothing here yet")
                    }
                    
                    UniversalButton(color: .customYellow, isDisabled: false, text: "Add hatching", size: 20, pading: 52) {
                        appRouter.hatchingRoute.append(.addStep1)
                    }
                }
                .padding(.horizontal)
                .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 110 : 72)
                .padding(.bottom, AppConfig.adaptiveTabbarHeight + (AppConfig.isIPhoneSE3rdGeneration ? 150 : 92))
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationDestination(for: HatchingScreen.self) { screen in
                switch screen {
                case .main:
                    HatchigMainView()
                case .addStep1:
                    AddHatchingStep1View(hatchingViewModel: hatchingViewModel)
                case .addStep2:
                    AddHatchingStep2View(hatchingViewModel: hatchingViewModel)
                case .detail:
                    HatchingDetailView(hatchingViewModel: hatchingViewModel)
                case .edit:
                    EditHatchingView(hatchingViewModel: hatchingViewModel)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(.hatchingTitle)
                }
            }
        }
    }
}

#Preview {
    NavigationView {
        HatchigMainView()
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
            .environmentObject(HatchingViewModel())
    }
}
