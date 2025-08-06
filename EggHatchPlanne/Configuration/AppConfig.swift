import SwiftUI

/// Централизованная конфигурация приложения
///
/// Этот файл содержит все константы и настройки, которые используются
/// в приложении. Изменение значений здесь автоматически применяется
/// ко всем частям приложения.

struct AppConfig {
    /// Высота таббара
    static let tabbarHeight: CGFloat = 78
    /// Отступ таббара снизу
    static let tabbarBottomPadding: CGFloat = 46
    /// Отступ таббара по бокам
    static let tabbarHorizontalPadding: CGFloat = 28
    
    /// Проверка, является ли устройство iPhone SE 3rd generation
    static var isIPhoneSE3rdGeneration: Bool {
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight == 667
    }
    
    /// Адаптивная высота таббара в зависимости от устройства
    /// iPhone SE 3rd generation (667 points) получает +сколько-то к высоте
    static var adaptiveTabbarHeight: CGFloat {
        isIPhoneSE3rdGeneration ? tabbarHeight - 12 : tabbarHeight
    }
    
    /// Адаптивный отступ таббара снизу в зависимости от устройства
    /// iPhone SE 3rd generation (667 points) получает +сколько-то к отступу
    static var adaptiveTabbarBottomPadding: CGFloat {
        isIPhoneSE3rdGeneration ? 0 : tabbarBottomPadding
    }
}
