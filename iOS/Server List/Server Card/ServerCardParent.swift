import ScrechKit
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack {
            Button {
                if !server.isSuspended {
                    nav.navigate(.toPanel(server.id))
                }
            } label: {
                if store.compactServerList {
                    CompactServerCard(server)
                } else {
                    ServerCard(server)
                }
            }
            .foregroundStyle(.foreground)
        }
        .buttonStyle(.plain)
        .hoverEffect()
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
