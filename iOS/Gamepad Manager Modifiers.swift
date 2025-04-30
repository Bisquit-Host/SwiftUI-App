import SwiftUI

struct GamepadDpadUpPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isDpadUpPressed) {
                if controller.isDpadUpPressed {
                    action()
                }
            }
    }
}

struct GamepadDpadDownPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isDpadDownPressed) {
                if controller.isDpadDownPressed {
                    action()
                }
            }
    }
}

struct GamepadDpadLeftPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isDpadLeftPressed) {
                if controller.isDpadLeftPressed {
                    action()
                }
            }
    }
}

struct GamepadDpadRightPressedModifier: ViewModifier {
    @State private var controller = GamepadManager.shared
    private var action: () -> Void
    
    init(controller: GamepadManager = GamepadManager.shared, _ action: @escaping () -> Void) {
        self.controller = controller
        self.action = action
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: controller.isDpadRightPressed) {
                if controller.isDpadRightPressed {
                    action()
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
    
    func onGamepadPressedDpadUp(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadDpadUpPressedModifier(action))
    }
    
    func onGamepadPressedDpadDown(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadDpadDownPressedModifier(action))
    }
    
    func onGamepadPressedDpadLeft(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadDpadLeftPressedModifier(action))
    }
    
    func onGamepadPressedDpadRight(_ action: @escaping () -> Void) -> some View {
        modifier(GamepadDpadRightPressedModifier(action))
    }
}
