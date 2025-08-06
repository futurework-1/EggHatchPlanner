import Foundation
import SwiftUI

/// ViewModel для управления состоянием инкубаторов
final class IncubatorViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Все инкубаторы пользователя
    @Published var allIncubators: [Incubator] = []
    
    /// Отфильтрованные инкубаторы
    @Published var filteredIncubators: [Incubator] = []
    
    /// Текущий редактируемый/просматриваемый инкубатор
    @Published var currentIncubator: Incubator?
    
    /// Показывать ли Alert подтверждения удаления
    @Published var showDeleteAlert = false
    
    /// ID инкубатора для удаления
    @Published var incubatorToDelete: UUID?
    
    /// Callback для выполнения после успешного удаления
    var onIncubatorDeleted: (() -> Void)?
    
    // MARK: - Private Properties
    
    private let userDefaultsService = UserDefaultsService.shared
    
    // MARK: - Initialization
    
    init() {
        loadAllData()
    }
    
    // MARK: - Data Loading
    
    /// Загрузить все данные из UserDefaults
    func loadAllData() {
        allIncubators = userDefaultsService.loadIncubators()
        applyFilter()
    }
    
    // MARK: - Incubator Management
    
    /// Добавить новый инкубатор
    func addIncubator(_ incubator: Incubator) {
        userDefaultsService.addIncubator(incubator)
        loadAllData()
    }
    
    /// Обновить существующий инкубатор
    func updateIncubator(_ incubator: Incubator) {
        userDefaultsService.updateIncubator(incubator)
        loadAllData()
    }
    
    /// Удалить инкубатор
    func deleteIncubator(with id: UUID) {
        userDefaultsService.deleteIncubator(with: id)
        loadAllData()
    }
    
    /// Показать Alert подтверждения удаления
    func showDeleteConfirmation(for incubatorId: UUID) {
        incubatorToDelete = incubatorId
        showDeleteAlert = true
    }
    
    /// Подтвердить удаление инкубатора
    func confirmDelete() {
        if let id = incubatorToDelete {
            deleteIncubator(with: id)
            // Вызываем callback после успешного удаления
            onIncubatorDeleted?()
        }
        incubatorToDelete = nil
        showDeleteAlert = false
    }
    
    /// Отменить удаление
    func cancelDelete() {
        incubatorToDelete = nil
        showDeleteAlert = false
    }
    
    // MARK: - Filtering
    
    /// Применить фильтр
    func applyFilter() {
        // Пока что без фильтрации, можно добавить позже
        filteredIncubators = allIncubators
    }
    
    /// Получить инкубаторы для отображения
    func getDisplayedIncubators() -> [Incubator] {
        return allIncubators
    }
    
    // MARK: - Navigation Helpers
    
    /// Установить текущий инкубатор для редактирования/просмотра
    func setCurrentIncubator(_ incubator: Incubator?) {
        currentIncubator = incubator
    }
    
    /// Получить инкубатор по ID
    func getIncubator(by id: UUID) -> Incubator? {
        return userDefaultsService.getIncubator(by: id)
    }
    
    // MARK: - Validation
    
    /// Проверить, валидны ли данные инкубатора для сохранения
    func isIncubatorValid(_ incubator: Incubator) -> Bool {
        return incubator.numberOfEggs > 0 &&
               !incubator.note.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - Date Formatting Helpers
    
    /// Получить отформатированную дату вылупления для инкубатора
    func getFormattedHatchingDate(for incubator: Incubator) -> String {
        return incubator.hatchingDate.formattedDate
    }
    
    /// Получить отформатированную дату начала для инкубатора
    func getFormattedStartDate(for incubator: Incubator) -> String {
        return incubator.startDate.formattedDate
    }
    
    /// Получить количество оставшихся дней до вылупления
    func getRemainingDays(for incubator: Incubator) -> Int {
        let calendar = Calendar.current
        let today = Date()
        let hatchingDate = incubator.hatchingDate
        
        let components = calendar.dateComponents([.day], from: today, to: hatchingDate)
        return components.day ?? 0
    }
    
    /// Проверить, вылупились ли уже яйца
    func isHatched(for incubator: Incubator) -> Bool {
        return Date() >= incubator.hatchingDate
    }
}
