import ScrechKit
import Calagopus

struct ServerListGrid: View {
    @EnvironmentObject private var store: ValueStore
    
    private let servers: [ServerAttributes]
    
    init(_ servers: [ServerAttributes]) {
        self.servers = servers
    }
    
    private let columns = [
        GridItem(.flexible()), GridItem(.flexible())
    ]
    
    var body: some View {
        Group {
            if store.compactServerList {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(servers) {
                        ServerCardParent($0)
                    }
                }
            } else {
                LazyVStack(spacing: 16) {
                    ForEach(servers) {
                        ServerCardParent($0)
                    }
                }
            }
        }
#if !os(macOS)
        .scenePadding([.horizontal, .bottom])
#endif
    }
}

#Preview {
    ServerListGrid([PreviewProp.serverAttributes])
        .darkSchemePreferred()
        .environmentObject(ValueStore())
}
