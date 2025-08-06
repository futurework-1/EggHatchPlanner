import SwiftUI

struct AddHatchingStep2View: View {
    
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// ViewModel для управления данными вылуплений
    var hatchingViewModel: HatchingViewModel
    
    // MARK: - State
    @State private var chickName: String = ""
    @State private var tag: String = ""
    @FocusState private var isChickNameFieldFocused: Bool
    @FocusState private var isTagFieldFocused: Bool
    
    var body: some View {
        ZStack(alignment: .center) {
            MainBGView()
                .onTapGesture {
                    // Скрытие клавиатуры при тапе на пустое место
                    isChickNameFieldFocused = false
                    isTagFieldFocused = false
                }
            
            VStack(spacing: 16) {
                
                Spacer(minLength: 0)
                
                // Поле имени цыпленка
                HStack(alignment: .top, spacing: 8) {
                    Text("🐥")
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .padding(.top, 2)
                    
                    TextField("Chick Name (optional)", text: $chickName)
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .focused($isChickNameFieldFocused)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(.customDarkGray)
                )
                
                // Поле тега
                HStack(alignment: .top, spacing: 8) {
                    Text("📍")
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .padding(.top, 2)
                    
                    TextField("Tag (optional)", text: $tag)
                        .font(.customFont(font: .bold, size: 20))
                        .foregroundColor(.white)
                        .textCase(.uppercase)
                        .focused($isTagFieldFocused)
                    
                    Spacer()
                }
                .padding()
                .background(
                    RoundedRectangle(cornerRadius: 17)
                        .fill(.customDarkGray)
                )
                
                Spacer(minLength: 0)
                
                // Кнопки
                HStack(spacing: 16) {
                    // Кнопка Skip
                    UniversalButton(
                        color: Color("customYellow"),
                        isDisabled: false,
                        text: "skip",
                        size: 20,
                        pading: 52
                    ) {
                        // Сохранить запись без имени и тега
                        saveHatching()
                    }
                    
                    // Кнопка Save
                    UniversalButton(
                        color: (chickName.isEmpty && tag.isEmpty) ? Color("customYellow").opacity(0.25) : Color("customYellow"),
                        isDisabled: chickName.isEmpty && tag.isEmpty,
                        text: "save",
                        size: 20,
                        pading: 52
                    ) {
                        // Сохранить запись с данными
                        saveHatching()
                    }
                }
            }
            .padding(.horizontal)
            .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 118 : 80)
            .padding(.bottom, AppConfig.adaptiveTabbarHeight + (AppConfig.isIPhoneSE3rdGeneration ? 150 : 92))
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Image(.backButton)
                    .onTapGesture {
                        appRouter.hatchingRoute.removeLast()
                    }
            }
            
            ToolbarItem(placement: .principal) {
                Image(.addHatching)
            }
            
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button("Done") {
                    isTagFieldFocused = false
                    isChickNameFieldFocused = false
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func saveHatching() {
        // Создаем новую запись используя данные из обоих экранов
        hatchingViewModel.createHatchingFromTempData(
            chickName: chickName.isEmpty ? nil : chickName,
            tag: tag.isEmpty ? nil : tag
        )
        
        // Возвращаемся на главный экран
        tabbarService.isTabbarVisible = true
        appRouter.hatchingRoute.removeAll()
    }
}

#Preview {
    NavigationStack {
        AddHatchingStep2View(hatchingViewModel: HatchingViewModel())
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
    }
}
