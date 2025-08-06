import Foundation

/// Сервис управления Tabbar.
final class TabbarService: ObservableObject {
    /// Флаг, указывающий, отображается ли Tabbar.
    @Published var isTabbarVisible: Bool = true
}
