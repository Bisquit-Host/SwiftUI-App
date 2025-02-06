import AppIntents
import PteroNet

struct CreateBackup: AppIntent, CustomIntentMigratedAppIntent, PredictableIntent {
    static let intentClassName = "CreateBackupIntent"
    
    static var title: LocalizedStringResource = "Create Backup"
    static var description = IntentDescription("Creates a new backup", searchKeywords: ["Minecraft"])
    
    @Parameter(title: "Server id")
    var id: String
    
    @Parameter(title: "Backup name")
    var backupName: String
    
    static var parameterSummary: some ParameterSummary {
        Summary("Create Backup") {
            \.$id
            \.$backupName
        }
    }
    
    func createBackup(_ name: String) {
        backupCreateAPI(id, name: name) { result in
            switch result {
            case .success(let model):
                if let model {
                    print(model)
                }
                
            case .failure(let error):
                networkCallError(#function, error)
            }
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
        createBackup(backupName)
        
        return .result()
    }
}
