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
    
    private var serverUrl: String {
        "https://mgr.bisquit.host/server/\(server.id)"
    }
    
    var body: some View {
        VStack {
            if server.isSuspended {
                SuspendedServerCard(server.name)
            } else {
                Button {
                    navState.navigate(.toPanel(server.id))
                } label: {
                    ServerCard(server)
                        .foregroundStyle(.foreground)
                }
            }
        }
        .hoverEffect()
        .safariCover($showSafari, url: serverUrl)
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                kill()
            }
        }
        .onDrag {
            let url = URL(string: serverUrl)
            
            if let itemProvider = NSItemProvider(contentsOf: url) {
                return itemProvider
            }
            
            return NSItemProvider()
        }
    }
    
    private func kill() {
        Task {
            await PteroNet.powerSignal(server.id, do: .kill)
        }
    }
}

#Preview {
    ServerCardParent(sampleJSON(.serverListAttributes))
        .environment(NavState())
}
