import SwiftUI

struct EditIncubationView: View {
    let incubatorId: UUID
    
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
    
    /// Текущий инкубатор для редактирования
    private var currentIncubator: Incubator? {
        incubatorViewModel.getIncubator(by: incubatorId)
    }
    
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
                    // Обновляем существующий инкубатор
                    updateIncubator()
                }
                //.padding(.bottom, 60)
                .padding(.bottom, AppConfig.isIPhoneSE3rdGeneration ? 120 : 60)
                //Spacer()
            }
            .padding(.horizontal, 20)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

        }
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden()
        .toolbar {
            /// Кнопка "Назад" с обработчиком навигации
            ToolbarItem(placement: .topBarLeading) {
                Image(.backButton)
                    .onTapGesture {
                        // Возвращаемся на экран детального представления
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
        .onAppear {
            // Инициализируем данные существующего инкубатора
            if let incubator = currentIncubator {
                selectedSpecies = incubator.selectedSpecies
                selectedDate = incubator.startDate
                numberOfEggs = incubator.numberOfEggs
                selectedReminders = incubator.reminders
                note = incubator.note
            }
        }
    }
    
    /// Функция для принудительного скрытия клавиатуры
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    /// Обновление существующего инкубатора
    private func updateIncubator() {
        guard let currentIncubator = currentIncubator else { return }
        
        // Создаем обновленный инкубатор с новыми данными
        var updatedIncubator = currentIncubator
        updatedIncubator.selectedSpecies = selectedSpecies
        updatedIncubator.startDate = selectedDate
        updatedIncubator.numberOfEggs = numberOfEggs
        updatedIncubator.reminders = selectedReminders
        updatedIncubator.note = note
        
        // Обновляем дату вылупления на основе нового вида птицы
        updatedIncubator.hatchingDate = Calendar.current.date(byAdding: .day, value: selectedSpecies.incubationDays, to: selectedDate) ?? selectedDate
        
        // Временный вывод для проверки данных
        print("Обновляем инкубатор:")
        print("- Вид птицы: \(selectedSpecies.displayName)")
        print("- Дата: \(selectedDate)")
        print("- Количество яиц: \(numberOfEggs)")
        print("- Напоминания: \(selectedReminders.map { $0.displayName })")
        print("- Заметка: \(note)")
        
        // Обновляем в UserDefaults через ViewModel
        incubatorViewModel.updateIncubator(updatedIncubator)
        
        // Возвращаемся на экран детального представления
        appRouter.incubationRoute.removeLast()
    }
}

#Preview {
    NavigationStack {
        EditIncubationView(incubatorId: UUID())
            .environmentObject(AppRouter())
            .environmentObject(TabbarService())
            .environmentObject(IncubatorViewModel())
    }
}
