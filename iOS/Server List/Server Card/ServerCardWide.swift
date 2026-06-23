import ScrechKit
import Calagopus

struct ServerCardWide: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
        vm = ServerCardVM(server.id)
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: System.isWatch ? 10 : 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        if !server.isSuspended {
                            Circle()
                                .fill(vm.stateColor.gradient)
                                .frame(10)
                        }
                        
                        Text(server.name)
                            .lineLimit(1)
                            .semibold()
                            .headline()
                        
                        Spacer()
                        
                        if differentiateWithoutColor {
                            Text(vm.state.rawValue)
                        }
                    }
                    
                    if let description = server.description, !description.isEmpty, store.serverCardDescription, System.isWatch {
                        Text(description)
                            .lineLimit(2)
                            .secondary()
                            .footnote()
                            .multilineTextAlignment(.leading)
                    } else if let description = server.description, !description.isEmpty, store.serverCardDescription {
                        Text(description)
                            .lineLimit(2)
                            .secondary()
                            .subheadline()
                            .multilineTextAlignment(.leading)
                    }
                }
                
                Spacer()
                
                if server.isSuspended {
                    Image(systemName: "snowflake")
                        .largeTitle()
                }
            }
            
            if !server.isSuspended {
                VStack(spacing: System.isWatch ? 6 : 12) {
                    if vm.stateColor != .red {
                        MetricGauge(
                            title: "CPU",
                            value: vm.cpuUsage / Double(server.limits.cpu),
                            color: .blue,
                            icon: "cpu"
                        )
                        
                        MetricGauge(
                            title: "RAM",
                            value: vm.ramUsage / (Double(server.limits.memory) * pow(1024, 2)),
                            color: .green,
                            icon: "memorychip"
                        )
                    }
                    
                    MetricGauge(
                        title: "SSD",
                        value: vm.diskUsage / (Double(server.limits.disk) * pow(1024, 2)),
                        color: .orange,
                        icon: "internaldrive"
                    )
                }
            }
        }
        .padding(System.isWatch ? 10 : 20)
        .contentShape(.rect)
#if !os(watchOS)
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .onDrag {
            if let url = URL(string: vm.serverURL), let itemProvider = NSItemProvider(contentsOf: url) {
                itemProvider
            } else {
                NSItemProvider()
            }
        }
#endif
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
#if canImport(SafariCover)
        .safariCover($showSafari, url: vm.serverURL)
#endif
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await CalagopusNet.powerSignal(server.id, do: .kill)
                }
            }
        }
    }
}

#Preview {
    ServerCardWide(PreviewProp.serverAttributes)
        .environmentObject(ValueStore())
}
