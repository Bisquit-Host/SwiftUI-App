import SwiftUI
import PteroNet

struct NewServerCard: View {
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
                    
                    Text(server.description)
                        .subheadline()
                        .secondary()
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
        .background {
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 10, x: 0, y: 5)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.white.opacity(0.2), lineWidth: 1)
        }
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
