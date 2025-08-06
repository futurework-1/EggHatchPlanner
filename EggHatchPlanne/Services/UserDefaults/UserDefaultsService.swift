import Foundation

/// Сервис для работы с UserDefaults
/// Централизованное управление пользовательскими настройками и данными
final class UserDefaultsService {
    
    // MARK: - Singleton
    
    static let shared = UserDefaultsService()
    
    // MARK: - Private Properties
    
    private let userDefaults = UserDefaults.standard
    
    // MARK: - Keys
    
    private enum Keys {
        static let incubators = "saved_incubators"
        static let settings = "app_settings"
        static let hatchings = "hatchings"
    }
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Incubators Management
    
    /// Сохранить все инкубаторы
    func saveIncubators(_ incubators: [Incubator]) {
        if let encoded = try? JSONEncoder().encode(incubators) {
            userDefaults.set(encoded, forKey: Keys.incubators)
        }
    }
    
    /// Загрузить все инкубаторы
    func loadIncubators() -> [Incubator] {
        guard let data = userDefaults.data(forKey: Keys.incubators),
              let incubators = try? JSONDecoder().decode([Incubator].self, from: data) else {
            return []
        }
        return incubators
    }
    
    /// Добавить новый инкубатор
    func addIncubator(_ incubator: Incubator) {
        var incubators = loadIncubators()
        incubators.append(incubator)
        saveIncubators(incubators)
    }
    
    /// Обновить существующий инкубатор
    func updateIncubator(_ updatedIncubator: Incubator) {
        var incubators = loadIncubators()
        if let index = incubators.firstIndex(where: { $0.id == updatedIncubator.id }) {
            var incubator = updatedIncubator
            incubators[index] = incubator
            saveIncubators(incubators)
        }
    }
    
    /// Удалить инкубатор
    func deleteIncubator(with id: UUID) {
        var incubators = loadIncubators()
        incubators.removeAll { $0.id == id }
        saveIncubators(incubators)
    }
    
    /// Получить инкубатор по ID
    func getIncubator(by id: UUID) -> Incubator? {
        return loadIncubators().first { $0.id == id }
    }
    
    // MARK: - Hatchings Management
    
    /// Сохранить записи вылуплений
    func saveHatchings(_ hatchings: [Hatching]) {
        if let encoded = try? JSONEncoder().encode(hatchings) {
            userDefaults.set(encoded, forKey: Keys.hatchings)
        }
    }
    
    /// Загрузить записи вылуплений
    func loadHatchings() -> [Hatching] {
        guard let data = userDefaults.data(forKey: Keys.hatchings),
              let hatchings = try? JSONDecoder().decode([Hatching].self, from: data) else {
            return []
        }
        return hatchings
    }
    
    // MARK: - Generic Methods
    
    /// Универсальное сохранение значения по ключу
    func setValue<T>(_ value: T, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }
    
    /// Универсальное получение значения по ключу
    func getValue<T>(forKey key: String, defaultValue: T) -> T {
        return userDefaults.object(forKey: key) as? T ?? defaultValue
    }
    
    /// Удаление значения по ключу
    func removeValue(forKey key: String) {
        userDefaults.removeObject(forKey: key)
    }
    
    /// Очистка всех данных
    func clearAll() {
        userDefaults.dictionaryRepresentation().keys.forEach { key in
            userDefaults.removeObject(forKey: key)
        }
    }
}
