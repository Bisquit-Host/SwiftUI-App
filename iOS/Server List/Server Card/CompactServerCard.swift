import SwiftUI
import PteroNet

struct CompactServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = ServerCardVM(server.id)
    }
    
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
                        if !differentiateWithoutColor {
                            Circle()
                                .fill(vm.stateColor.gradient)
                                .frame(6)
                        }
                        
                        Text(server.name)
                            .fontSize(14)
                            .semibold()
                            .lineLimit(1)
                        
                        Spacer()
                    }
                    
                    if vm.stateColor != .gray {
                        VStack(spacing: 8) {
                            if vm.stateColor != .red {
                                CompactMetricRow(
                                    icon: "cpu",
                                    value: vm.cpuUsage / server.limits.cpu,
                                    color: .blue
                                )
                                
                                CompactMetricRow(
                                    icon: "memorychip",
                                    value: vm.ramUsage / (server.limits.memory * pow(1024, 2)),
                                    color: .green
                                )
                            } else {
                                Spacer()
                            }
                            
                            CompactMetricRow(
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
        .glassEffect(in: .rect(cornerRadius: 12))
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
