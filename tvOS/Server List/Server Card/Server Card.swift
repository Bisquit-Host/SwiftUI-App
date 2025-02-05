import ScrechKit
import PteroNet

struct ServerCard: View {
    @State private var vm: ServerCardVM
    
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
            
            let cpuUsage = vm.cpuUsage / limits.cpu
            ProgressBar("cpu", progress: cpuUsage)
            
            let ramUsage = vm.ramUsage / pow(1024, 2) / limits.memory
            ProgressBar("ram", progress: ramUsage)
            
            let ssdUsage = vm.diskUsage / pow(1024, 2) / limits.disk
            ProgressBar("ssd", progress: ssdUsage)
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
    ServerCard(sampleJSON(.serverListAttributes))
}
