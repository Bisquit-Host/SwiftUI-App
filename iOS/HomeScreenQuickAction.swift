#if os(iOS)
import UIKit

enum HomeScreenQuickAction {
    static let topupType = "host.bisquit.Bisquit-Host.quick-action.top-up"
    static let topupNotification = Notification.Name("HomeScreenQuickAction.topup")
    
    static func isTopup(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        shortcutItem.type == topupType
    }
    
    static func handle(_ shortcutItem: UIApplicationShortcutItem) -> Bool {
        guard isTopup(shortcutItem) else {
            return false
        }
        
        NotificationCenter.default.post(name: topupNotification, object: nil)
        return true
    }
}
#endif
