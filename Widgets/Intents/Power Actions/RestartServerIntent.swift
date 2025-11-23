import AppIntents

struct RestartServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Restart Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .restart)
        return .result()
    }
}
