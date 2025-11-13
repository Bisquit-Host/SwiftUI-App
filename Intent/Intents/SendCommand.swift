import AppIntents

struct SendCommand: AppIntent, PredictableIntent {    
    static let title: LocalizedStringResource = "Send Command"
    static let description = IntentDescription("Sends a command to the server", searchKeywords: ["Minecraft"])
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    @Parameter(title: "Command")
    var command: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Send Command") {
            \.$id
            \.$command
        }
    }
    
    func sendCommand(_ command: String) async {
        await PteroNet.sendCommand(id, command: command)
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
        await sendCommand(command)
        
        return .result()
    }
}
