import AppIntents

struct SendCommand: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "SendCommandIntent"
    
    static var title: LocalizedStringResource = "Send Command"
    static var description = IntentDescription("Sends a command to the server", searchKeywords: ["Minecraft"])
    
    @Parameter(title: "Server id")
    var id: String
    
    @Parameter(title: "Command")
    var command: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Send Command") {
            \.$id
            \.$command
        }
    }
    
    func sendCommand(_ command: String) {
        PteroNet.sendCommand(id, command: command)
    }
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$id, \.$command)) { id, command in
            DisplayRepresentation(
                title: "Send Command",
                subtitle: "Send command to a server"
            )
        }
    }
    
    func perform() async throws -> some IntentResult {
        sendCommand(command)
        
        return .result()
    }
}
