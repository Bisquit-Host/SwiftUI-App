import SwiftUI
import PteroNet
import DeviceKit

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
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] granted, _ in
            guard granted else {
                return
            }
            
            self?.getNotificationSettings(application: application)
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
        
        Task {
            await sendToken(token)
        }
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
        case .authorized:
            break
            
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
}

private func sendToken(_ token: String) async {
    if let pterID = await fetchPterID() {
        postPushToken(pterID: pterID, token: token)
    }
}

private func fetchPterID() async -> Int? {
    do {
        return try await accountDetailsAPI().id
    } catch {
        SystemAlert.error(error)
        return nil
    }
}

private func postPushToken(pterID: Int, token: String) {
    guard
        let url = URL(string: "https://push-activity.bisquit.host/user/push_tokens/add")
    else {
        return
    }
    
    var request = URLRequest(url: url)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body: [String: Any] = [
        "id": pterID,
        "type": "apple",
        "token": token,
        "device": Device.current.description
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    URLSession.shared.dataTask(with: request) { _, _, error in
        if let error {
            print(error.localizedDescription)
        }
    }
    .resume()
}
#endif
