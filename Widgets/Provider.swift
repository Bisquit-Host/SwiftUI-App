import WidgetKit
import PteroNet

struct Provider: AppIntentTimelineProvider {
    typealias Entry = SystemSmallEntry
    typealias Intent = ConfigurationAppIntent
    
    func timeline(
        for configuration: ConfigurationAppIntent,
        in context: Context
    ) -> Timeline<SystemSmallEntry> {
        var cpu = 0.0
        
        serverUsageAPI(configuration.serverId) { result in
            switch result {
            case .success(let model):
                if let model {
                    let usage = model.attributes.usage
                    cpu = usage.cpu
                }
                
            case .failure:
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
        
        let timeline = Timeline(
            entries: entries,
            policy: .atEnd
        )
        
        return timeline
    }
    
    func snapshot(for configuration: ConfigurationAppIntent,
                  in context: Context
    ) -> SystemSmallEntry {
        SystemSmallEntry(
            date: Date(),
            cpuUsage: getCpu(),
            ramUsage: getRam()
        )
    }
    
    func placeholder(in context: Context) -> SystemSmallEntry {
        SystemSmallEntry(
            date: Date(),
            cpuUsage: getCpu(),
            ramUsage: getRam()
        )
    }
    
    func getCpu() -> Double {
        if let storage = UserDefaults(suiteName: "group.Bisquit-host") {
            storage.double(forKey: "widgetCpuUsage")
        } else {
            -1
        }
    }
    
    func getRam() -> Double {
        if let storage = UserDefaults(suiteName: "group.Bisquit-host") {
            storage.double(forKey: "widgetRamUsage")
        } else {
            -1
        }
    }
}
