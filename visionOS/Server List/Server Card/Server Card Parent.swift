import SwiftUI
import PteroNet

struct ServerCardParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var showSafari = false
    
    var body: some View {
        NavigationLink {
            PanelView(server.id)
        } label: {
            ServerCard(server)
        }
        .buttonBorderShape(.roundedRectangle(radius: 64))
        .contextMenu {
            ServerCardContextMenu($showSafari, id: server.id)
        }
    }
}

#Preview {
    ServerCardParent(
        sampleJSON(.serverListAttributes)
    )
    .padding()
    .glassBackgroundEffect()
}
