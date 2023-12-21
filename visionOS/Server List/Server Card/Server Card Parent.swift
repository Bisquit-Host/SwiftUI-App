import SwiftUI
import PteroNet

struct ServerCardParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
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
