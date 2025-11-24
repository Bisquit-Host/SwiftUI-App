import SwiftUI
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var nav
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var contextMenu = false
    
    var body: some View {
        VStack {
            if server.isSuspended {
                SuspendedServerCard(server.name)
            } else {
                ServerCardWide(server)
            }
        }
        .buttonStyle(.plain)
        .onTapGesture {
            nav.navigate(.toPanel(server.id))
        }
        .onLongPressGesture {
            if !server.isSuspended {
                contextMenu = true
            }
        }
        .sheet($contextMenu) {
            ServerCardContextMenu(server)
        }
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(NavState())
}
