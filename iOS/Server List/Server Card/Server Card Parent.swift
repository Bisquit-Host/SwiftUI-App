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
        .safariCover($showSafari, url: "https://mgr.bisquit.host/server/\(server.id)")
        .contextMenu {
            ServerCardContextMenu(server.id, showSafari: $showSafari, confirmKill: $confirmKill)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                PteroNet.powerSignal(server.id, signal: .kill)
            }
        }
    }
}

#Preview {
    ServerCardParent(sampleJSON(.serverListAttributes))
        .environment(NavState())
        .environmentObject(SettingsStorage())
}
