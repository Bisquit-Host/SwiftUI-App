import ScrechKit
import PteroNet

struct ServerListGrid: View {
    @EnvironmentObject private var store: ValueStore
    
    private let servers: [ServerAttributes]
    
    init(_ servers: [ServerAttributes]) {
        self.servers = servers
    }
    
    private let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
#if os(watchOS)
        LazyVStack {
            ForEach(servers) { server in
                ServerCardParent(server)
            }
        }
#else
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
        .scenePadding()
#endif
    }
}

#Preview {
    ServerListGrid(sampleJSON(.serverListDataArray))
        .environmentObject(ValueStore())
}
