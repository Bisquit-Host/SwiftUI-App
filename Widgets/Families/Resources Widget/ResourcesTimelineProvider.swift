import WidgetKit

struct ResourcesTimelineProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> ResourcesUsageEntry {
        ResourcesUsageEntry(date: Date(), name: "Preview", id: "12345678", state: "running")
    }
    
    func snapshot(for configuration: ConfigurationAppIntent, in context: Context) async -> ResourcesUsageEntry {
        await entry(for: configuration) ?? ResourcesUsageEntry(date: Date(), name: "", id: "", state: "Select a server")
    }
    
    func timeline(for configuration: ConfigurationAppIntent, in context: Context) async -> Timeline<ResourcesUsageEntry> {
        let entry = await entry(for: configuration) ?? ResourcesUsageEntry(date: Date(), name: "", id: "", state: "Select a server")
        let nextUpdate = Calendar.current.date(byAdding: DateComponents(minute: 15), to: Date())!
        
        return Timeline(entries: [entry], policy: .after(nextUpdate))
    }
    
    private func entry(for configuration: ConfigurationAppIntent) async -> ResourcesUsageEntry? {
        guard let server = configuration.selectedServer else {
            return nil
        }
        
        let usage = await Networking.fetchResourceUsage(server.id)
        
        return ResourcesUsageEntry(
            date: Date(),
            name: server.displayString,
            id: server.id,
            state: usage.state,
            test: usage.test
        )
    }
}
