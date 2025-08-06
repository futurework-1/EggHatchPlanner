import SwiftUI

struct IncubatorItemView: View {
    let incubator: Incubator
    @State private var displayedReminders: [ReminderType] = []
    @EnvironmentObject private var appRouter: AppRouter
    @EnvironmentObject private var tabbarService: TabbarService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Показываем заголовок напоминаний только если есть выбранные напоминания
            if !incubator.reminders.isEmpty {
                HStack {
                    Text("⏰ DAILY REMAINDERS")
                        .foregroundStyle(.white)
                        .font(.customFont(font: .bold, size: 16))
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // Показываем только те напоминания, которые были выбраны пользователем
                ForEach(incubator.reminders, id: \.self) { reminder in
                    ChekBoxView(
                        text: reminder.displayName,
                        reminderType: reminder,
                        selectedReminders: $displayedReminders
                    )
                }
                .padding(.bottom, 8)
            }
            
            // Отображаем IncubationCardView с данными инкубатора
            IncubationCardView(
                tipe: incubator.selectedSpecies.displayName,
                hatchingDate: incubator.hatchingDate.formattedDate
            )
        }
        .onTapGesture {
            // Скрываем Tabbar при переходе на детальный экран
            tabbarService.isTabbarVisible = false
            // Переходим на экран деталей с ID инкубатора
            appRouter.incubationRoute.append(.detail(incubatorId: incubator.id))
        }
    }
}

#Preview {
    ZStack {
        MainBGView()
        IncubatorItemView(incubator: Incubator(
            selectedSpecies: .chicken,
            startDate: Date(),
            numberOfEggs: 12,
            reminders: [.turnEggs, .checkTemperature],
            note: "Test note"
        ))
        .environmentObject(AppRouter())
        .environmentObject(TabbarService())
        .padding(.horizontal)
    }
}
