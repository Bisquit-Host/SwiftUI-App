import SwiftUI
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var navState
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        Button {
            navState.navigate(.toPanel(server.id))
        } label: {
            if server.isSuspended {
                SuspendedCard(server.name)
            } else {
                ServerCard(server)
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    ServerCardParent(
        sampleJSON(.serverListAttributes)
    )
    .environment(NavState())
}
