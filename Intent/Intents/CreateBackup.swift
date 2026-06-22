import AppIntents
import Calagopus

struct CreateBackup: AppIntent, PredictableIntent {
    static let title: LocalizedStringResource = "Create Backup"
    static let description = IntentDescription("Creates a new backup", searchKeywords: ["Minecraft"])
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    @Parameter(title: "Backup name", description: "Optional", default: "")
    var backupName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Create Backup") {
            \.$id
            \.$backupName
        }
    }
    
    func createBackup(_ name: String) async {
        do {
            _ = try await CalagopusNet.client().createBackup(server: id, name: name)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$id, \.$backupName)) { id, name in
            DisplayRepresentation(title: "Create Backup", subtitle: "Creates a new backup")
        }
    }
    
    func perform() async throws -> some IntentResult {
        await createBackup(backupName)
        return .result()
    }
}
