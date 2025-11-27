import SwiftUI
import PteroNet

struct InfoRelativeStats: View {
    @Environment(PanelVM.self) private var vm
    
    private let limits: ServerLimits
    
    init(_ limits: ServerLimits) {
        self.limits = limits
    }
    
    private func percent(_ usage: Double, _ limit: Double) -> String {
        guard vm.serverState != .offline, limit > 0, usage.isFinite else { return "-" }
        
        let ratio = usage / limit * 100
        guard ratio.isFinite else { return "-" }
        
        let clamped = max(-1000.0, min(1000.0, ratio))
        return "\(Int(clamped.rounded()))%"
    }
    
    private var relativeRam: String {
        percent(vm.ramUsage, limits.memory * pow(1024, 2))
    }
    
    private var relativeCpu: String {
        percent(vm.cpuUsage, limits.cpu)
    }
    
    private var relativeDisk: String {
        percent(vm.diskUsage, limits.disk)
    }
    
    var body: some View {
        HStack {
            Group {
                InfoStat("Uptime", value: Converter.millisecondsToTime(vm.uptime))
                    .numericTransition(vm.uptime)
                    .animation(.default, value: vm.uptime)
                
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
