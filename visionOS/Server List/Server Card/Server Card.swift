import SwiftUI
import PteroNet

struct ServerCard: View {
    private var vm: ServerCardVM
    
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    private var limits: ServerListLimits {
        server.limits
    }
    
    var body: some View {
        VStack {
            Text(server.name)
            
            HStack {
                CircularGauge("CPU", value: vm.cpu_usage, limit: limits.cpu, isRedacted: vm.isLoadingData)
                
                CircularGauge("RAM", value: vm.ram_usage, limit: limits.memory, isRedacted: vm.isLoadingData)
            }
            
            LinearGauge(value: vm.disk_usage, limit: limits.disk)
        }
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
