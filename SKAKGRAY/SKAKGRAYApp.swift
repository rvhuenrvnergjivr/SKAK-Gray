import SwiftUI
import UIKit
import AppsFlyerLib
import AppTrackingTransparency

@main
struct ProjectApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
     
    var body: some Scene {
        WindowGroup {
            ContentViewSKAKGRAY()
        }
    }
}



class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        print("🚀 AppDelegate start")
        
        UNUserNotificationCenter.current().delegate = self
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            print("🔔 Push permission: \(granted)")
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    self.requestTrackingAuthorization()
                }
            }
        }
        UIApplication.shared.registerForRemoteNotifications()
        
        AppsFlyerLib.shared().appsFlyerDevKey = ConstantSKAKGRAY.appsFlyerDevKey
        AppsFlyerLib.shared().appleAppID     = ConstantSKAKGRAY.appID
        AppsFlyerLib.shared().delegate       = self
        
        AppsFlyerLib.shared().start()
        
        return true
    }
    
    func application(_ application: UIApplication,
                         didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
            let token = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        UserDefaults.standard.set(token, forKey: "apnToken")
            print("📲 APNs Token:", token)
        }

        func application(_ application: UIApplication,
                         didFailToRegisterForRemoteNotificationsWithError error: Error) {
            print("❌ Failed to register:", error.localizedDescription)
        }
    
    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
    
    private func requestTrackingAuthorization() {
            if #available(iOS 14, *) {
                ATTrackingManager.requestTrackingAuthorization { status in
                    switch status {
                    case .authorized:
                        print("123 ✅ Tracking разрешён")
                    case .denied:
                        print("13 ❌ Пользователь отказал")
                    case .restricted:
                        print("123 ⚠️ Ограничено настройками")
                    case .notDetermined:
                        print("123 ⌛ Пользователь ещё не сделал выбор")
                    @unknown default:
                        break
                    }
                    
                    self.makeRequest()
                }
            } else {
                print("123 ATT недоступен, можно сразу использовать IDFA")
                self.makeRequest()
            }
        }

    func makeRequest() {
        var urlString = UserDefaults.standard.string(forKey: "urlString")
        
        guard urlString == nil || (urlString ?? "").isEmpty else { return }
        
        let builder = LinkBuilderSKAKGRAY()
    }
}


extension AppDelegate: AppsFlyerLibDelegate {
    func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        print("✅ AppsFlyer conversion data: \(conversionInfo)")

        if let afattr = getAFAttr(from: conversionInfo) {
            UserDefaults.standard.set(afattr, forKey: "AFAttr")
        }
    }

    func onConversionDataFail(_ error: Error) {
        print("❌ AppsFlyer conversion error: \(error.localizedDescription)")
        
        #if DEBUG
        UserDefaults.standard.set("example", forKey: "AFAttr")
        #endif
    }
}

func getAFAttr(from conversionData: [AnyHashable: Any]) -> String? {
    // 1️⃣ Перетворюємо словник у JSON Data
    guard let jsonData = try? JSONSerialization.data(withJSONObject: conversionData, options: []) else {
        print("❌ Failed to serialize AF conversion data to JSON")
        return nil
    }

    // 2️⃣ Перетворюємо Data у String
    guard let jsonString = String(data: jsonData, encoding: .utf8) else {
        print("❌ Failed to convert JSON data to String")
        return nil
    }

    // 3️⃣ URL-кодуємо рядок (RFC 1738)
    let allowedCharacterSet = CharacterSet(charactersIn: "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789-._~")
    let encodedString = jsonString.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet)

    return encodedString
}
