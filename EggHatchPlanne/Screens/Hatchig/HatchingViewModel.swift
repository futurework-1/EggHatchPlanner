import Foundation
import SwiftUI
import UIKit

/// ViewModel для управления данными вылуплений
final class HatchingViewModel: ObservableObject {
    
    // MARK: - Published Properties
    
    /// Все записи вылуплений
    @Published var hatchings: [Hatching] = []
    
    /// Текущая выбранная запись для детального просмотра
    @Published var selectedHatching: Hatching?
    
    // MARK: - Temporary Data for Creating New Hatching
    
    /// Временные данные для создания новой записи
    var tempImageData: Data?
    var tempSelectedDate: Date?
    var tempComment: String?
    
    // MARK: - Private Properties
    
    private let userDefaultsService = UserDefaultsService.shared
    
    // MARK: - Initialization
    
    init() {
        loadHatchings()
    }
    
    // MARK: - Public Methods
    
    /// Добавить новую запись вылупления
    func addHatching(_ hatching: Hatching) {
        hatchings.append(hatching)
        saveHatchings()
    }
    
    /// Обновить существующую запись вылупления
    func updateHatching(_ hatching: Hatching) {
        if let index = hatchings.firstIndex(where: { $0.id == hatching.id }) {
            hatchings[index] = hatching
            saveHatchings()
        }
    }
    
    /// Удалить запись вылупления
    func deleteHatching(withId id: UUID) {
        hatchings.removeAll { $0.id == id }
        saveHatchings()
    }
    
    /// Получить запись вылупления по ID
    func getHatching(withId id: UUID) -> Hatching? {
        return hatchings.first { $0.id == id }
    }
    
    /// Получить статистику вылуплений
    func getHatchingStatistics() -> HatchingStatistics {
        return HatchingStatistics(hatchings: hatchings)
    }
    
    /// Выбрать запись для детального просмотра
    func selectHatching(withId id: UUID) {
        selectedHatching = hatchings.first { $0.id == id }
    }
    
    // MARK: - Temporary Data Management
    
    /// Сохранить данные из первого экрана
    func saveTempData(imageData: Data?, selectedDate: Date?, comment: String?) {
        tempImageData = imageData
        tempSelectedDate = selectedDate
        tempComment = comment?.isEmpty == true ? nil : comment
    }
    
    /// Создать и сохранить новую запись с данными из обоих экранов
    func createHatchingFromTempData(chickName: String?, tag: String?) {
        let newHatching = Hatching(
            imageData: tempImageData,
            chickName: chickName?.isEmpty == true ? nil : chickName,
            tag: tag?.isEmpty == true ? nil : tag,
            hatchDate: tempSelectedDate ?? Date(),
            note: tempComment
        )
        
        addHatching(newHatching)
        clearTempData()
    }
    
    /// Очистить временные данные
    func clearTempData() {
        tempImageData = nil
        tempSelectedDate = nil
        tempComment = nil
    }
    
    /// Создать тестовые данные для Preview
    func createTestData() {
        // Создаем тестовое изображение (простой квадрат)
        let testImageData = createTestImageData()
        
        let testHatchings = [
            Hatching(
                imageData: testImageData,
                chickName: "Speedy",
                tag: "first",
                hatchDate: Date().addingTimeInterval(-86400 * 7), // 7 дней назад
                note: "Hatched overnight, looked strong!"
            ),
            Hatching(
                imageData: testImageData,
                chickName: "Fluffy",
                tag: "second",
                hatchDate: Date().addingTimeInterval(-86400 * 14), // 14 дней назад
                note: "Very active chick"
            ),
            Hatching(
                imageData: testImageData,
                chickName: "Pepper",
                tag: "third",
                hatchDate: Date().addingTimeInterval(-86400 * 21), // 21 день назад
                note: "Beautiful coloring"
            )
        ]
        
        hatchings = testHatchings
    }
    
    /// Создать тестовые данные изображения
    private func createTestImageData() -> Data? {
        // Создаем простое тестовое изображение программно
        let size = CGSize(width: 100, height: 100)
        let renderer = UIGraphicsImageRenderer(size: size)
        
        let image = renderer.image { context in
            // Рисуем простой цветной квадрат для тестов
            UIColor.systemYellow.setFill()
            context.fill(CGRect(origin: .zero, size: size))
            
            // Добавляем простой круг в центре
            UIColor.systemOrange.setFill()
            let circleRect = CGRect(x: 25, y: 25, width: 50, height: 50)
            context.cgContext.fillEllipse(in: circleRect)
        }
        
        return image.jpegData(compressionQuality: 0.8)
    }
    
    // MARK: - Private Methods
    
    /// Загрузить записи вылуплений из UserDefaults
    private func loadHatchings() {
        hatchings = userDefaultsService.loadHatchings()
    }
    
    /// Сохранить записи вылуплений в UserDefaults
    private func saveHatchings() {
        userDefaultsService.saveHatchings(hatchings)
    }
}
