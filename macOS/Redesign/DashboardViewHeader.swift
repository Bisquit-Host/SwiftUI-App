import SwiftUI
import Calagopus

struct DashboardViewHeader: View {
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(server.name)
                .largeTitle(.bold)
            
            Text(server.description ?? "")
                .title3()
                .secondary()
                .animation(.default, value: server.description)
        }
    }
}

#Preview {
    DashboardViewHeader(PreviewProp.serverAttributes)
        .darkSchemePreferred()
}
