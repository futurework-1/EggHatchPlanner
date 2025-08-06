import Foundation

extension Date {
    /// Форматирует дату в формате "dd.MM.yyyy"
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: self)
    }
    
    /// Форматирует дату в формате "dd.MM.yyyy HH:mm"
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy HH:mm"
        return formatter.string(from: self)
    }
    
    /// Форматирует дату в формате "dd MMM yyyy"
    var formattedDateLong: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd MMM yyyy"
        return formatter.string(from: self)
    }
}
