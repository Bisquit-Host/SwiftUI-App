import SwiftUI
import Calagopus

struct ServerCardParent: View {
    @Environment(NavState.self) private var nav
    
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        Button {
            nav.navigate(.toPanel(server.id))
        } label: {
            ServerCard(server)
        }
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .environment(NavState())
}
