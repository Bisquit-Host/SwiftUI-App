import ScrechKit
import Calagopus

struct ServerListGrid: View {
    private let servers: [CalagopusServer]
    
    init(_ servers: [CalagopusServer]) {
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
