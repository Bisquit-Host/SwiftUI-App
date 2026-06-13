import ScrechKit
import PteroNet

struct ResourcesConfiguredWidgetView: View {
    private let entry: ResourcesUsageEntry
    
    init(_ entry: ResourcesUsageEntry) {
        self.entry = entry
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(alignment: .top) {
                VStack(alignment: .leading) {
                    Text(entry.name)
                        .title(.bold)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                    
                    Text(stateLabel)
                        .caption2(.bold)
                        .foregroundStyle(stateColor)
                }
                
                Spacer()
                
                VStack(alignment: .trailing) {
                    Button("Refresh", systemImage: "arrow.clockwise", intent: RefreshIntent())
                        .labelStyle(.iconOnly)
                        .buttonBorderShape(.circle)
                    
                    Text(entry.date, format: .dateTime.hour().minute())
                        .caption2()
                        .secondary()
                }
            }
            
            Spacer()
            
            HStack {
                ResourceMetricView(
                    title: "CPU",
                    value: cpuText,
                    systemImage: "cpu"
                )
                
                ResourceMetricView(
                    title: "RAM",
                    value: memoryText,
                    systemImage: "memorychip"
                )
                
                ResourceMetricView(
                    title: "Disk",
                    value: diskText,
                    systemImage: "internaldrive"
                )
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
    }
    
    private var cpuText: String {
        guard let cpu = entry.test?.usage.cpu else {
            return "-"
        }
        
        return cpu.formatted(.number.precision(.fractionLength(0))) + "%"
    }
    
    private var memoryText: String {
        guard let memory = entry.test?.usage.memory else {
            return "-"
        }
        
        return formatBytes(memory, countStyle: .memory)
    }
    
    private var diskText: String {
        guard let disk = entry.test?.usage.disk else {
            return "-"
        }
        
        return formatBytes(disk, countStyle: .memory)
    }
    
    private var stateLabel: String {
        switch entry.state {
        case "running": "Running"
        case "offline": "Offline"
        case "suspended": "Suspended"
        case "stopping": "Stopping"
        case "starting": "Starting"
        default: entry.state
        }
    }
    
    private var stateColor: Color {
        switch entry.state {
        case "running": .green
        case "starting", "stopping": .orange
        case "offline": .secondary
        case "suspended": .red
        default: .secondary
        }
    }
}
