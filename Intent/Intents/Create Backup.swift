import AppIntents
import PteroNet

struct CreateBackup: AppIntent, PredictableIntent {
    static var title: LocalizedStringResource = "Create Backup"
    static var description = IntentDescription("Creates a new backup", searchKeywords: ["Minecraft"])
    
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
            let backup = try await backupCreateAPI(id, name: name)
        } catch {
            networkCallError(#function, error)
        }
    }
    
    static var predictionConfiguration: some IntentPredictionConfiguration {
        IntentPrediction(parameters: (\.$id, \.$backupName)) { id, name in
            DisplayRepresentation(
                title: "Create Backup",
                subtitle: "Creates a new backup"
            )
        }
    }
    
    func perform() async throws -> some IntentResult {
        await createBackup(backupName)
        
        return .result()
    }
}
