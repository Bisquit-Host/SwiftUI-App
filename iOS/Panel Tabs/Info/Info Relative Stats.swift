import SwiftUI
import PteroNet

struct InfoRelativeStats: View {
    @Environment(PanelVM.self) private var vm
    
    private let limits: ServerLimits
    
    init(_ limits: ServerLimits) {
        self.limits = limits
    }
    
    private var relativeRam: String {
        let limit = limits.memory * pow(1024, 2)
        let usage = Int(vm.ramUsage / limit * 100)
        
        return "\(usage)%"
    }
    
    private var relativeCpu: String {
        let usage = Int(vm.cpuUsage / limits.cpu * 100)
        
        return "\(usage)%"
    }
    
    private var relativeDisk: String {
        let usage = Int(vm.diskUsage / limits.disk * 100)
        
        return "\(usage)%"
    }
    
    var body: some View {
        HStack {
            Group {
                InfoStat("Uptime", value: millisecondsToTime(vm.uptime))
                
                InfoStat("Storage", value: relativeDisk)
                
                InfoStat("Processor", value: relativeCpu)
                
                InfoStat("Memory", value: relativeRam)
            }
            .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    InfoRelativeStats(sampleJSON(.serverListAttributes))
        .environment(PanelVM(""))
}
