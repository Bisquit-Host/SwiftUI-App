import ScrechKit
import PteroNet
import SafariCover

struct ServerCardParent: View {
    //    @Environment(NavState.self) private var nav
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        VStack {
            //            if server.isSuspended {
            //                SuspendedServerCard(server.name)
            //            } else {
            Button {
                //                    nav.navigate(.toPanel(server.id))
            } label: {
                ServerCard(server)
            }
            //            }
        }
        .safariCover($showSafari, url: "https://mgr.bisquit.host/server/" + server.id)
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
    //        .environment(NavState())
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
