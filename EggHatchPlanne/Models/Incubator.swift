import Foundation

/// Виды птиц для инкубации
enum BirdSpecies: String, CaseIterable, Codable {
    case chicken = "CHICKEN"
    case duck = "DUCK"
    case goose = "GOOSE"
    case turkey = "TURKEY"
    case guineaFlow = "GUINEA FOWL"
    
    var displayName: String {
        switch self {
        case .chicken:
            return "🐔 CHICKEN"
        case .duck:
            return "🦆 DUCK"
        case .goose:
            return "🦆 GOOSE"
        case .turkey:
            return "🦃 TURKEY"
        case .guineaFlow:
            return "🐤 GUINEA FOWL"
        }
    }
    
    /// Количество дней инкубации для каждого вида птицы
    var incubationDays: Int {
        switch self {
        case .chicken:
            return 21
        case .duck:
            return 28
        case .goose:
            return 30
        case .turkey:
            return 28
        case .guineaFlow:
            return 27
        }
    }
}

/// Типы напоминаний для инкубации
enum ReminderType: String, CaseIterable, Codable {
    case turnEggs = "TURN EGGS"
    case checkTemperature = "CHECK TEMPERATURE"
    case checkHumidity = "CHECK HUMIDITY"
    
    var displayName: String {
        return self.rawValue
    }
}

/// Модель данных для инкубатора
struct Incubator: Identifiable, Codable {
    /// Уникальный идентификатор
    var id = UUID()
    /// Выбранный вид птицы
    var selectedSpecies: BirdSpecies
    /// Дата начала инкубации
    var startDate: Date
    /// Дата вылупления (рассчитывается автоматически)
    var hatchingDate: Date
    /// Количество яиц
    var numberOfEggs: Int
    /// Список активных напоминаний
    var reminders: [ReminderType]
    /// Заметка
    var note: String
    /// Дата создания записи
    var createdAt: Date = Date()
    
    init(
        selectedSpecies: BirdSpecies,
        startDate: Date = Date(),
        numberOfEggs: Int,
        reminders: [ReminderType] = [],
        note: String = ""
    ) {
        self.selectedSpecies = selectedSpecies
        self.startDate = startDate
        // Рассчитываем дату вылупления на основе вида птицы
        self.hatchingDate = Calendar.current.date(byAdding: .day, value: selectedSpecies.incubationDays, to: startDate) ?? startDate
        self.numberOfEggs = numberOfEggs
        self.reminders = reminders
        self.note = note
    }
}
