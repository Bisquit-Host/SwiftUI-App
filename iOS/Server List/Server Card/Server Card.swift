import ScrechKit
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    @Namespace private var animation
    private let bounds = UIScreen.main.bounds
    
    private var rounding: CGFloat {
        switch store.designCode {
        case 0: 25
        default: 16
        }
    }
    
    private var backgroundColor: Color {
        vm.stateColor.opacity(0.15)
    }
    
    private var limits: ServerLimits {
        server.limits
    }
    
    var body: some View {
        VStack {
            switch store.designCode {
            case 0:
                // Rect
                VStack {
                    serverName
                    
                    if vm.stateColor != .red {
                        HStack(spacing: 20) {
                            cpuGauge
                            
                            ramGauge
                        }
                        .matchedEffect("RAM_CPU", in: animation)
                    }
                    
                    diskGauge
                }
                .padding(.vertical, 5)
                .padding(.horizontal, 10)
                .frame(height: 150)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: rounding))
                .background(backgroundColor, in: .rect(cornerRadius: rounding))
                
            case 1:
                // Wide
                HStack {
                    VStack(alignment: .leading) {
                        serverName
                        
                        description
                        
                        diskGauge
                    }
                    
                    if vm.stateColor != .red {
                        HStack(spacing: 16) {
                            cpuGauge
                            
                            ramGauge
                        }
                        .matchedEffect("RAM_CPU", in: animation)
                    }
                }
                .frame(height: 100)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: rounding))
                .background(backgroundColor, in: .rect(cornerRadius: rounding))
                
            default:
                EmptyView()
            }
        }
        .task {
            vm.fetchServerUsage()
        }
        .onChange(of: store.updateServers) {
            vm.fetchServerUsage()
        }
    }
    
    private var serverName: some View {
        ServerName(server.name)
            .matchedEffect("name", in: animation)
    }
    
    private var description: some View {
        VStack {
            if !server.description.isEmpty {
                Text(server.description)
                    .footnote()
                    .secondary()
                    .foregroundStyle(.foreground)
                    .lineLimit(1)
            }
        }
        .matchedEffect("description", in: animation)
    }
    
    private var diskGauge: some View {
        GaugeDisk(vm.diskUsage, limit: limits.disk)
            .padding(.top, 2)
            .matchedEffect("disk", in: animation)
    }
    
    private var cpuGauge: some View {
        GaugeRegular(
            name: .cpu,
            value: vm.cpuUsage,
            limit: limits.cpu,
            isRedacted: vm.isLoading
        )
        .scaleEffect(1.1)
    }
    
    private var ramGauge: some View {
        GaugeRegular(
            name: .ram,
            value: vm.ramUsage,
            limit: limits.memory,
            isRedacted: vm.isLoading
        )
        .scaleEffect(1.1)
    }
}

#Preview {
    LazyVGrid(
        columns: [GridItem(.adaptive(minimum: 160, maximum: 400))],
        spacing: 8
    ) {
        ServerCard(sampleJSON(.serverListAttributes))
        
        ServerCard(sampleJSON(.serverListAttributes))
        
        ServerCard(sampleJSON(.serverListAttributes))
        
        ServerCard(sampleJSON(.serverListAttributes))
    }
    .padding(5)
    .environmentObject(ValueStore())
}
