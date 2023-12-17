import ScrechKit
import PteroNet

struct StatsTab: View {
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
    }
    
    var body: some View {
        VStack {
            Text(server.id)
            
            Text(server.name)
            
            Text(server.description)
            
            Text(server.node)
        }
    }
}

#Preview {
    StatsTab(
        sampleJSON(.serverListAttributes)
    )
    .padding()
}
