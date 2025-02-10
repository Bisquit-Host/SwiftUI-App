import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
    static var description = IntentDescription("Refreshes the content")
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        .result()
    }
}
