import ScrechKit
import Calagopus

#if canImport(AlertKit)
import AlertKit
#endif

final class SystemAlert {
    private static func localized(_ text: String) -> String {
        NSLocalizedString(text, comment: "")
    }

    private static func localized(_ text: String?) -> String? {
        guard let text else { return nil }

        return localized(text)
    }

    static func done(_ title: String, subtitle: String? = nil) {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: localized(title),
            subtitle: localized(subtitle),
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
#if canImport(AlertKit)
    static func copied(_ title: String = "Copied") {
        AlertKitAPI.present(
            title: localized(title),
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
    }
    
    static func networkError() {
        AlertKitAPI.present(
            title: localized("Network Error"),
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
    
    static func error(_ title: String, subtitle: String? = nil) {
        if let subtitle {
            Logger().error("\(title) • \(subtitle)")
        } else {
            Logger().error("\(title)")
        }
        
        AlertKitAPI.present(
            title: localized(title),
            subtitle: localized(subtitle),
            icon: .error,
            style: .iOS17AppleMusic,
            haptic: .error
        )
    }
#endif
    
    static func restored() {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: localized("Restored"),
            subtitle: localized("The server has been restored"),
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
    static func reinstalled() {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: localized("Reinstalled"),
            subtitle: localized("The server has been reinstalled"),
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
    static func changesSaved() {
#if canImport(AlertKit)
        AlertKitAPI.present(
            title: localized("Changes Saved"),
            subtitle: localized("The file has been saved"),
            icon: .done,
            style: .iOS17AppleMusic,
            haptic: .success
        )
#endif
    }
    
    static func error(_ error: Error) {
#if canImport(AlertKit)
        let message = errorMessage(for: error)
        Logger().error("Error: \(message)")
        AlertKitAPI.present(title: message, icon: .error, style: .iOS17AppleMusic, haptic: .error)
#endif
        networkCallError(#function, error)
    }

#if canImport(AlertKit)
    private static func errorMessage(for error: Error) -> String {
        let message = switch error {
        case let CalagopusError.httpStatus(status, _, apiError):
            apiError?.firstDetail?.detail ?? "Request failed with HTTP status \(status)"
        
        case let CalagopusError.validation(detail):
            detail.detail
        
        case CalagopusError.invalidResponse:
            "The server returned an invalid response"
        
        case let CalagopusError.invalidURL(url):
            "Invalid server URL: \(url)"
        
        case let CalagopusError.missingPathValue(value):
            "The request is missing \(value)"
        
        case let CalagopusError.missingRequiredQueryValue(value):
            "The request is missing \(value)"
        
        default:
            error.localizedDescription
        }

        return message.last == "." ? String(message.dropLast()) : message
    }
#endif
}
