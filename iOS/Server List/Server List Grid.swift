import ScrechKit
import PteroNet

struct ServerListGrid: View {
    @EnvironmentObject private var settings: ValueStorage
    
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
                GridItem(
                    .adaptive(minimum: settings.designCode == 0 ? 170 : 360)
                )
            ],
            spacing: 8
        ) {
//            if settings.isApiKeyValid {
                ForEach(servers) { server in
                    ServerCardParent(server)
                }
//            } else {
//                ServerCardParent(demoServer)
//            }
        }
#endif
    }
}

#Preview {
    ServerListGrid(
        sampleJSON(.serverListDataArray)
    )
///    .environment(NavState())
    .environmentObject(ValueStorage())
}
