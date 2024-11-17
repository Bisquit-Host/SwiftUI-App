import ScrechKit
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    @EnvironmentObject private var settings: SettingsStorage
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    @Namespace private var animation
    private let bounds = UIScreen.main.bounds
    
    private var backgroundColor: Color {
        vm.stateColor.opacity(0.15)
    }
    
    private var limits: ServerLimits {
        server.limits
    }
    
    private var name: String {
        server.name.replacing(" ", with: "")
    }
    
    var body: some View {
        VStack {
            switch settings.designCode {
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
                .frame(maxHeight: .infinity)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: vm.stateColor != .red ? 22 : 16))
                .background(backgroundColor, in: .rect(cornerRadius: vm.stateColor != .red ? 22 : 16))
                
            case 1:
                // Line
                HStack {
                    VStack {
                        serverName
                        
                        diskGauge
                    }
                    
                    if vm.stateColor != .red {
                        HStack {
                            cpuGauge
                            
                            ramGauge
                        }
                        .matchedEffect("RAM_CPU", in: animation)
                    }
                }
                .frame(height: 90)
                .padding(.horizontal)
                .background(.ultraThinMaterial, in: .rect(cornerRadius: vm.stateColor != .red ? 22 : 16))
                .background(backgroundColor, in: .rect(cornerRadius: vm.stateColor != .red ? 22 : 16))
                
            default:
                EmptyView()
            }
        }
        .task {
            vm.fetchServerUsage()
        }
        .onChange(of: settings.updateServers) {
            vm.fetchServerUsage()
        }
    }
    
    private var serverName: some View {
        ServerName(name, color: vm.stateColor)
            .matchedEffect("name", in: animation)
    }
    
    private var diskGauge: some View {
        DiskGauge(vm.diskUsage, limit: limits.disk)
            .padding(.top, 4)
            .matchedEffect("disk", in: animation)
    }
    
    private var cpuGauge: some View {
        RegularGauge(
            name: .cpu,
            value: vm.cpuUsage,
            limit: limits.cpu,
            isRedacted: vm.isLoading
        )
        .scaleEffect(1.1)
    }
    
    private var ramGauge: some View {
        RegularGauge(
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
        columns: [
            GridItem(.adaptive(minimum: 160, maximum: 400))
        ],
        spacing: 8
    ) {
        ServerCard(sampleJSON(.serverListAttributes))
        
        ServerCard(sampleJSON(.serverListAttributes))
        
        ServerCard(sampleJSON(.serverListAttributes))
        
        ServerCard(sampleJSON(.serverListAttributes))
    }
    .padding(5)
    .environmentObject(SettingsStorage())
}
