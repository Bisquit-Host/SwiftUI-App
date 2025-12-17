import ScrechKit
import PteroNet

#if canImport(AlertKit)
import AlertKit
#endif

final class SystemAlert {
#if canImport(AlertKit)
    static func done(_ title: String, subtitle: String? = nil) {
        AlertKitAPI.present(
            title: title,
            subtitle: subtitle,
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    static func copied(_ title: String = "Copied") {
        AlertKitAPI.present(
            title: NSLocalizedString(title, comment: ""),
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
    
    static func error(_ title: String, subtitle: String? = nil) {
        print(title)
        
        if let subtitle {
            print(subtitle)
        }
        
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
        AlertKitAPI.present(
            title: "Restored",
            subtitle: "The server has been restored",
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
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
            
            print("Error:", error.status, "-", error.code)
            
            AlertKitAPI.present(title: title, icon: .error, style: .iOS17AppleMusic, haptic: .error)
        }
#endif
        networkCallError(#function, error)
    }
}
