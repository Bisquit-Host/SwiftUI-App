import ScrechKit
import PteroNet

struct ServerCard: View {
    private var vm: ServerCardVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = ServerCardVM(server.id)
    }
    
    private var limits: ServerLimits {
        server.limits
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                Text(server.name)
                    .fontSize(70)
                    .fontWeight(.medium)
                
                Text(server.description)
            }
            
            Spacer()
            
            ProgressBar("cpu",
                        progress: vm.cpuUsage / limits.cpu
            )
            
            ProgressBar("ram",
                        progress: vm.ramUsage / pow(1024, 2) / limits.memory
            )
            
            ProgressBar("ssd",
                        progress: vm.diskUsage / pow(1024, 2) / limits.disk
            )
        }
        .padding(.bottom)
        .task {
            vm.fetchServerUsage()
        }
        .contextMenu {
            ServerCardContextMenu(server.id)
        }
    }
}

#Preview {
    ServerCard(
        sampleJSON(.serverListAttributes)
    )
}
