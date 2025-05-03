import SwiftUI
import PteroNet

struct SidebarServerCard: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        NavigationLink(value: server) {
            VStack(alignment: .leading) {
                Text(server.name)
                    .title3(.semibold)
                
                if !server.description.isEmpty {
                    Text(server.description)
                        .secondary()
                }
            }
            .padding(.vertical, 5)
        }
    }
}
