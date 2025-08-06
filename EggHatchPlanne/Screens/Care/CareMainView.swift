import SwiftUI

struct CareMainView: View {
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// Состояние чекбокса (загружается из UserDefaults)
    @State private var isChecked: Bool = UserDefaults.standard.bool(forKey: "egg_turning_checked")
    /// Время последней установки галочки (загружается из UserDefaults)
    @State private var lastCheckTime: Date? = {
        if let timeInterval = UserDefaults.standard.object(forKey: "egg_turning_time") as? TimeInterval {
            return Date(timeIntervalSince1970: timeInterval)
        }
        return nil
    }()
    /// Таймер для автоматического сброса
    @State private var resetTimer: Timer?
    
    /// Данные для дней ухода за яйцами
    private let careDays = [
        (day: 1, image: "eggImage1"),
        (day: 5, image: "eggImage2"),
        (day: 10, image: "eggImage3"),
        (day: 18, image: "eggImage4"),
        (day: 21, image: "eggImage5")
    ]
    
    var body: some View {
        @ObservedObject var appRouter = appRouter
        
        NavigationStack(path: $appRouter.careRoute) {
            ZStack(alignment: .center) {
                MainBGView()
                
                VStack(alignment: .center, spacing: 20) {
                    Image(.eggCareTitle)
                        .padding(.top, 90)
                    
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("EGG TURNING")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 20))
                        Spacer()
                        Image(.gearImge)
                            .onTapGesture {
                                appRouter.careRoute.append(.careSetings)
                            }
                    }
                    
                    HStack(alignment: .center, spacing: 4) {
                        Image(isChecked ? .chekBoxDone : .chekBox)
                            .onTapGesture {
                                toggleCheckbox()
                            }
                        
                        Text("TURN EGGS")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 22))
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    .onTapGesture {
                        toggleCheckbox()
                    }
                    
                    HStack(alignment: .center, spacing: 0) {
                        ForEach(careDays, id: \.day) { careDay in
                            CareDayView(day: careDay.day, imageName: careDay.image)
                        }
                    }
                    .padding()
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    
                    Spacer()
                    
                }
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .navigationDestination(for: CareScreen.self) { screen in
                switch screen {
                case .main:
                    RemaindersSettings()
                case .careSetings:
                   RemaindersSettings()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .toolbar {
                
//                ToolbarItem(placement: .principal) {
//                    Image(.eggCareTitle)
//                        .padding(.top, 40)
//                }
            }
            .onAppear {
                checkAndRestoreState()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Переключение состояния чекбокса
    private func toggleCheckbox() {
        withAnimation(.easeInOut(duration: 0.2)) {
            isChecked.toggle()
            
            if isChecked {
                // Сохраняем время установки галочки
                let currentTime = Date()
                lastCheckTime = currentTime
                UserDefaults.standard.set(currentTime.timeIntervalSince1970, forKey: "egg_turning_time")
                UserDefaults.standard.set(true, forKey: "egg_turning_checked")
                
                // Запускаем таймер на 3 часа (10800 секунд)
                startResetTimer()
            } else {
                // Останавливаем таймер если чекбокс снят вручную
                stopResetTimer()
                UserDefaults.standard.set(false, forKey: "egg_turning_checked")
                UserDefaults.standard.removeObject(forKey: "egg_turning_time")
            }
        }
    }
    
    /// Запуск таймера для автоматического сброса
    private func startResetTimer() {
        // Останавливаем предыдущий таймер если он есть
        stopResetTimer()
        
        // Создаем новый таймер на 3 часа
        resetTimer = Timer.scheduledTimer(withTimeInterval: 10800, repeats: false) { _ in
            DispatchQueue.main.async {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isChecked = false
                    UserDefaults.standard.set(false, forKey: "egg_turning_checked")
                    UserDefaults.standard.removeObject(forKey: "egg_turning_time")
                }
            }
        }
    }
    
    /// Остановка таймера
    private func stopResetTimer() {
        resetTimer?.invalidate()
        resetTimer = nil
    }
    
    /// Проверка и восстановление состояния при загрузке
    private func checkAndRestoreState() {
        guard let lastCheckTime = lastCheckTime else { return }
        
        let currentTime = Date()
        let timeDifference = currentTime.timeIntervalSince(lastCheckTime)
        
        // Если прошло больше 3 часов, сбрасываем галочку
        if timeDifference >= 10800 {
            isChecked = false
            UserDefaults.standard.set(false, forKey: "egg_turning_checked")
            UserDefaults.standard.removeObject(forKey: "egg_turning_time")
        } else {
            // Если прошло меньше 3 часов, запускаем таймер на оставшееся время
            let remainingTime = 10800 - timeDifference
            resetTimer = Timer.scheduledTimer(withTimeInterval: remainingTime, repeats: false) { _ in
                DispatchQueue.main.async {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        isChecked = false
                        UserDefaults.standard.set(false, forKey: "egg_turning_checked")
                        UserDefaults.standard.removeObject(forKey: "egg_turning_time")
                    }
                }
            }
        }
    }
}

#Preview {
    CareMainView()
        .environmentObject(AppRouter())
}
