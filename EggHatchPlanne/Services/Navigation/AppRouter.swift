import Foundation
import SwiftUI

/// Управляет маршрутами экранов приложения.
/// Отвечает за навигацию между основными экранами и вкладками.

final class AppRouter: ObservableObject {
    /// Текущий основной экран приложения
    @Published var currentMainScreen: AppMainScreen = .splash
    
    /// Стек экранов вкладки "incubation"
    @Published var incubationRoute: [IncubationScreen] = []
    
    /// Стек экранов вкладки "care"
    @Published var careRoute: [CareScreen] = []
    
    /// Стек экранов вкладки "hatching"
    @Published var hatchingRoute: [HatchingScreen] = []
    
    /// Стек экранов вкладки "settings"
    @Published var settingsRoute: [SettingsScreen] = []
    
    /// Флаг для переключения экрана
    @Published var showMainScreen: Bool = false
}

// MARK: - Основные экраны приложения

/// Основные экраны приложения.
/// Определяет глобальную навигацию между основными разделами.
enum AppMainScreen {
    case splash        // Экран загрузки приложения
    case tabbar        // Главный экран с табами
}

// MARK: - Экраны вкладки "incubation"

/// Экраны вкладки "incubation".
enum IncubationScreen: Hashable {
    case main
    case addincubation
    case detail(incubatorId: UUID)
    case edit(incubatorId: UUID)
}

// MARK: - Экраны вкладки "care"

/// Экраны вкладки "care".
enum CareScreen {
    case main
    case careSetings
}

// MARK: - Экраны вкладки "hatching"

/// Экраны вкладки "hatching".
enum HatchingScreen {
    case main
    case addStep1
    case addStep2
    case detail
    case edit
}

// MARK: - Экраны вкладки "settings"

/// Экраны вкладки "settings".
enum SettingsScreen {
    case main
}

// MARK: - Вкладки приложения с индексами

/// Вкладки приложения с индексами.
/// Определяет порядок и индексы вкладок в TabBar.
enum AppTabScreen {
    case incubation
    case care
    case hatching
    case settings
    
    /// Индекс для выбранной вкладки.
    var selectedTabScreenIndex: Int {
        switch self {
        case .incubation:
            return 0
        case .care:
            return 1
        case .hatching:
            return 2
        case .settings:
            return 3
        }
    }
}
