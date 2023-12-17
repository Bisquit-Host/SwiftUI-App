import SwiftUI
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var navState
    
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
    }
    
    @State private var showSafari = false
    
    var body: some View {
        VStack {
            if server.is_suspended {
                SuspendedServerCard(server.name)
                    .popoverTip(Tip_SuspendedServer())
            } else {
                Button {
                    navState.navigate(.toPanel(server.id))
                } label: {
                    ServerCard(server)
                }
            }
        }
        .safariCover($showSafari, url: "https://mgr.bisquit.host/server/\(server.id)")
        .contextMenu {
            ServerCardContextMenu($showSafari, id: server.id)
        }
    }
}

#Preview {
    ServerCardParent(
        sampleJSON(.serverListAttributes)
    )
    .environment(NavState())
    .environmentObject(SettingsStorage())
}
