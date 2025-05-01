import SwiftUI

struct GamepadDebug: View {
    @State private var gamepad = GamepadManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text(gamepad.isAPressed ? "A Pressed" : "Press A") // PS X // Primary Action
            Text(gamepad.isBPressed ? "B Pressed" : "Press B") // PS Circle // Back
            Text(gamepad.isXPressed ? "X Pressed" : "Press X") // PS Square
            Text(gamepad.isYPressed ? "Y Pressed" : "Press Y") // PS Triangle // Toolbar
            Text(gamepad.isMenuPressed ? "Menu Pressed" : "Press Menu")
            Text(gamepad.isOptionsPressed ? "Options Pressed" : "Press Options")
            Text(gamepad.isLeftThumbstickPressed ? "Left Stick Pressed" : "Press Left Stick")
            Text(gamepad.isRightThumbstickPressed ? "Right Stick Pressed" : "Press Right Stick")
            Text(gamepad.isLeftShoulderPressed ? "Left Shoulder Pressed" : "Press Left Shoulder")
            Text(gamepad.isRightShoulderPressed ? "Right Shoulder Pressed" : "Press Right Shoulder")
            Text(gamepad.isLeftTriggerPressed ? "Left Trigger Pressed" : "Press Left Trigger")
            Text(gamepad.isRightTriggerPressed ? "Right Trigger Pressed" : "Press Right Trigger")
            Text(gamepad.isDpadUpPressed ? "DPad Up Pressed" : "Press DPad Up")
            Text(gamepad.isDpadDownPressed ? "DPad Down Pressed" : "Press DPad Down")
            Text(gamepad.isDpadLeftPressed ? "DPad Left Pressed" : "Press DPad Left")
            Text(gamepad.isDpadRightPressed ? "DPad Right Pressed" : "Press DPad Right")
            
            Text("Battery: \(Int(gamepad.batteryLevel * 100))%")
        }
    }
}
