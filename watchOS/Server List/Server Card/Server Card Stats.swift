import ScrechKit
import PteroNet

struct ServerCardStats: View {
    @Environment(ServerCardVM.self) private var vm
    
    private let limits: ServerListLimits
    
    init(_ limits: ServerListLimits) {
        self.limits = limits
    }
    
    var body: some View {
        HStack {
            RegularGauge(.cpu,
                         value: vm.cpu_usage,
                         limit: limits.cpu,
                         isRedacted: vm.isLoadingData
            )
            
            RegularGauge(.ram,
                         value: vm.ram_usage,
                         limit: limits.memory,
                         isRedacted: vm.isLoadingData
            )
            
            RegularGauge(.ssd,
                         value: vm.disk_usage,
                         limit: limits.disk,
                         isRedacted: vm.isLoadingData
            )
        }
    }
}

#Preview {
    ServerCardStats(
        sampleJSON(.serverLimits)
    )
    .environment(ServerCardVM(""))
}
