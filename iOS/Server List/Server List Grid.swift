import ScrechKit
import PteroNet

struct ServerListGrid: View {
    @EnvironmentObject private var store: ValueStore
    
    private let servers: [ServerAttributes]
    
    init(_ servers: [ServerAttributes]) {
        self.servers = servers
    }
    
    var body: some View {
#if os(watchOS)
        LazyVStack {
            ForEach(servers) { server in
                ServerCardParent(server)
            }
        }
#else
        LazyVGrid(
            columns: [
                GridItem(.adaptive(
                    minimum: store.designCode == 0 ? 170 : 360
                ))
            ],
            spacing: 8
        ) {
            ForEach(servers) { server in
                ServerCardParent(server)
            }
        }
#endif
    }
}

#Preview {
    ServerListGrid(sampleJSON(.serverListDataArray))
        .environmentObject(ValueStore())
}
