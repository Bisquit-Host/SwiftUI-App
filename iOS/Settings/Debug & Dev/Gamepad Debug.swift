import SwiftUI
import GameController

struct GamepadDebug: View {
    @State private var controller = GamepadManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text(controller.isAPressed ? "A Pressed" : "Press A") // PS X // Primary Action
            Text(controller.isBPressed ? "B Pressed" : "Press B") // PS Circle // Back
            Text(controller.isXPressed ? "X Pressed" : "Press X") // PS Square
            Text(controller.isYPressed ? "Y Pressed" : "Press Y") // PS Triangle // Toolbar
            Text(controller.isMenuPressed ? "Menu Pressed" : "Press Menu")
            Text(controller.isOptionsPressed ? "Options Pressed" : "Press Options")
            Text(controller.isLeftThumbstickPressed ? "Left Stick Pressed" : "Press Left Stick")
            Text(controller.isRightThumbstickPressed ? "Right Stick Pressed" : "Press Right Stick")
            Text(controller.isLeftShoulderPressed ? "Left Shoulder Pressed" : "Press Left Shoulder")
            Text(controller.isRightShoulderPressed ? "Right Shoulder Pressed" : "Press Right Shoulder")
            Text(controller.isLeftTriggerPressed ? "Left Trigger Pressed" : "Press Left Trigger")
            Text(controller.isRightTriggerPressed ? "Right Trigger Pressed" : "Press Right Trigger")
            Text("Battery: \(Int(controller.batteryLevel * 100))%")
        }
    }
}

@Observable
final class GamepadManager {
    static let shared = GamepadManager()
    
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
    
    func setupControllers() {
        for controller in GCController.controllers() {
            self.batteryLevel = controller.battery?.batteryLevel ?? -1
            
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
            }
        }
    }
}

struct GamepadAPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isAPressed) {
                if controller.isAPressed {
                    action()
                }
            }
    }
}

struct GamepadBPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isBPressed) {
                if controller.isBPressed {
                    action()
                }
            }
    }
}

struct GamepadXPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isXPressed) {
                if controller.isXPressed {
                    action()
                }
            }
    }
}

struct GamepadYPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isYPressed) {
                if controller.isYPressed {
                    action()
                }
            }
    }
}

struct GamepadMenuPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isMenuPressed) {
                if controller.isMenuPressed {
                    action()
                }
            }
    }
}

struct GamepadOptionsPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isOptionsPressed) {
                if controller.isOptionsPressed {
                    action()
                }
            }
    }
}

struct GamepadLeftThumbstickPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isLeftThumbstickPressed) {
                if controller.isLeftThumbstickPressed {
                    action()
                }
            }
    }
}

struct GamepadRightThumbstickPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(
        controller: GamepadManager = GamepadManager.shared,
        _ action: @escaping () -> Void
    ) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isRightThumbstickPressed) {
                if controller.isRightThumbstickPressed {
                    action()
                }
            }
    }
}

struct GamepadLeftShoulderPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isLeftShoulderPressed) {
                if controller.isLeftShoulderPressed {
                    action()
                }
            }
    }
}

struct GamepadRightShoulderPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isRightShoulderPressed) {
                if controller.isRightShoulderPressed {
                    action()
                }
            }
    }
}

struct GamepadLeftTriggerPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isLeftTriggerPressed) {
                if controller.isLeftTriggerPressed {
                    action()
                }
            }
    }
}

struct GamepadRightTriggerPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isRightTriggerPressed) {
                if controller.isRightTriggerPressed {
                    action()
                }
            }
    }
}

extension View {
    func onGamepadPressedA(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadAPressedModifier(action))
    }
    
    func onGamepadPressedB(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadBPressedModifier(action))
    }
    
    func onGamepadPressedX(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadXPressedModifier(action))
    }
    
    func onGamepadPressedY(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadYPressedModifier(action))
    }
    
    func onGamepadPressedMenu(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadMenuPressedModifier(action))
    }
    
    func onGamepadPressedOptions(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadOptionsPressedModifier(action))
    }
    
    func onGamepadPressedLeftThumbstick(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadLeftThumbstickPressedModifier(action))
    }
    
    func onGamepadPressedRightThumbstick(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadRightThumbstickPressedModifier(action))
    }
    
    func onGamepadPressedLeftShoulder(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadLeftShoulderPressedModifier(action))
    }
    
    func onGamepadPressedRightShoulder(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadRightShoulderPressedModifier(action))
    }
    
    func onGamepadPressedLeftTrigger(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadLeftTriggerPressedModifier(action))
    }
    
    func onGamepadPressedRightTrigger(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadRightTriggerPressedModifier(action))
    }
}
