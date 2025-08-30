import SwiftUI
import PteroNet

struct CompactServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = .init(server.id)
    }
    
    var body: some View {
        VStack(spacing: 5) {
            if vm.stateColor == .gray {
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
                        if vm.stateColor != .gray {
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
                                CompactMetricRow(icon: "cpu", value: vm.cpuUsage / server.limits.cpu, color: .blue)
                                CompactMetricRow(icon: "memorychip", value: vm.ramUsage / (server.limits.memory * pow(1024, 2)), color: .green)
                            } else {
                                Spacer()
                            }
                            
                            CompactMetricRow(icon: "internaldrive", value: vm.diskUsage / (server.limits.disk * pow(1024, 2)), color: .orange)
                        }
                    }
                }
            }
        }
        .padding(12)
        .frame(height: 105)
        .background {
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .overlay {
            RoundedRectangle(cornerRadius: 12)
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
