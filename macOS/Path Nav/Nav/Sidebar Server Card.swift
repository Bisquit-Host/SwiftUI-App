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
                
                Text(server.description)
                    .secondary()
                    .footnote()
            }
            .padding(.vertical, 5)
        }
    }
}
