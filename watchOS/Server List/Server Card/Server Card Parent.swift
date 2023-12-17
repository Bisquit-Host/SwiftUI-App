import SwiftUI
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var navState
    
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
    }
    
    var body: some View {
        Button {
            navState.navigate(.toPanel(server.id))
        } label: {
            if server.is_suspended {
                SuspendedCard(server.name)
            } else {
                ServerCard(server)
            }
        }
    }
}

#Preview {
    ServerCardParent(
        sampleJSON(.serverListAttributes)
    )
    .environment(NavState())
}
