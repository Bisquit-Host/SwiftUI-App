import ScrechKit
import PteroNet

struct ServerCard: View {
    @EnvironmentObject private var store: ValueStore
    @Environment(\.accessibilityDifferentiateWithoutColor) private var differentiateWithoutColor
    
    @State private var vm: ServerCardVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = ServerCardVM(server.id)
    }
    
    var body: some View {
        let limits = server.limits
        
        HStack {
            VStack(alignment: .leading, spacing: 16) {
                if differentiateWithoutColor {
                    Text(vm.state.rawValue)
                }
                
                Text(server.name)
                    .fontSize(70)
                    .fontWeight(.medium)
                    .blur(radius: store.hideServerNames ? 12 : 0)
                
                Text(server.description)
                    .blur(radius: store.hideServerNames ? 5 : 0)
            }
            
            Spacer()
            
            if vm.state != .offline {
                let cpuUsage = vm.cpuUsage / limits.cpu
                ProgressBar("cpu", progress: cpuUsage)
                
                let ramUsage = vm.ramUsage / pow(1024, 2) / limits.memory
                ProgressBar("ram", progress: ramUsage)
            }
            
            let ssdUsage = vm.diskUsage / pow(1024, 2) / limits.disk
            ProgressBar("ssd", progress: ssdUsage)
        }
        .padding(.bottom)
        .task {
            await vm.fetchServerUsage()
        }
        .contextMenu {
            ServerCardContextMenu(server.id)
        }
    }
}

#Preview {
    ServerCard(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
