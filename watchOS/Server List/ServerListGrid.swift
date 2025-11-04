import ScrechKit
import PteroNet

struct ServerListGrid: View {
    private let servers: [ServerAttributes]
    
    init(_ servers: [ServerAttributes]) {
        self.servers = servers
    }
    
    var body: some View {
        LazyVStack {
            ForEach(servers) {
                ServerCardParent($0)
            }
        }
    }
}

#Preview {
    ServerListGrid([PreviewProp.serverAttributes])
        .darkSchemePreferred()
}
