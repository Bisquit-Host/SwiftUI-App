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
    private let rounding = 16.0
    
    private var backgroundColor: Color {
        vm.stateColor.opacity(0.12)
    }
    
    private var limits: ServerLimits {
        server.limits
    }
    
    var body: some View {
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
#warning("glassEffect")
        }
        .frame(height: 100)
        .padding(.horizontal)
        //        .glassEffect(in: .rect(cornerRadius: rounding))
        .background(
            ZStack {
                RoundedRectangle(cornerRadius: rounding)
                    .fill(.ultraThinMaterial)
                
                RoundedRectangle(cornerRadius: rounding)
                    .fill(backgroundColor)
            }
        )
        .overlay {
            RoundedRectangle(cornerRadius: rounding)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
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
        columns: [
            GridItem(.adaptive(minimum: 360))
        ],
        spacing: 8
    ) {
        ServerCard(sampleJSON(.serverListAttributes))
        ServerCard(sampleJSON(.serverListAttributes))
        ServerCard(sampleJSON(.serverListAttributes))
        ServerCard(sampleJSON(.serverListAttributes))
    }
    .darkSchemePreferred()
    .padding(5)
    .environmentObject(ValueStore())
}
