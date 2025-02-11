import ScrechKit
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
#if canImport(AlertKit)
        if let error = error as? PterError {
            var title = error.detail
            
            if title.last == "." {
                title.removeLast()
            }
            
            print("Error: \(error.status) - \(error.code)")
            
            main {
                AlertKitAPI.present(
                    title: error.detail,
                    icon: .error,
                    style: .iOS17AppleMusic,
                    haptic: .error
                )
            }
        }
#endif
        
        networkCallError(#function, error)
    }
}
