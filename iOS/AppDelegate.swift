import SwiftUI
import Calagopus
import OSLog

#if canImport(Contacts)
import Contacts
#endif

#if !os(macOS)
final class AppDelegate: UIResponder, UIApplicationDelegate {
    static var pendingShortcutItem: UIApplicationShortcutItem?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        registerForPushNotifications(application)
        
        if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
            Self.pendingShortcutItem = shortcutItem
            return false
        }
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        completionHandler(HomeScreenQuickAction.handle(shortcutItem))
    }
    
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        if let shortcutItem = options.shortcutItem {
            Self.pendingShortcutItem = shortcutItem
        }
        
        let configuration = UISceneConfiguration(name: connectingSceneSession.configuration.name, sessionRole: connectingSceneSession.role)
        configuration.delegateClass = SceneDelegate.self
        
        return configuration
    }
    
    private func registerForPushNotifications(_ application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, _ in
            guard granted else { return }
            
            Task { @MainActor in
                self.getNotificationSettings(application)
            }
        }
    }
    
    private func getNotificationSettings(_ application: UIApplication) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else { return }
            
            Task { @MainActor in
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }
        
        let token = tokenParts.joined()
        
        Logger().info("Push token: \(token)")
        ValueStore().pushToken = token
        
        Task {
            guard let accessToken = accessToken() else { return }
            
            await PushTokenService.sendIfPossible(accessToken: accessToken, pushToken: token)
        }
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        Logger().error("Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - Contacts
#if os(iOS)
    func requestPermission() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { _, error in
                Logger().error("Error requesting permissions: \(error?.localizedDescription ?? "Unknown")")
            }
            
        default:
            break
        }
    }
#endif
}
#endif
