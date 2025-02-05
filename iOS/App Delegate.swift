import SwiftUI
import PteroNet

#if canImport(Contacts)
import Contacts
#endif

#if !os(macOS)
final class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        if ValueStore().isApiKeyValid {
            registerForPushNotifications(application: application)
        }
        
        return true
    }
    
    // MARK: - Contacts
#if os(iOS)
    func requestPermission() {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized:
            break
            
        case .denied, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, error in
                if let error {
                    print("Error requesting permissions: \(error)")
                }
            }
            
        default:
            break
        }
    }
#endif
    
    private func registerForPushNotifications(application: UIApplication) {
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
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        let tokenParts = deviceToken.map {
            String(format: "%02.2hhx", $0)
        }
        
        let token = tokenParts.joined()
        
        print("Device Token: \(token)")
        
        sendToken(token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error)")
    }
}

private func sendToken(_ token: String) {
    fetchEmail { email in
        if let email {
            postPushToken(email: email, token: token)
        }
    }
}

private func fetchEmail(completion: @escaping (String?) -> Void) {
    accountDetailsAPI { result in
        switch result {
        case .success(let model):
            completion(model?.attributes.email)
            
        case .failure(let error):
            SystemAlert.error(error)
            completion(nil)
        }
    }
}

private func postPushToken(email: String, token: String) {
    let url = URL(string: "http://api.topscrech.dev/user/push_tokens/add")
    
    var request = URLRequest(url: url!)
    request.httpMethod = "POST"
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")
    
    let body = [
        "email": email,
        "type": "Apple",
        "token": token
    ]
    
    request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])
    
    URLSession.shared.dataTask(with: request) { _, _, error in
        guard error == nil else {
            print(error?.localizedDescription ?? "Unknown error")
            return
        }
    }
    .resume()
}
#endif
