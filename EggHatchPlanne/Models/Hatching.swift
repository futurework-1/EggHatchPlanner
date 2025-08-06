import Foundation
import UIKit

/// Модель записи вылупления
struct Hatching: Codable, Identifiable {
    let id: UUID
    var imageData: Data?
    var chickName: String?
    var tag: String?
    var hatchDate: Date
    var note: String?
    var createdAt: Date
    
    init(
        id: UUID = UUID(),
        imageData: Data? = nil,
        chickName: String? = nil,
        tag: String? = nil,
        hatchDate: Date,
        note: String? = nil,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.imageData = imageData
        self.chickName = chickName
        self.tag = tag
        self.hatchDate = hatchDate
        self.note = note
        self.createdAt = createdAt
    }
    
    /// Вспомогательное свойство для получения UIImage из Data
    var image: UIImage? {
        guard let imageData = imageData else { return nil }
        return UIImage(data: imageData)
    }
}

/// Статистика вылуплений
struct HatchingStatistics {
    let totalHatchings: Int
    let totalEggs: Int
    let successRate: Double
    
    init(hatchings: [Hatching]) {
        self.totalHatchings = hatchings.count
        self.totalEggs = hatchings.count // Упрощенно, можно добавить поле для количества яиц
        self.successRate = hatchings.isEmpty ? 0.0 : 100.0 // Упрощенно, все записи считаются успешными
    }
}
