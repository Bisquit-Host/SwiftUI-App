import ScrechKit
import PteroNet

@Observable
final class ConsoleVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var alertKill = false
    var inspectorPresented = false
    var server_power = ""
    var fontSize: CGFloat = 10
    
    func returnFontDesignName(_ fontDesign: Font.Design) -> String {
        let fontDesignString: String?
        
        switch fontDesign {
        case .default:
            fontDesignString = "Default"
            
        case .serif:
            fontDesignString = "Serif"
            
        case .rounded:
            fontDesignString = "Rounded"
            
        case .monospaced:
            fontDesignString = "Monospaced"
            
        @unknown default:
            fontDesignString = ""
        }
        
        return fontDesignString!
    }
    
    func sendCommand(_ command: String) {
        PteroNet.sendCommand(id, command: command)
    }
    
    func showFailureMessage(error: Error) {
        switch error {
        case Errors.BadGateway:
            print("HttpException")
            //            withAnimation {
            //                self.createButtonText = "Error 400"
            //                self.errorText = "Cannot create a new backup, this server has reached its limit of \(backupLimit) backups."
            //            }
            
        case Errors.Success:
            print("Suc")
            //            withAnimation {
            //                self.createButtonText = "Error 429"
            //                self.errorText = "Only 2 backups may be generated within a 600 second span of time."
            //            }
            
        default:
            print("Def")
            //            withAnimation {
            //                self.createButtonText = "Unknown Error"
            //                self.createButtonText = "Contact Support"
            //            }
        }
        
        delay(4) {
            withAnimation {
                //                self.createButtonText = "Create Backup"
                //                self.createButtonColor = .blue
                //                self.errorText = ""
                //                self.createButtonDisabled = false
            }
        }
    }
}
