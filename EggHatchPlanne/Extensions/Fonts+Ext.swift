import SwiftUI

/// Перечисление доступных стилей шрифта Fredoka
/// Используется для унификации названий шрифтов в приложении
enum Fredoka: String {
    case regular = "Fredoka-Regular"
    case light = "Fredoka-Light"
    case medium = "Fredoka-Medium"
    case semiBold = "Fredoka-SemiBold"
    case bold = "Fredoka-Bold"
}

extension Font {
    /// Создает кастомный шрифт Fredoka с указанным стилем и размером
    /// - Parameters:
    ///   - font: Стиль шрифта из перечисления Fredoka
    ///   - size: Размер шрифта в пунктах
    /// - Returns: Настроенный шрифт SwiftUI
    static func customFont(font: Fredoka, size: CGFloat) -> SwiftUI.Font {
        .custom(font.rawValue, size: size)
    }
}


/// Метод выводит все доступные шрифты в консоль
func printAllFonts() {
    for family in UIFont.familyNames.sorted() {
        print("Family: \(family)")
        for name in UIFont.fontNames(forFamilyName: family) {
            print("   \(name)")
        }
    }
}
