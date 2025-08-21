import SwiftUI
import PteroNet

struct ServerCardParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    var body: some View {
        NavigationLink {
            PanelView(server)
        } label: {
            ServerCard(server)
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
        .darkSchemePreferred()
        .padding()
        .glassBackgroundEffect()
}
