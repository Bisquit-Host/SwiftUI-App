#if os(iOS)
import Foundation

enum ActiveServicesIntentError: LocalizedError {
    case notSignedIn, servicesUnavailable
    
    var errorDescription: String? {
        switch self {
        case .notSignedIn: "Sign in to billing before fetching your active services"
        case .servicesUnavailable: "Unable to fetch your active services"
        }
    }
}
#endif
