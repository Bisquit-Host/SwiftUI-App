import SwiftUI
import LocalAuthentication

@Observable
final class SettingsVM {
    var bioType = "Unknown"
    private(set) var biometryType: LABiometryType = .none
    
    private(set) var context = LAContext()
    private(set) var canEvaluatePolicy = false
    
    var sheetBio = false
    var sheetSupport = false
    var sheetSftp = false
    var alertClearAllData = false
    
    func defineBiometryType() {
        canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = context.biometryType
        
        switch biometryType {
        case .faceID:
            bioType = "Face ID"
            
        case .touchID:
            bioType = "Touch ID"
            
        default: break
        }
    }
}
