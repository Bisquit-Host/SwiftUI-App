import ScrechKit
import PteroNet

#if canImport(AlertKit)
import AlertKit
#endif

final class SystemAlert {
#if canImport(AlertKit)
    
    @MainActor
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
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    @MainActor
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
    
    @MainActor
    static func restored() {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: "Restored",
            subtitle: "The server has been restored",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
    @MainActor
    static func reinstalled() {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: "Reinstalled",
            subtitle: "The server has been reinstalled",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
    @MainActor
    static func changesSaved() {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: "Changes Saved",
            subtitle: "The file has been saved",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
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
            
            AlertKitAPI.present(
                title: title,
                icon: .error,
                style: .iOS17AppleMusic,
                haptic: .error
            )
        }
#endif
        networkCallError(#function, error)
    }
}
