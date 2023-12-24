import SwiftUI
import PteroNet

struct ServerCard: View {
    @Environment(ServerListVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var isHovered = false
    
    var body: some View {
        NavigationLink {
            PanelView(server.id)
        } label: {
            HStack {
                if isHovered {
                    Text(server.name)
                        .padding(5)
                        .border(.white, width: 2)
                        .buttonBorderShape(.capsule)
                        .frame(height: 30)
                } else {
                    Text(server.name)
                        .frame(height: 30)
                }
                
                Spacer()
            }
            .padding(.leading)
            .foregroundStyle(.primary)
            .title2(design: .rounded)
        }
        .buttonStyle(.borderless)
        .onHover { hover in
            isHovered = hover
        }
    }
}

#Preview {
    ServerCard(
        sampleJSON(.serverListAttributes)
    )
}
