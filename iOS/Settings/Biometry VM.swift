import SwiftUI
import LocalAuthentication

@Observable
final class BiometryVM {
    private let context = LAContext()
    
    private(set) var bioType = "Unknown"
    private(set) var canEvaluatePolicy = false
    private(set) var biometryType: LABiometryType = .none
    
    var sheetBio = false
    
    func defineBiometryType() {
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil) else {
            return
        }
        
        switch context.biometryType {
        case .faceID:  bioType = "Face ID"
        case .touchID: bioType = "Touch ID"
        case .opticID: bioType = "Optic ID"
            
        default:
            break
        }
    }
}
