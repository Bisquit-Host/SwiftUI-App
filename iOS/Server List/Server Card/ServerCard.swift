import SwiftUI
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = ServerCardVM(server.id)
    }
    
    private var isSuspended: Bool {
        vm.stateColor == .gray
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: System.isWatch ? 10 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if vm.stateColor != .gray {
                            Circle()
                                .fill(vm.stateColor.gradient)
                                .frame(10)
                        }
                        
                        Text(server.name)
                            .lineLimit(1)
                            .semibold()
                            .headline()
                    }
                    
                    if !server.description.isEmpty, store.serverCardDescription {
                        Text(server.description)
                            .lineLimit(2)
                            .secondary()
                            .font(System.isWatch ? .footnote : .subheadline)
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                if isSuspended {
                    Image(systemName: "snowflake")
                        .largeTitle()
                }
            }
            
            if vm.stateColor != .gray {
                VStack(spacing: System.isWatch ? 6 : 12) {
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
        .padding(System.isWatch ? 10 : 20)
#if !os(visionOS) && !os(macOS)
        .glassEffect(in: .rect(cornerRadius: 16))
#endif
#if os(macOS)
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
#endif
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
    ServerCard(PreviewProp.serverAttributes)
        .environmentObject(ValueStore())
}
