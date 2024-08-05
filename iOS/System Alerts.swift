import SwiftUI

#if canImport(AlertKit)
import AlertKit

final class SystemAlert {
    static func copied() {
        AlertKitAPI.present(
            title: NSLocalizedString("Copied", comment: ""),
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    static func networkError() {
        AlertKitAPI.present(
            title: NSLocalizedString("Network Error", comment: ""),
            icon: .custom(UIImage(systemName: "exclamationmark.triangle")!),
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    static func error(_ title: String, subtitle: String?) {
        AlertKitAPI.present(
            title: title,
            subtitle: subtitle,
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
}
#endif
