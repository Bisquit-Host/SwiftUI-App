import SwiftUI
import LocalAuthentication

@Observable
final class BiometryVM {
    private(set) var canEvaluatePolicy = false
    private(set) var biometryType: LABiometryType = .none
    
    var bioType: LocalizedStringKey? {
        guard LAContext().canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return nil
        }
        
        biometryType = LAContext().biometryType
        
        switch LAContext().biometryType {
        case .faceID:  return "Face ID"
        case .touchID: return "Touch ID"
        case .opticID: return "Optic ID"
        default:       return nil
        }
    }
    
    var icon: String {
        switch biometryType {
        case .faceID: "faceid"
        case .touchID: "touchid"
        case .opticID: "opticid"
        default: "exclamationmark.triangle"
        }
    }
}
