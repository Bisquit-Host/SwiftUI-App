import ScrechKit
import PteroNet

struct ServerCardStats: View {
    @Environment(ServerCardVM.self) private var vm
    
    private let limits: ServerLimits
    
    init(_ limits: ServerLimits) {
        self.limits = limits
    }
    
    var body: some View {
        HStack {
            if vm.stateColor != .red {
                GaugeRegular(
                    name: .cpu,
                    value: vm.cpuUsage,
                    limit: limits.cpu,
                    isRedacted: vm.isLoading
                )
                
                GaugeRegular(
                    name: .ram,
                    value: vm.ramUsage,
                    limit: limits.memory,
                    isRedacted: vm.isLoading
                )
            }
            
            GaugeRegular(
                name: .ssd,
                value: vm.diskUsage,
                limit: limits.disk,
                isRedacted: vm.isLoading
            )
        }
    }
}

#Preview {
    ServerCardStats(sampleJSON(.serverLimits))
        .darkSchemePreferred()
        .environment(ServerCardVM(""))
}
