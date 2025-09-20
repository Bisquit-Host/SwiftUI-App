import ScrechKit
import PteroNet

struct InfoAbsoluteStats: View {
    @Environment(PanelVM.self) private var vm
    
    private let limits: ServerLimits
    
    init(_ limits: ServerLimits) {
        self.limits = limits
    }
    
    var body: some View {
        HStack {
            Group {
                VStack {
                    Text("Processor")
                        .footnote()
                        .secondary()
                    
                    cpuAbsolute
                }
                
                VStack {
                    Text("Memory")
                        .footnote()
                        .secondary()
                    
                    ramAbsolute
                }
                
                VStack {
                    Text("Storage")
                        .footnote()
                        .secondary()
                    
                    diskAbsolute
                }
            }
            .lineLimit(1)
            .minimumScaleFactor(0.5)
            .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
    }
    
    private var diskAbsolute: some View {
        let usage = formatBytes(vm.diskUsage * pow(1024, 2))
        let usageText = Text(usage)
        
        let limit = formatBytes(
            limits.disk * pow(1024, 2),
            countStyle: .memory
        )
        
        let limitText = Text("/" + limit)
            .footnote()
            .tertiary()
        
        return HStack(alignment: .bottom, spacing: 0) {
            usageText
            limitText
        }
    }
    
    private var cpuAbsolute: some View {
        let usage = Int(vm.cpuUsage)
        let usageText = vm.serverState == .offline ? Text("-") : Text("\(usage)%")
        
        let limit = Int(limits.cpu)
        
        let limitText = Text("/\(limit)%")
            .footnote()
            .tertiary()
        
        return HStack(alignment: .bottom, spacing: 0) {
            usageText
            limitText
        }
    }
    
    private var ramAbsolute: some View {
        let usage = formatBytes(vm.ramUsage, countStyle: .memory)
        let usageText = vm.serverState == .offline ? Text("-") : Text(usage)
        
        let limit = formatBytes(
            limits.memory * pow(1024, 2),
            countStyle: .memory
        )
        
        let limitText = Text("/" + limit)
            .footnote()
            .tertiary()
        
        return HStack(alignment: .bottom, spacing: 0) {
            usageText
            limitText
        }
    }
}

#Preview {
    InfoAbsoluteStats(PreviewProp.serverAttributes.limits)
        .environment(PanelVM(""))
}
