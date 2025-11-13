import AppIntents

struct RefreshIntent: AppIntent {
    static let title: LocalizedStringResource = "Refresh"
    static let description = IntentDescription("Refreshes the content")
    
    static let isDiscoverable = false
    
    init() {}
    
    func perform() async -> some IntentResult {
        .result()
    }
}
