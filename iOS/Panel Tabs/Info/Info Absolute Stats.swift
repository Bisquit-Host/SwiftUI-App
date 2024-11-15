import ScrechKit
import PteroNet

struct InfoAbsoluteStats: View {
    @Environment(PanelVM.self) private var panelVM
    
    private let limits: ServerLimits
    
    init(_ limits: ServerLimits) {
        self.limits = limits
    }
    
    var body: some View {
        HStack {
            Group {
                VStack {
                    Text("Storage")
                        .footnote()
                        .foregroundStyle(.secondary)
                    
                    diskAbsolute
                }
                
                VStack {
                    Text("Processor")
                        .footnote()
                        .foregroundStyle(.secondary)
                    
                    cpuAbsolute
                }
                
                VStack {
                    Text("Memory")
                        .footnote()
                        .foregroundStyle(.secondary)
                    
                    ramAbsolute
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
    }
    
    private var diskAbsolute: some View {
        let usage = formatBytes(panelVM.diskUsage * pow(1024, 2))
        let usageText = Text(usage)
        
        let limit = formatBytes(
            limits.disk * pow(1024, 2),
            countStyle: .memory
        )
        
        let limitText = Text("/\(limit)")
            .footnote()
            .foregroundStyle(.tertiary)
        
        return HStack(alignment: .bottom, spacing: 0) {
            usageText
            limitText
        }
    }
    
    private var cpuAbsolute: some View {
        let usage = Int(panelVM.cpuUsage)
        let usageText = Text("\(usage)%")
        
        let limit = Int(limits.cpu)
        let limitText = Text("/\(limit)%")
            .footnote()
            .foregroundStyle(.tertiary)
        
        return HStack(alignment: .bottom, spacing: 0) {
            usageText
            limitText
        }
    }
    
    private var ramAbsolute: some View {
        let usage = formatBytes(panelVM.ramUsage, countStyle: .memory)
        let usageText = Text(usage)
        
        let limit = formatBytes(
            limits.memory * pow(1024, 2),
            countStyle: .memory
        )
        
        let limitText = Text("/\(limit)")
            .footnote()
            .foregroundStyle(.tertiary)
        
        return HStack(alignment: .bottom, spacing: 0) {
            usageText
            limitText
        }
    }
}

#Preview {
    InfoAbsoluteStats(
        sampleJSON(.serverListAttributes)
    )
    .environment(PanelVM(""))
}
