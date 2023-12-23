import SwiftUI
import PteroNet

struct ServerCard: View {
    @Environment(ServerListVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        NavigationLink {
            PanelView(server.id)
        } label: {
            Text(server.name)
        }
//        Button {
//            vm.selectedServer = server
//        } label: {
//            Text(server.name)
//        }
    }
}

#Preview {
    ServerCard(
        sampleJSON(.serverListAttributes)
    )
}
