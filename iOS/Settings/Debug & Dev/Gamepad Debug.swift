import SwiftUI

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
