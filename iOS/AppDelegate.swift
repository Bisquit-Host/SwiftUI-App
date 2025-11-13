import SwiftUI
import PteroNet
@preconcurrency import CryptoKit

#if canImport(Contacts)
import Contacts
#endif

#if !os(macOS)
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        registerForPushNotifications(application)
        
        return true
    }
    
    private func registerForPushNotifications(_ application: UIApplication) {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge]
        
        UNUserNotificationCenter.current().requestAuthorization(options: options) { granted, _ in
            guard granted else {
                return
            }
            
            Task { @MainActor in
                self.getNotificationSettings(application: application)
            }
        }
    }
    
    private func getNotificationSettings(application: UIApplication) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized else {
                return
            }
            
            DispatchQueue.main.async {
                application.registerForRemoteNotifications()
            }
        }
    }
    
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        let tokenParts = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }
        
        let token = tokenParts.joined()
        
        print("Push token:", token)
        ValueStore().pushToken = token
#if !DEBUG
        Task {
            await sendPushToken(token)
        }
#endif
    }
    
    func application(
        _ application: UIApplication,
        didFailToRegisterForRemoteNotificationsWithError error: Error
    ) {
        print("Failed to register for remote notifications:", error)
    }
    
    // MARK: - Contacts
#if os(iOS)
    func requestPermission() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { _, error in
                if let error {
                    print("Error requesting permissions:", error)
                }
            }
            
        default:
            break
        }
    }
#endif
    private func sendPushToken(_ token: String) async {
        let link = "https://push-activity.bisquit.host/token/save"
        
        guard let url = URL(string: link) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        guard let deviceID = UIDevice.current.identifierForVendor?.uuidString else {
            return
        }
        
        let data = Data(deviceID.utf8)
        
        let hashedDeviceID = SHA512.hash(data: data).compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        let body = [
            "token": token,
            "device_id": hashedDeviceID
        ]
        
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
        
        do {
            let (_, _) = try await URLSession.shared.data(for: request)
        } catch {
            print(error.localizedDescription)
        }
    }
}
#endif
