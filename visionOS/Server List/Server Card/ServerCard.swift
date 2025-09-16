import SwiftUI
import PteroNet

struct ServerCard: View {
    @EnvironmentObject private var store: ValueStore
    @State private var vm: ServerCardVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = ServerCardVM(server.id)
    }
    
    private let gradient = Gradient(colors: [.mint, .orange, .red])
    
    private var limits: ServerLimits {
        server.limits
    }
    
    var body: some View {
        HStack(spacing: 50) {
            VStack(alignment: .leading) {
                Text(server.name)
                    .largeTitle()
                
                if !server.description.isEmpty {
                    Text(server.description)
                        .title()
                        .secondary()
                }
            }
            
            Spacer()
            
            Group {
                if vm.stateColor != .red {
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
                }
                
                CircularGauge(
                    param: "SSD",
                    value: vm.diskUsage,
                    limit: limits.disk,
                    isRedacted: vm.isLoading
                )
            }
            .scaleEffect(1.5)
        }
        .padding()
        .task {
            await vm.fetchServerUsage()
        }
        .onChange(of: store.updateServers) {
            Task {
                await vm.fetchServerUsage()
            }
        }
    }
}

#Preview {
    List {
        ServerCard(PreviewProp.serverAttributes)
    }
    .padding()
    .environmentObject(ValueStore())
}
