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
        let image = UIImage(systemName: "exclamationmark.triangle")!
        
        AlertKitAPI.present(
            title: NSLocalizedString("Network Error", comment: ""),
            icon: .custom(image),
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
    
    static func restored() {
#if canImport(AlertKit)
        main {
            AlertKitAPI.present(
                title: "Restored",
                subtitle: "The server has been restored",
                icon: .done,
                style: .iOS17AppleMusic,
                haptic: .success
            )
        }
#endif
    }
    
    static func reinstalled() {
#if canImport(AlertKit)
        main {
            AlertKitAPI.present(
                title: "Reinstalled",
                subtitle: "The server has been reinstalled",
                icon: .done,
                style: .iOS17AppleMusic,
                haptic: .success
            )
        }
#endif
    }
    
    static func changesSaved() {
#if canImport(AlertKit)
        main {
            AlertKitAPI.present(
                title: "Changes Saved",
                subtitle: "The file has been saved",
                icon: .done,
                style: .iOS17AppleMusic,
                haptic: .success
            )
        }
#endif
    }
    
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
                    title: title,
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
