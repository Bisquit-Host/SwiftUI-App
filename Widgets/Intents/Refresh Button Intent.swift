import AppIntents

struct RefreshIntent: AppIntent {
    static var title: LocalizedStringResource = "Refresh"
    static var description = IntentDescription("Refreshes the content")
    
    static var isDiscoverable = false
    
    init() {}
    
    func perform() async -> some IntentResult {
        .result()
    }
}
