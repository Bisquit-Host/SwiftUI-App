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
            PanelView(server.id)
        } label: {
            ServerCard(server)
        }
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
        .padding()
        .glassBackgroundEffect()
}
