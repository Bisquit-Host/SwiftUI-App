import SwiftUI
import PteroNet

struct ServerCard: View {
    @EnvironmentObject private var settings: ValueStorage
    @State private var vm: ServerCardVM
    
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
        VStack(alignment: .leading, spacing: 16) {
            Text(server.name)
                .title()
            
            HStack(spacing: 20) {
                CircularGauge(
                    param: "CPU",
                    value: vm.cpuUsage,
                    limit: limits.cpu,
                    isRedacted: vm.isLoading
                )
                
                CircularGauge(
                    param: "RAM",
                    value: vm.ramUsage,
                    limit: limits.memory,
                    isRedacted: vm.isLoading
                )
                
                CircularGauge(
                    param: "RAM",
                    value: vm.diskUsage,
                    limit: limits.disk,
                    isRedacted: vm.isLoading
                )
                
                //                LinearGauge(value: vm.diskUsage, limit: limits.disk)
            }
            .padding(.vertical)
            .task {
                vm.fetchServerUsage()
            }
            .onChange(of: settings.updateServers) {
                vm.fetchServerUsage()
            }
        }
    }
}

#Preview {
    List {
        ServerCard(PreviewProperty.serverAttributes)
    }
    .padding()
}
