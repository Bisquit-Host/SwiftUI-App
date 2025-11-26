import SwiftUI
import PteroNet

struct InfoRelativeStats: View {
    @Environment(PanelVM.self) private var vm
    
    private let limits: ServerLimits
    
    init(_ limits: ServerLimits) {
        self.limits = limits
    }
    
    private var relativeRam: String {
        guard
            vm.serverState != .offline,
            limits.memory > 0,
            vm.ramUsage.isFinite
        else {
            return "-"
        }
        
        let limit = limits.memory * pow(1024, 2)
        let usage = Int(vm.ramUsage / limit * 100)
        
        return "\(usage)%"
    }
    
    private var relativeCpu: String {
        guard
            vm.serverState != .offline,
            limits.cpu > 0,
            vm.cpuUsage.isFinite
        else {
            return "-"
        }
        
        let usage = Int(vm.cpuUsage / limits.cpu * 100)
        
        return "\(usage)%"
    }
    
    private var relativeDisk: String {
        guard
            limits.disk > 0,
            vm.diskUsage.isFinite
        else {
            return "-"
        }
        
        let usage = Int(vm.diskUsage / limits.disk * 100)
        
        return "\(usage)%"
    }
    
    var body: some View {
        HStack {
            Group {
                InfoStat("Uptime", value: Converter.millisecondsToTime(vm.uptime))
                    .numericTransition()
                
                InfoStat("Processor", value: relativeCpu)
                InfoStat("Memory", value: relativeRam)
                InfoStat("Storage", value: relativeDisk)
            }
            .frame(maxWidth: .infinity)
        }
        .multilineTextAlignment(.center)
    }
}

#Preview {
    InfoRelativeStats(PreviewProp.serverAttributes.limits)
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
