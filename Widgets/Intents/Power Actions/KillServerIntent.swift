import AppIntents

struct KillServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Kill Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await CalagopusNet.powerSignal(id, do: .kill)
        return .result()
    }
}
