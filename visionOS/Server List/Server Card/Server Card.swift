import SwiftUI
import PteroNet

struct ServerCard: View {
    private var vm: ServerCardVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    private var limits: ServerLimits {
        server.limits
    }
    
    var body: some View {
        HStack {
            Text(server.name)
            
            CircularGauge("CPU",
                          value: vm.cpuUsage,
                          limit: limits.cpu,
                          isRedacted: vm.isLoading)
            
            CircularGauge("RAM",
                          value: vm.ramUsage,
                          limit: limits.memory,
                          isRedacted: vm.isLoading)
            
            LinearGauge(value: vm.diskUsage, limit: limits.disk)
        }
        
        //        VStack {
        //            Text(server.name)
        //
        //            HStack {
        //                CircularGauge("CPU",
        //                              value: vm.cpuUsage,
        //                              limit: limits.cpu,
        //                              isRedacted: vm.isLoading)
        //
        //                CircularGauge("RAM",
        //                              value: vm.ramUsage,
        //                              limit: limits.memory,
        //                              isRedacted: vm.isLoading)
        //            }
        //
        //            LinearGauge(value: vm.diskUsage, limit: limits.disk)
        //        }
        .padding(.vertical)
        .task {
            vm.fetchServerUsage()
        }
    }
}

#Preview {
    ServerCard(
        sampleJSON(.serverListAttributes)
    )
    .padding()
    .glassBackgroundEffect()
}
