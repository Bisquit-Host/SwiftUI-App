import SwiftUI
import GaypadKit

struct GamepadDebug: View {
    @State private var gamepad = GamepadManager.shared
    
    private var dpadIcon: String {
        if gamepad.dpadUpPressed {
            "dpad.up.filled"
        } else if gamepad.dpadDownPressed {
            "dpad.down.filled"
        } else if gamepad.dpadLeftPressed {
            "dpad.left.filled"
        } else if gamepad.dpadRightPressed {
            "dpad.right.filled"
        } else {
            "dpad"
        }
    }
    
    private var actionIcon: String {
        if gamepad.xPressed {
            "circle.grid.cross.left.filled"
        } else if gamepad.yPressed {
            "circle.grid.cross.up.filled"
        } else if gamepad.aPressed {
            "circle.grid.cross.down.filled"
        } else if gamepad.bPressed {
            "circle.grid.cross.right.filled"
        } else {
            "circle.grid.cross"
        }
    }
    
    // XBox A    // PS X        // Primary Action
    // XBox B   // PS Circle   // Back
    // XBox X  // PS Square
    // XBox Y // PS Triangle // Toolbar
    
    var body: some View {
        VStack {
            HStack {
                Image(systemName: "l2.button.roundedtop.horizontal")
                    .symbolVariant(gamepad.leftTriggerPressed ? .fill : .none)
                
                Image(systemName: "r2.button.roundedtop.horizontal")
                    .symbolVariant(gamepad.rightTriggerPressed ? .fill : .none)
            }
            
            HStack {
                Image(systemName: "l1.button.roundedbottom.horizontal")
                    .symbolVariant(gamepad.leftShoulderPressed ? .fill : .none)
                
                Image(systemName: "r1.button.roundedbottom.horizontal")
                    .symbolVariant(gamepad.rightShoulderPressed ? .fill : .none)
            }
            
            HStack {
                Image(systemName: "camera.shutter.button")
                    .symbolVariant(gamepad.optionsPressed ? .fill : .none)
                
                Image(systemName: "line.3.horizontal.circle")
                    .symbolVariant(gamepad.menuPressed ? .fill : .none)
            }
            
            HStack {
                Image(systemName: dpadIcon)
                Image(systemName: actionIcon)
            }
            
            HStack {
                Image(systemName: "l.joystick.press.down")
                    .symbolVariant(gamepad.leftThumbstickPressed ? .fill : .none)
                
                Image(systemName: "r.joystick.press.down")
                    .symbolVariant(gamepad.rightThumbstickPressed ? .fill : .none)
            }
            
            Text("Battery: \(Int(gamepad.batteryLevel * 100))%")
                .largeTitle()
        }
        .foregroundStyle(gamepad.isConnected ? .primary : .secondary)
        .fontSize(50)
    }
}

#Preview {
    GamepadDebug()
        .darkSchemePreferred()
}
