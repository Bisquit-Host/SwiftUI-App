import AppIntents

struct StartServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .start)
        return .result()
    }
}
