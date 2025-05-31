import ScrechKit
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var navState
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        let serverUrl = "https://mgr.bisquit.host/server/\(server.id)"
        
        VStack {
            if server.isSuspended {
                SuspendedServerCard(server.name)
            } else {
                Button {
                    navState.navigate(.toPanel(server.id))
                } label: {
                    ServerCard(server)
                }
            }
        }
        .hoverEffect()
        .safariCover($showSafari, url: serverUrl)
        .onDrag {
            NSItemProvider(contentsOf: URL(string: serverUrl))!
        }
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await PteroNet.powerSignal(server.id, do: .kill)
                }
            }
        }
    }
}

#Preview {
    ServerCardParent(sampleJSON(.serverListAttributes))
        .environment(NavState())
        .environmentObject(ValueStore())
}
