import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Server"
        
    init() {}
    
    func perform() async throws -> some IntentResult {
        .result()
    }
}
