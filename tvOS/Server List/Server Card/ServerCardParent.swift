import SwiftUI
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var nav
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        Button {
            nav.navigate(.toPanel(server))
        } label: {
            ServerCardWide(server)
        }
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .environment(NavState())
}
