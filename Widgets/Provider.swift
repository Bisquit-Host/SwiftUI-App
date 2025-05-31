import WidgetKit
import PteroNet

struct Provider: AppIntentTimelineProvider {
    typealias Entry = SystemSmallEntry
    typealias Intent = ConfigurationAppIntent
    
    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) async -> Timeline<SystemSmallEntry> {
        var cpu = 0.0
        
        if let id = configuration.id {
            do {
                let model = try await serverUsageAPI(id)
                cpu = model.usage.cpu
            } catch {
                cpu = -1
            }
        }
        
        let entryDate = Calendar.current.date(
            byAdding: DateComponents(minute: 1),
            to: Date()
        )!
        
        let entries = [
            SystemSmallEntry(
                date: entryDate,
                cpuUsage: cpu,
                ramUsage: getRam()
            )
        ]
        
        return Timeline(
            entries: entries,
            policy: .atEnd
        )
    }
    
    func snapshot(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) -> SystemSmallEntry {
        SystemSmallEntry(
            date: Date(),
            cpuUsage: getCpu(),
            ramUsage: getRam()
        )
    }
    
    func placeholder(
        in context: Context
    ) -> SystemSmallEntry {
        SystemSmallEntry(
            date: Date(),
            cpuUsage: getCpu(),
            ramUsage: getRam()
        )
    }
    
    private func getCpu() -> Double {
        if let storage = UserDefaults(suiteName: "group.Bisquit-host") {
            storage.double(forKey: "widgetCpuUsage")
        } else {
            -1
        }
    }
    
    private func getRam() -> Double {
        if let storage = UserDefaults(suiteName: "group.Bisquit-host") {
            storage.double(forKey: "widgetRamUsage")
        } else {
            -1
        }
    }
}
