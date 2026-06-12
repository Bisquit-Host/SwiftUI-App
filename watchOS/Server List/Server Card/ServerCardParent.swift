import SwiftUI
import PteroNet

struct ServerCardParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var contextMenu = false
    
    var body: some View {
        NavigationLink {
            PanelView(server.id)
        } label: {
            VStack {
                if server.isSuspended {
                    SuspendedServerCard(server.name)
                } else {
                    ServerCardWide(server)
                }
            }
        }
        .disabled(server.isSuspended)
        .buttonStyle(.plain)
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
}
