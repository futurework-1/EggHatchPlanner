import SwiftUI
import WebKit

enum WebViewType {
    case privacyPolicy
    case aboutDeveloper
    
    var title: String {
        switch self {
        case .privacyPolicy: return "Privacy Policy"
        case .aboutDeveloper: return "About Developer"
        }
    }
}

struct WebViewScreen: View {
    let url: URL
    let type: WebViewType
    @EnvironmentObject private var tabbarService: TabbarService

    var body: some View {
        WebView(url: url)
            .navigationTitle(type.title)
            .navigationBarTitleDisplayMode(.inline)
            .ignoresSafeArea(.all, edges: .bottom)
            .onAppear {
                tabbarService.isTabbarVisible = false
            }
            .onDisappear {
                tabbarService.isTabbarVisible = true
            }
    }
}

struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        return WKWebView()
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        uiView.load(request)
    }
}

struct SettingsMainView: View {
    /// Роутер для навигации
    @EnvironmentObject private var appRouter: AppRouter
    /// Сервис управления Tabbar
    @EnvironmentObject private var tabbarService: TabbarService
    
    /// Сервис управления разрешениями на уведомления
    @StateObject private var notificationService = NotificationPermissionService()
    
    /// Переменные для WebView
    @State private var showWebView = false
    @State private var webViewURL: URL?
    @State private var webViewType: WebViewType = .aboutDeveloper
    
    /// Показывать ли алерт очистки истории
    @State private var showClearHistoryAlert = false
    
    /// Показывать ли алерт единиц измерения
    @State private var showUnitMeasurementAlert = false
    
    private let privacyPolicyURL = URL(string: "https://apple.com")
    private let aboutDeveloperURL = URL(string: "https://google.com")
    
    var body: some View {
        NavigationStack(path: $appRouter.settingsRoute) {
            ZStack(alignment: .center) {
                MainBGView()
                
                VStack(alignment: .center, spacing: 12) {
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("NOTIFICATION")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 24))
                        Spacer()
                        Image(notificationService.isNotificationsEnabled ? .toggleOn : .toggleOff)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80, alignment: .center)
                            .onTapGesture {
                                Task {
                                    await notificationService.toggleNotifications()
                                }
                            }
                    }
                    .padding(.horizontal)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    .padding(.top, 20)
                    .onTapGesture {
                        Task {
                            await notificationService.toggleNotifications()
                        }
                    }
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("UNIT OF MEASUREMENT")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 20))
                        Spacer()
                        Image(.forward)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40, alignment: .center)
                            .onTapGesture {
                                showUnitMeasurementAlert = true
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    .onTapGesture {
                        showUnitMeasurementAlert = true
                    }
                    
                    HStack(alignment: .center, spacing: 0) {
                        Text("HISTORY CLEAN")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 24))
                        Spacer()
                        Text("CLEAR")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 24))
                            .onTapGesture {
                                showClearHistoryAlert = true
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 24)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    
                    /// PRIVACY POLICY
                    HStack(alignment: .center, spacing: 0) {
                        Text("PRIVACY POLICY")
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 20))
                        Spacer()
                        Image(.forward)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40, alignment: .center)
                            .onTapGesture {
                                webViewType = .privacyPolicy
                                webViewURL = privacyPolicyURL
                                showWebView = true
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    
                    /// ABOUT DEVELOPER
                    HStack(alignment: .center, spacing: 0) {
                        Text("ABOUT DEVELOPER")
                            .foregroundStyle(.white)
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 20))
                        Spacer()
                        Image(.forward)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 40, height: 40, alignment: .center)
                            .onTapGesture {
                                webViewType = .aboutDeveloper
                                webViewURL = aboutDeveloperURL
                                showWebView = true
                            }
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 20)
                    .background(RoundedRectangle(cornerRadius: 20).fill(.customDarkGray))
                    
                }
                .padding(.top, 120)
                .padding(.horizontal, 28)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
                
            }
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden()
            .navigationDestination(isPresented: $showWebView) {
                if let url = webViewURL {
                    WebViewScreen(url: url, type: webViewType)
                }
            }
            .alert("Clear History", isPresented: $showClearHistoryAlert) {
                Button("Clear") {
                    clearHistory()
                }
                .foregroundColor(.red)
                
                Button("Cancel") {
                    // Просто закрываем алерт
                }
                .foregroundColor(.blue)
            } message: {
                Text("Are you sure you want to clear all history?")
            }
            .overlay {
                if showUnitMeasurementAlert {
                    ZStack {
                        Color.black.opacity(0.5)
                            .ignoresSafeArea()
                        
                        CustomSettingsAlert(isPresented: $showUnitMeasurementAlert)
                            .padding(.horizontal, 28)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Image(.settingsTitle)
                       // .padding(.top, 40)
                }
            }
            .onAppear {
                // Проверяем текущий статус разрешений при появлении экрана
                Task {
                    await notificationService.checkCurrentStatus()
                }
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Очистка истории
    private func clearHistory() {
        // Очищаем все данные из UserDefaults
        UserDefaults.standard.removeObject(forKey: "saved_incubators")
        UserDefaults.standard.removeObject(forKey: "hatchings")
        UserDefaults.standard.removeObject(forKey: "notifications_enabled")
        UserDefaults.standard.removeObject(forKey: "selected_interval")
        UserDefaults.standard.removeObject(forKey: "selected_time")
        UserDefaults.standard.removeObject(forKey: "selected_days")
        UserDefaults.standard.removeObject(forKey: "egg_turning_checked")
        UserDefaults.standard.removeObject(forKey: "egg_turning_time")
        
        // Очищаем все остальные возможные ключи
        UserDefaults.standard.removeObject(forKey: "app_settings")
        
        // Удаляем все сохраненные галочки инкубаторов
        removeAllIncubatorReminders()
        
        print("История полностью очищена")
    }
    
    /// Удаление всех сохраненных галочек инкубаторов
    private func removeAllIncubatorReminders() {
        let userDefaults = UserDefaults.standard
        let allKeys = userDefaults.dictionaryRepresentation().keys
        
        // Удаляем все ключи, которые начинаются с "incubator_" и заканчиваются на "_reminders"
        for key in allKeys {
            if key.hasPrefix("incubator_") && key.hasSuffix("_reminders") {
                userDefaults.removeObject(forKey: key)
            }
        }
    }
}

#Preview {
    SettingsMainView()
        .environmentObject(AppRouter())
        .environmentObject(TabbarService())
}
