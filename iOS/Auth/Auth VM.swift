import ScrechKit
import AudioToolbox
import LocalAuthentication

@Observable
final class AuthVM {
    var icon = "face.smiling"
    var colorButton: Color = .black
    var textLogin = ""
    var bioType = "Unknown"
    
#if !os(macOS) && !os(visionOS)
    let impactMed = UIImpactFeedbackGenerator(style: .heavy)
#endif
    
    var trigger = false
    
    private(set) var biometryType: LABiometryType = .none
    private(set) var isAuthenticated = false
    private(set) var errorDescription: String? = nil
    private(set) var context = LAContext()
    private(set) var canEvaluatePolicy = false
    
    //    var scene: SKScene {
    //        let scene = GameScene()
    //        scene.scaleMode = .resizeFill
    //        scene.backgroundColor = .clear
    //        scene.physicsWorld.gravity = CGVector(dx: 0, dy: -0.5)
    //        return scene
    //    }
    
    func appear(_ useBiometry: Bool, navState: NavState) {
        delay(0.5) {
            if useBiometry {
                self.getBiometryType()
                self.authenticate(navState)
            } else {
                navState.navigate(.toServerList)
            }
        }
    }
    
    private func authSucceed(_ navState: NavState) {
#if !os(macOS) && !os(visionOS)
        impactMed.impactOccurred()
#endif
        AudioServicesPlayAlertSound(SystemSoundID(1394))
        
        trigger.toggle()
        
        withAnimation(.easeInOut) {
            colorButton = .green
        }
        
        delay(1.5) {
            navState.navigate(.toServerList)
        }
    }
    
    private func authUnsucceed(_ navState: NavState) {
        withAnimation(.easeInOut(duration: 1.5)) {
            main {
                self.colorButton = .red
            }
        }
        
        delay(2) {
            self.authenticate(navState)
        }
    }
    
    func getBiometryType() {
        canEvaluatePolicy = context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: nil)
        biometryType = context.biometryType
        
        switch biometryType {
        case .faceID:
            icon = "faceid"
            bioType = "Face ID"
            
        case .touchID:
            icon = "touchid"
            bioType = "Touch ID"
            
        default:
            textLogin = "Error :("
            icon = "exclamationmark.triangle"
        }
    }
    
    func authenticate(_ navState: NavState) {
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            context.evaluatePolicy(
                .deviceOwnerAuthenticationWithBiometrics,
                localizedReason: "This is a security check reason."
            ) { success, error in
                if success {
                    self.authSucceed(navState)
                } else {
                    self.authUnsucceed(navState)
                }
            }
        } else {
            withAnimation(.easeOut) {
                self.colorButton = .orange
            }
        }
    }
}
