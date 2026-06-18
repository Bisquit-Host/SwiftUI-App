import SwiftUI
import PteroNet

struct ServerCardCompact: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = ServerCardVM(server.id)
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        VStack(spacing: 5) {
            if differentiateWithoutColor {
                Text(vm.state.rawValue)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            if vm.state == .suspended {
                Image(systemName: "snowflake")
                    .largeTitle()
                    .secondary()
                
                Text(server.name)
                    .fontSize(14)
                    .semibold()
                    .lineLimit(1)
                    .frame(maxWidth: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 12) {
                    HStack(spacing: 8) {
                        Circle()
                            .fill(vm.stateColor.gradient)
                            .frame(6)
                        
                        Text(server.name)
                            .fontSize(14)
                            .semibold()
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    if vm.stateColor != .gray {
                        VStack(spacing: 8) {
                            if vm.stateColor != .red {
                                MetricGaugeCompact(
                                    icon: "cpu",
                                    value: vm.cpuUsage / server.limits.cpu,
                                    color: .blue
                                )
                                
                                MetricGaugeCompact(
                                    icon: "memorychip",
                                    value: vm.ramUsage / (server.limits.memory * pow(1024, 2)),
                                    color: .green
                                )
                            } else {
                                Spacer()
                            }
                            
                            MetricGaugeCompact(
                                icon: "internaldrive",
                                value: vm.diskUsage / (server.limits.disk * pow(1024, 2)),
                                color: .orange
                            )
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(height: 105)
        .contentShape(.rect)
        .glassEffect(in: .rect(cornerRadius: 12))
        .task {
            await vm.fetchServerUsage()
        }
        .onChange(of: store.updateServers) {
            Task {
                await vm.fetchServerUsage()
            }
        }
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
#if canImport(SafariCover)
        .safariCover($showSafari, url: vm.serverURL)
#endif
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await PteroNet.powerSignal(server.id, do: .kill)
                }
            }
        }
    }
}
