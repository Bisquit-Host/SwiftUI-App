import SwiftUI
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var navState
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var contextMenu = false
    
    var body: some View {
        VStack {
            if server.isSuspended {
                SuspendedCard(server.name)
            } else {
                ServerCard(server)
            }
        }
        .buttonStyle(.plain)
        .onTapGesture {
            navState.navigate(.toPanel(server.id))
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
        .environment(NavState())
}
