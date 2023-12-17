import SwiftUI
import PteroNet

struct ServerCardParent: View {
    private let server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
    }
    
    var body: some View {
        NavigationLink {
            PanelView(server.id)
        } label: {
            ServerCard(server)
        }
        .buttonBorderShape(.roundedRectangle(radius: 64))
    }
}

#Preview {
    ServerCardParent(
        sampleJSON(.serverListAttributes)
    )
    .padding()
    .glassBackgroundEffect()
}
