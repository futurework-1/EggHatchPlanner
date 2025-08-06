import SwiftUI

struct AddIncubationView: View {
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    /// ViewModel для управления инкубаторами
    @EnvironmentObject private var incubatorViewModel: IncubatorViewModel
    /// Глобальное состояние фокуса для управления клавиатурой во всех текстовых полях
    @State private var isAnyTextFieldFocused: Bool = false
    
    // MARK: - Состояния для сбора данных
    /// Выбранный вид птицы
    @State private var selectedSpecies: BirdSpecies = .chicken
    /// Выбранная дата
    @State private var selectedDate: Date = Date()
    /// Количество яиц
    @State private var numberOfEggs: Int = 0
    /// Выбранные напоминания
    @State private var selectedReminders: [ReminderType] = []
    /// Заметка
    @State private var note: String = ""
    
    var body: some View {
        ZStack(alignment: .center) {
            MainBGView()
            
            VStack(alignment: .center, spacing: 0) {
                
                ScrollView {
                    /// Компонент выбора вида птицы
                    SelectSpeciesView(selectedSpecies: $selectedSpecies)
                        .padding(.vertical, 20)
                    
                    /// Компонент отображения даты
                    DateView(selectedDate: $selectedDate)
                    
                    /// Компонент ввода количества яиц с передачей состояния фокуса
                    NumberOfEggsView(
                        isAnyTextFieldFocused: $isAnyTextFieldFocused,
                        numberOfEggs: $numberOfEggs
                    )
                        .padding(.bottom, 20)
                    
                    /// Заголовок секции напоминаний
                    HStack {
                        Text("⏰ DAILY REMAINDERS")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 16))
                        Spacer()
                    }
                    
                    /// Чекбоксы для различных типов напоминаний
                    ChekBoxView(text: "TURN EGGS", reminderType: .turnEggs, selectedReminders: $selectedReminders)
                    ChekBoxView(text: "CHECK TEMPERATURE", reminderType: .checkTemperature, selectedReminders: $selectedReminders)
                    ChekBoxView(text: "CHECK HUMIDITY", reminderType: .checkHumidity, selectedReminders: $selectedReminders)
                        .padding(.bottom, 20)
                    
                    /// Компонент для заметок
                    NoteView(note: $note)
                    

                }
                .padding(.top, AppConfig.isIPhoneSE3rdGeneration ? 120 : 80)
                .padding(.bottom, AppConfig.isIPhoneSE3rdGeneration ? 60 : 20)
                
                /// Кнопка сохранения с обработчиком навигации
                UniversalButton(color: .customYellow, isDisabled: false, text: "save", size: 20, pading: 52) {
                    // Создаем экземпляр Incubator
                    let newIncubator = Incubator(
                        selectedSpecies: selectedSpecies,
                        startDate: selectedDate,
                        numberOfEggs: numberOfEggs,
                        reminders: selectedReminders,
                        note: note
                    )
                    
                    
                    // Временный вывод для проверки данных
                    print("Создаем инкубатор:")
                    print("- Вид птицы: \(selectedSpecies.displayName)")
                    print("- Дата: \(selectedDate)")
                    print("- Количество яиц: \(numberOfEggs)")
                    print("- Напоминания: \(selectedReminders.map { $0.displayName })")
                    print("- Заметка: \(note)")
                    
                    // Сохраняем в UserDefaults через ViewModel
                    incubatorViewModel.addIncubator(newIncubator)
                    
                    // Показываем Tabbar при сохранении
                    tabbarService.isTabbarVisible = true
                    appRouter.incubationRoute.removeLast()
                }
                .padding(.bottom, AppConfig.isIPhoneSE3rdGeneration ? 120 : 60)
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            /// Заголовок экрана в центре
            ToolbarItem(placement: .principal) {
                Image(.addIncubationTitle)
            }
            /// Кнопка "Назад" с обработчиком навигации
            ToolbarItem(placement: .topBarLeading) {
                Image(.backButton)
                    .onTapGesture {
                        // Показываем Tabbar при возврате
                        tabbarService.isTabbarVisible = true
                        appRouter.incubationRoute.removeLast()
                    }
            }
            /// Кнопка "Done" на клавиатуре для скрытия клавиатуры
            ToolbarItem(placement: .keyboard) {
                HStack {
                    Spacer()
                    Button("Done") {
                        // Скрываем клавиатуру принудительно
                        hideKeyboard()
                    }
                    .foregroundColor(.white)
                    .font(.customFont(font: .bold, size: 16))
                }
            }
        }
    }
    
    /// Функция для принудительного скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    NavigationStack {
        AddIncubationView()
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
    }
}
