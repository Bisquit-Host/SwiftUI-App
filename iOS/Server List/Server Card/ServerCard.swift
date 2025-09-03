import SwiftUI
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = .init(server.id)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if vm.stateColor != .gray {
                            Circle()
                                .fill(vm.stateColor.gradient)
                                .frame(10)
                        }
                        
                        Text(server.name)
                            .headline()
                            .semibold()
                    }
                    
                    if !server.description.isEmpty {
                        Text(server.description)
                            .subheadline()
                            .secondary()
                    }
                }
                
                Spacer()
                
                if vm.stateColor == .gray {
                    Image(systemName: "snowflake")
                        .largeTitle()
                }
            }
            
            if vm.stateColor != .gray {
                VStack(spacing: 12) {
                    if vm.stateColor != .red {
                        MetricGauge(
                            title: "CPU",
                            value: vm.cpuUsage / server.limits.cpu,
                            color: .blue,
                            icon: "cpu"
                        )
                        
                        MetricGauge(
                            title: "RAM",
                            value: vm.ramUsage / (server.limits.memory * pow(1024, 2)),
                            color: .green,
                            icon: "memorychip"
                        )
                    }
                    
                    MetricGauge(
                        title: "Disk",
                        value: vm.diskUsage / (server.limits.disk * pow(1024, 2)),
                        color: .orange,
                        icon: "internaldrive"
                    )
                }
            }
        }
        .padding(20)
        .glassEffect(in: .rect(cornerRadius: 16))
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
