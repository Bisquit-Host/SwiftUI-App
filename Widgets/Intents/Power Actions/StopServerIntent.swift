import AppIntents

struct StopServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Stop Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .stop)
        return .result()
    }
}
