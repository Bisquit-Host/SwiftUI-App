import SwiftUI
import Calagopus

struct ServerCardParent: View {
    @Environment(NavState.self) private var nav
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        Button {
            if !server.isSuspended {
                nav.navigate(.toPanel(server.id))
            }
        } label: {
            ServerCardWide(server)
        }
        .buttonStyle(.plain)
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await CalagopusNet.powerSignal(server.id, do: .kill)
                }
            }
        }
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .padding()
        .glassBackgroundEffect()
}
