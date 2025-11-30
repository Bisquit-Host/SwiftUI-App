import ScrechKit
import PteroNet

struct ServerCardParent: View {
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    private let serverURL: String
    
    init(_ server: ServerAttributes) {
        self.server = server
        serverURL = "https://mgr.bisquit.host/server/" + server.id
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        VStack {
            NavigationLink(value: server) {
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
