import ScrechKit
import Calagopus

struct ServerCardParent: View {
    @EnvironmentObject private var store: ValueStore
    
    private let server: CalagopusServer
    private let serverURL: String
    
    init(_ server: CalagopusServer) {
        self.server = server
        serverURL = Endpoint.bisquitPter + "/server/" + server.id
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        VStack {
            NavigationLink(value: server.id) {
                if store.compactServerList {
                    ServerCardCompact(server)
                } else {
                    ServerCardWide(server)
                }
            }
            .foregroundStyle(.foreground)
        }
        .buttonStyle(.plain)
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .onDrag {
            let url = URL(string: serverURL)
            
            if let itemProvider = NSItemProvider(contentsOf: url) {
                return itemProvider
            }
            
            return NSItemProvider()
        }
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
