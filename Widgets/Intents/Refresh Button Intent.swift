import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
    
    init() {}
    
    func perform() async throws -> some IntentResult {
        .result()
    }
}
