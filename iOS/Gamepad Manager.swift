import Foundation
import GameController

@Observable
final class GamepadManager {
    static let shared = GamepadManager()
    
    // Buttons
    var isAPressed = false
    var isBPressed = false
    var isXPressed = false
    var isYPressed = false
    var isMenuPressed = false
    var isOptionsPressed = false
    var isLeftThumbstickPressed = false
    var isRightThumbstickPressed = false
    var isLeftShoulderPressed = false
    var isRightShoulderPressed = false
    var isLeftTriggerPressed = false
    var isRightTriggerPressed = false
    
    // D-Pad
    var isDpadUpPressed = false
    var isDpadDownPressed = false
    var isDpadLeftPressed = false
    var isDpadRightPressed = false
    
    // Battery
    var batteryLevel: Float = -1
    
    private init() {
        NotificationCenter.default.addObserver(
            forName: .GCControllerDidConnect,
            object: nil,
            queue: .main
        ) { _ in
            self.setupControllers()
        }
        
        GCController.startWirelessControllerDiscovery(completionHandler: nil)
        setupControllers()
    }
    
    private func setupControllers() {
        for controller in GCController.controllers() {
            batteryLevel = controller.battery?.batteryLevel ?? -1
            
            controller.extendedGamepad?.valueChangedHandler = { [weak self] _, element in
                guard let self else {
                    return
                }
                
                let gamepad = controller.extendedGamepad
                
                func check(_ input: GCControllerButtonInput?, _ update: (Bool) -> Void) {
                    if let button = element as? GCControllerButtonInput, button == input {
                        update(button.isPressed)
                    }
                }
                
                check(gamepad?.buttonA)               { self.isAPressed = $0 }
                check(gamepad?.buttonB)               { self.isBPressed = $0 }
                check(gamepad?.buttonX)               { self.isXPressed = $0 }
                check(gamepad?.buttonY)               { self.isYPressed = $0 }
                check(gamepad?.buttonMenu)            { self.isMenuPressed = $0 }
                check(gamepad?.buttonOptions)         { self.isOptionsPressed = $0 }
                check(gamepad?.leftThumbstickButton)  { self.isLeftThumbstickPressed = $0 }
                check(gamepad?.rightThumbstickButton) { self.isRightThumbstickPressed = $0 }
                check(gamepad?.leftShoulder)          { self.isLeftShoulderPressed = $0 }
                check(gamepad?.rightShoulder)         { self.isRightShoulderPressed = $0 }
                check(gamepad?.leftTrigger)           { self.isLeftTriggerPressed = $0 }
                check(gamepad?.rightTrigger)          { self.isRightTriggerPressed = $0 }
                
                if let dpad = element as? GCControllerDirectionPad {
                    let x = dpad.xAxis.value
                    let y = dpad.yAxis.value
                    
                    self.isDpadUpPressed    = x == 0 && y == 1
                    self.isDpadDownPressed  = x == 0 && y == -1
                    self.isDpadLeftPressed  = x == -1 && y == 0
                    self.isDpadRightPressed = x == 1 && y == 0
                }
            }
        }
    }
}
