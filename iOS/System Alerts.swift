import SwiftUI
import PteroNet

#if canImport(AlertKit)
import AlertKit
#endif

final class SystemAlert {
#if canImport(AlertKit)
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
#endif
    
    static func error(_ error: Error) {
        if let error = error as? PterError {
#if canImport(AlertKit)
#warning("Add translations")
            DispatchQueue.main.async {
                AlertKitAPI.present(
                    title: "\(error.status) - \(error.code)",
                    subtitle: "\(LocalizedStringResource(stringLiteral: error.detail))",
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
            }
#endif
        }
        
        networkCallError(#function, error)
    }
}
