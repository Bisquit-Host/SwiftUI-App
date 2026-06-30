import ScrechKit
import Calagopus

struct StatsTab: View {
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        VStack {
            Text(server.id)
            Text(server.name)
            Text(server.description ?? "")
            Text(server.nodeName)
        }
    }
}

#Preview {
    StatsTab(PreviewProp.serverAttributes)
        .padding()
        .darkSchemePreferred()
}
