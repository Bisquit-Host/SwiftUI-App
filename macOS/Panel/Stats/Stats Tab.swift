import ScrechKit
import PteroNet

struct StatsTab: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
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
    StatsTab(PreviewProp.serverAttributes)
        .padding()
        .darkSchemePreferred()
}
