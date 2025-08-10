import Foundation
import UserNotifications
import SwiftUI

/// Сервис для управления разрешениями на уведомления
class NotificationPermissionService: ObservableObject {
    
    /// Текущий статус разрешения на уведомления
    @Published var isNotificationsEnabled: Bool = false
    
    /// Инициализация сервиса
    init() {
        loadNotificationStatus()
    }
    
    /// Загружает текущий статус уведомлений
    private func loadNotificationStatus() {
        isNotificationsEnabled = UserDefaults.standard.bool(forKey: "notifications_enabled")
    }
    
    /// Запрашивает разрешение на уведомления
    func requestNotificationPermission() async -> Bool {
        let center = UNUserNotificationCenter.current()
        
        // Проверяем текущий статус
        let settings = await center.notificationSettings()
        
        switch settings.authorizationStatus {
        case .notDetermined:
            // Запрашиваем разрешение - покажет нативный алерт iOS
            do {
                let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
                await MainActor.run {
                    self.isNotificationsEnabled = granted
                    UserDefaults.standard.set(granted, forKey: "notifications_enabled")
                }
                return granted
            } catch {
                await MainActor.run {
                    self.isNotificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: "notifications_enabled")
                }
                return false
            }
            
        case .authorized, .provisional, .ephemeral:
            // Разрешение уже получено
            await MainActor.run {
                self.isNotificationsEnabled = true
                UserDefaults.standard.set(true, forKey: "notifications_enabled")
            }
            return true
            
        case .denied:
            // Пользователь отказал в доступе
            await MainActor.run {
                self.isNotificationsEnabled = false
                UserDefaults.standard.set(false, forKey: "notifications_enabled")
            }
            return false
            
        @unknown default:
            // Неизвестный статус
            await MainActor.run {
                self.isNotificationsEnabled = false
                UserDefaults.standard.set(false, forKey: "notifications_enabled")
            }
            return false
        }
    }
    
    /// Переключает состояние уведомлений
    func toggleNotifications() async {
        if isNotificationsEnabled {
            // Выключаем уведомления
            await MainActor.run {
                self.isNotificationsEnabled = false
                UserDefaults.standard.set(false, forKey: "notifications_enabled")
            }
        } else {
            // Включаем уведомления - запрашиваем разрешение
            let granted = await requestNotificationPermission()
            if !granted {
                // Если разрешение не получено, тогл остается выключенным
                await MainActor.run {
                    self.isNotificationsEnabled = false
                    UserDefaults.standard.set(false, forKey: "notifications_enabled")
                }
            }
        }
    }
    
    /// Проверяет текущий статус разрешения
    func checkCurrentStatus() async {
        let center = UNUserNotificationCenter.current()
        let settings = await center.notificationSettings()
        
        await MainActor.run {
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                self.isNotificationsEnabled = true
            case .denied, .notDetermined:
                self.isNotificationsEnabled = false
            @unknown default:
                self.isNotificationsEnabled = false
            }
            UserDefaults.standard.set(self.isNotificationsEnabled, forKey: "notifications_enabled")
        }
    }
}
