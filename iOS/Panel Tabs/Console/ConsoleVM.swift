import SwiftUI
import Calagopus

@Observable
final class ConsoleVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var alertKill = false
    var inspectorPresented = false
    var command = ""
    var fontSize = 10.0
    var lastMessageIndex = 0
    
    func returnFontDesignName(_ fontDesign: Font.Design) -> String {
        switch fontDesign {
        case .default:    "Default"
        case .serif:      "Serif"
        case .rounded:    "Rounded"
        case .monospaced: "Monospaced"
        default:          ""
        }
    }
    
    func sendCommand() async {
        await CalagopusNet.sendCommand(id, command: command)
        command = ""
    }
}
