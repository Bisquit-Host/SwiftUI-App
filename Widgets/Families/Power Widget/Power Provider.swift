import WidgetKit

struct PowerProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PowerEntry {
        PowerEntry(date: Date(), configuration: .init())
    }
    
    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> PowerEntry {
        PowerEntry(date: Date(), configuration: configuration)
    }
    
    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<PowerEntry> {
        
        var entries: [PowerEntry] = []
        
        let entry = PowerEntry(date: .now, configuration: configuration)
        entries.append(entry)
        
        return Timeline(entries: entries, policy: .atEnd)
    }
}

