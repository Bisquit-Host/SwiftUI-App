import SwiftUI
import GaypadKit

struct GamepadDebug: View {
    @State private var gamepad = GamepadManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            Text(gamepad.aPressed ? "A Pressed" : "Press A") // PS X // Primary Action
            Text(gamepad.bPressed ? "B Pressed" : "Press B") // PS Circle // Back
            Text(gamepad.xPressed ? "X Pressed" : "Press X") // PS Square
            Text(gamepad.yPressed ? "Y Pressed" : "Press Y") // PS Triangle // Toolbar
            Text(gamepad.menuPressed ? "Menu Pressed" : "Press Menu")
            Text(gamepad.optionsPressed ? "Options Pressed" : "Press Options")
            Text(gamepad.leftThumbstickPressed ? "Left Stick Pressed" : "Press Left Stick")
            Text(gamepad.rightThumbstickPressed ? "Right Stick Pressed" : "Press Right Stick")
            Text(gamepad.leftShoulderPressed ? "Left Shoulder Pressed" : "Press Left Shoulder")
            Text(gamepad.rightShoulderPressed ? "Right Shoulder Pressed" : "Press Right Shoulder")
            Text(gamepad.leftTriggerPressed ? "Left Trigger Pressed" : "Press Left Trigger")
            Text(gamepad.rightTriggerPressed ? "Right Trigger Pressed" : "Press Right Trigger")
            
            Text(gamepad.dpadUpPressed ? "DPad Up Pressed" : "Press DPad Up")
            Text(gamepad.dpadDownPressed ? "DPad Down Pressed" : "Press DPad Down")
            Text(gamepad.dpadLeftPressed ? "DPad Left Pressed" : "Press DPad Left")
            Text(gamepad.dpadRightPressed ? "DPad Right Pressed" : "Press DPad Right")
            
            Text("Battery: \(Int(gamepad.batteryLevel * 100))%")
        }
    }
}
