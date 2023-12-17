import ScrechKit
import PteroNet

struct ServerCard: View {
    private var vm: ServerCardVM
    
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    var body: some View {
        VStack {
            HStack {
                Text(server.name)
                    .lineLimit(1)
                    .minimumScaleFactor(0.25)
                
                if !vm.isLoadingData {
                    PulseCircle(vm.stateColor, size: 12)
                }
            }
            
            ServerCardStats(server.limits)
                .environment(vm)
        }
        .task {
            vm.fetchServerUsage()
        }
    }
}

#Preview {
    ServerCard(
        sampleJSON(.serverListAttributes)
    )
}
