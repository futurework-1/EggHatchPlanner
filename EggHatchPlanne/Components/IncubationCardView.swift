import SwiftUI

struct IncubationCardView: View {
    
    let tipe: String
    let hatchingDate: String
    
    
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 0) {
            
            VStack(alignment: .leading, spacing: 8) {
                
                HStack(alignment: .center, spacing: 0) {
                    Image(.eggImage1)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 52, height: 52, alignment: .center)
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("📅 HATCHING DATE")
                            .foregroundStyle(.customLightGray)
                            .font(.customFont(font: .bold, size: 12))
                        
                        Text(hatchingDate)
                            .foregroundStyle(.white)
                            .font(.customFont(font: .bold, size: 20))
                        
                    }
                }
                
                Text(tipe)
                    .padding(.vertical, 6)
                    .padding(.horizontal, 6)
                    .foregroundStyle(.white)
                    .font(.customFont(font: .bold, size: 12))
                    .background(RoundedRectangle(cornerRadius: 12).fill(.customGray))
                
            }
            
            Spacer()
            
            Image(.forward)
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 16)
        .frame(maxWidth: .infinity, alignment: .center)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.customDarkGray)
        )
        
    }
}

#Preview {
    ZStack {
        MainBGView()
        IncubationCardView(tipe: "🐔 CHICKEN", hatchingDate: "19.08.2025")
            .padding()
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
