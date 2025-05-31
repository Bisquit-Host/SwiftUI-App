import AppIntents
import PteroNet

struct ChangePower: AppIntent, PredictableIntent {
    static var title: LocalizedStringResource = "Change Power"
    static var description = IntentDescription("Sends a power signal to the server", searchKeywords: ["Minecraft"])
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    @Parameter(title: "Power Signal", default: .start)
    var signal: PowerSignalAppEnum?
    
    static var parameterSummary: some ParameterSummary {
        Summary("Change Power") {
            \.$id
            \.$signal
        }
    }
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$id, \.$signal)) { id, signal in
            DisplayRepresentation(
                title: "Change Power",
                subtitle: "Start, Stop, Restart or Kill a server"
            )
        }
    }
    
    func perform() async throws -> some IntentResult /*& ReturnsValue<Int>*/ {
        let powerSignal: ServerSignal = switch signal {
        case .stop:    .stop
        case .restart: .restart
        case .kill:    .kill
        default:       .start
        }
        
        await PteroNet.powerSignal(id, do: powerSignal)
        
        return .result()
    }
}

//fileprivate extension IntentDialog {
//    static func idParameterDisambiguationIntro(count: Int, id: String) -> Self {
//        "There are \(count) options matching ‘\(id)’"
//    }
//
//    static func idParameterConfirmation(id: String) -> Self {
//        "Just to confirm, you wanted ‘\(id)’?"
//    }
//
//    static func signalParameterDisambiguationIntro(count: Int, signal: PowerSignalAppEnum) -> Self {
//        "There are \(count) options matching ‘\(signal)’"
//    }
//
//    static func signalParameterConfirmation(signal: PowerSignalAppEnum) -> Self {
//        "Just to confirm, you wanted ‘\(signal)’?"
//    }
//}
