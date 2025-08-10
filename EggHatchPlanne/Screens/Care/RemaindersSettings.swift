import SwiftUI

struct RemaindersSettings: View {
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// Сервис управления разрешениями на уведомления
    @StateObject private var notificationService = NotificationPermissionService()
    
    /// Выбранный интервал (сохраняется в UserDefaults)
    @State private var selectedInterval: String = UserDefaults.standard.string(forKey: "selected_interval") ?? "EVERY 3 HOURS"
    
    /// Выбранное время (сохраняется в UserDefaults)
    @State private var selectedTime: String = UserDefaults.standard.string(forKey: "selected_time") ?? "08:00"
    
    /// Выбранные дни (сохраняется в UserDefaults)
    @State private var selectedDays: Set<String> = Set(UserDefaults.standard.stringArray(forKey: "selected_days") ?? ["MON"])
    
    /// Доступные интервалы
    private let intervals = ["EVERY 3 HOURS", "EVERY 6 HOURS", "EVERY 8 HOURS", "EVERY 12 HOURS", "EVERY 24 HOURS"]
    
    /// Доступное время
    private let times = ["08:00", "14:00", "18:00", "20:00"]
    
    /// Доступные дни
    private let days = ["MON", "TUE", "WED", "THU", "FRI", "SAT", "SUN"]
    
    var body: some View {
        ZStack {
            MainBGView()
            
            VStack(alignment: .center, spacing: 0) {
                
                Image(.eggTurningReminders)
                    //.padding(.top, 68)
                    .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 68 : 28)
                    .padding(.bottom, 40)
                
                
                
                HStack(alignment: .center, spacing: 0) {
                    Text("NOTIFICATION")
                        .foregroundStyle(.white)
                        .font(.customFont(font: .bold, size: 24))
                    Spacer()
                    Image(notificationService.isNotificationsEnabled ? .toggleOn : .toggleOff)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 80, height: 80, alignment: .center)
                        .onTapGesture {
                            Task {
                                await notificationService.toggleNotifications()
                            }
                        }
                }
                .padding(.horizontal)
                .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                .padding(.bottom, 20)
                .onTapGesture {
                    Task {
                        await notificationService.toggleNotifications()
                    }
                }
                
                
                
                
                ScrollView {
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("INTERVAL")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 19))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(intervals.prefix(2), id: \.self) { interval in
                            Text(interval)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedInterval == interval ? Color.customVeryLightGray : Color.customDarkGray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedInterval == interval ? Color.white : Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    if notificationService.isNotificationsEnabled {
                                        selectInterval(interval)
                                    }
                                }
                                .opacity(notificationService.isNotificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 0)
                    
                    
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(intervals.dropFirst(2).prefix(2), id: \.self) { interval in
                            Text(interval)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedInterval == interval ? Color.customVeryLightGray : Color.customDarkGray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedInterval == interval ? Color.white : Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    if notificationService.isNotificationsEnabled {
                                        selectInterval(interval)
                                    }
                                }
                                .opacity(notificationService.isNotificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 8)
                    
                    
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(intervals.dropFirst(4), id: \.self) { interval in
                            Text(interval)
                                .foregroundStyle(.white)
                                .font(.customFont(font: .bold, size: 17))
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedInterval == interval ? Color.customVeryLightGray : Color.customDarkGray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedInterval == interval ? Color.white : Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    if notificationService.isNotificationsEnabled {
                                        selectInterval(interval)
                                    }
                                }
                                .opacity(notificationService.isNotificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 32)
                    
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("BY THE HOUR")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 19))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 10)
                    
                    
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(times, id: \.self) { time in
                            Text(time)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedTime == time ? Color.customVeryLightGray : Color.customDarkGray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedTime == time ? Color.white : Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    if notificationService.isNotificationsEnabled {
                                        selectTime(time)
                                    }
                                }
                                .opacity(notificationService.isNotificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 32)
                    
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("BY DAY")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 19))
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
                    
                    
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(days.prefix(4), id: \.self) { day in
                            Text(day)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedDays.contains(day) ? Color.customVeryLightGray : Color.customDarkGray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedDays.contains(day) ? Color.white : Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    if notificationService.isNotificationsEnabled {
                                        toggleDay(day)
                                    }
                                }
                                .opacity(notificationService.isNotificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 4)
                    
                    
                    HStack(alignment: .center, spacing: 6) {
                        ForEach(days.dropFirst(4), id: \.self) { day in
                            Text(day)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(selectedDays.contains(day) ? Color.customVeryLightGray : Color.customDarkGray)
                                )
                                .overlay(
                                    RoundedRectangle(cornerRadius: 16)
                                        .stroke(selectedDays.contains(day) ? Color.white : Color.clear, lineWidth: 1)
                                )
                                .onTapGesture {
                                    if notificationService.isNotificationsEnabled {
                                        toggleDay(day)
                                    }
                                }
                                .opacity(notificationService.isNotificationsEnabled ? 1.0 : 0.5)
                        }
                    }
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 17))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 0)
                    
                }
                .padding(.bottom, AppConfig.isIPhoneSE3rdGeneration ? 120 : 60)
                
                
                
                
            }
            .padding(.horizontal, 28)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            
            
            
            
            
            
        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            /// Кнопка "Назад" с обработчиком навигации
            ToolbarItem(placement: .topBarLeading) {
                Image(.backButton)
                    .padding(.top, 24)
                    .onTapGesture {
                        // Возвращаемся на экран детального представления
                        appRouter.careRoute.removeLast()
                        tabbarService.isTabbarVisible = true
                    }
            }
        }
        .onAppear {
            tabbarService.isTabbarVisible = false
            // Проверяем текущий статус разрешений при появлении экрана
            Task {
                await notificationService.checkCurrentStatus()
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Сброс всех выбранных элементов
    private func resetAllSelections() {
        selectedInterval = "EVERY 3 HOURS"
        selectedTime = "08:00"
        selectedDays = ["MON"]
        
        // Сохраняем сброшенные значения в UserDefaults
        UserDefaults.standard.set(selectedInterval, forKey: "selected_interval")
        UserDefaults.standard.set(selectedTime, forKey: "selected_time")
        UserDefaults.standard.set(Array(selectedDays), forKey: "selected_days")
    }
    
    /// Выбор интервала
    private func selectInterval(_ interval: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedInterval = interval
            UserDefaults.standard.set(interval, forKey: "selected_interval")
        }
    }
    
    /// Выбор времени
    private func selectTime(_ time: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            selectedTime = time
            UserDefaults.standard.set(time, forKey: "selected_time")
        }
    }
    
    /// Переключение дня
    private func toggleDay(_ day: String) {
        withAnimation(.easeInOut(duration: 0.2)) {
            if selectedDays.contains(day) {
                selectedDays.remove(day)
            } else {
                selectedDays.insert(day)
            }
            UserDefaults.standard.set(Array(selectedDays), forKey: "selected_days")
        }
    }
}

#Preview {
    NavigationStack {
        RemaindersSettings()
    }
}
