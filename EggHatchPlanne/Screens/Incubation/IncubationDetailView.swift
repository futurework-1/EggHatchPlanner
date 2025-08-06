import SwiftUI

struct IncubationDetailView: View {
    let incubatorId: UUID
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    /// ViewModel для управления инкубаторами
    @EnvironmentObject private var incubatorViewModel: IncubatorViewModel
    
    /// Показывать ли алерт подтверждения удаления
    @State private var showDeleteAlert = false
    
    private var incubator: Incubator? {
        incubatorViewModel.getIncubator(by: incubatorId)
    }
    
    var body: some View {
        ZStack(alignment: .center) {
            MainBGView()
            
            if let incubator = incubator {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        
                        Image(.eggImage1)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 120, height: 120, alignment: .center)
                            .padding(.bottom, 8)
                        
                        Text("HATCHING DATE")
                            .foregroundStyle(.customLightGray)
                            .font(.customFont(font: .bold, size: 18))
                            .padding(.bottom, 2)
                        
                        Text(incubator.hatchingDate.formattedDate)
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 24))
                            .padding(.bottom, 20)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("SPECIES")
                                .foregroundStyle(.white)
                                .font(.customFont(font: .bold, size: 20))
                            
                            Text(incubator.selectedSpecies.displayName)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 12)
                                .foregroundStyle(.white)
                                .font(.customFont(font: .bold, size: 20))
                                .background(RoundedRectangle(cornerRadius:20)
                                    .fill(.customVeryLightGray))
                                .overlay(RoundedRectangle(cornerRadius: 16)
                                    .stroke(.white))
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 28)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("📅 START DATE")
                                .foregroundStyle(.customVeryLightGray)
                                .font(.customFont(font: .bold, size: 20))
                            
                            Text(incubator.startDate.formattedDate)
                                .foregroundStyle(.white)
                                .font(.customFont(font: .bold, size: 24))
                                .padding(.bottom, 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 28)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("🥚 NUMBER OF EGGS")
                                .foregroundStyle(.customVeryLightGray)
                                .font(.customFont(font: .bold, size: 20))
                            
                            Text("\(incubator.numberOfEggs)")
                                .foregroundStyle(.white)
                                .font(.customFont(font: .bold, size: 24))
                                .padding(.bottom, 20)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.bottom, 28)
                        
                        if !incubator.note.isEmpty {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("📝 NOTE")
                                    .foregroundStyle(.customVeryLightGray)
                                    .font(.customFont(font: .bold, size: 20))
                                
                                Text(incubator.note)
                                    .foregroundStyle(.white)
                                    .font(.customFont(font: .bold, size: 24))
                                    .padding(.bottom, 20)
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    .padding(.horizontal)
                }
                //.padding(.top, 80)
                .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 120 : 80)
            } else {
                // Показываем сообщение если инкубатор не найден
                VStack {
                    Text("The incubator is not found, try restarting the device.")
                        .foregroundStyle(.white)
                        .font(.customFont(font: .bold, size: 20))
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            /// Кнопка "Назад" с обработчиком навигации
            ToolbarItem(placement: .topBarLeading) {
                Image(.backButton)
                    .onTapGesture {
                        // Показываем Tabbar при возврате
                        tabbarService.isTabbarVisible = true
                        appRouter.incubationRoute.removeLast()
                    }
            }
            /// Кнопка "Редактирование" с обработчиком навигации
            ToolbarItem(placement: .topBarTrailing) {
                Image(.editButton)
                    .onTapGesture {
                        // Переходим на экран редактирования с ID инкубатора
                        appRouter.incubationRoute.append(.edit(incubatorId: incubatorId))
                    }
            }
            /// Кнопка "Удаление" с обработчиком навигации
            ToolbarItem(placement: .topBarTrailing) {
                Image(.trashButton)
                    .onTapGesture {
                        // Показываем алерт подтверждения удаления
                        showDeleteAlert = true
                    }
            }
        }
        .alert("DELETE", isPresented: $showDeleteAlert) {
            Button("DELETE") {
                // Удаляем инкубатор
                incubatorViewModel.deleteIncubator(with: incubatorId)
                // Показываем Tabbar
                tabbarService.isTabbarVisible = true
                // Возвращаемся на главный экран
                appRouter.incubationRoute.removeAll()
            }
            .background(Color.red)
            .foregroundColor(.white)
            
            Button("CANCEL") {
                // Просто закрываем алерт
            }
            .background(Color.red)
            .foregroundColor(.red)
        } message: {
            Text("ARE YOU SURE YOU WANT TO DELETE ALL COMPLETED INCUBATION RECORDS?")
        }
    }
}

#Preview {
    NavigationStack {
        IncubationDetailView(incubatorId: UUID())
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
            .environmentObject(IncubatorViewModel())
    }
}
