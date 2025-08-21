import ScrechKit
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(server.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
                
                if !vm.isLoading {
                    PulseCircle(vm.stateColor, size: 12)
                }
            }
            
            ServerCardStats(server.limits)
                .environment(vm)
        }
        .task {
            await vm.fetchServerUsage()
        }
    }
}

#Preview {
    ServerCard(sampleJSON(.serverListAttributes))
        .darkSchemePreferred()
}
