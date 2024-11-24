import SwiftUI
import PteroNet

struct ServerCard: View {
    @Environment(ServerListVM.self) private var vm
    @EnvironmentObject private var settings: ValueStorage
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var isHovered = false
    
    var body: some View {
        Button {
            vm.selectedServer = server
        } label: {
            if isHovered {
                Text(server.name)
                    .padding(8)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .transition(.asymmetric(insertion: .identity, removal: .opacity))
                    .background {
                        Capsule()
                            .stroke(.white, lineWidth: 2)
                    }
            } else {
                Text(server.name)
                    .padding(8)
                    .frame(height: 30)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.horizontal)
        .foregroundStyle(.primary)
        .title2(design: .rounded)
        .buttonStyle(.borderless)
        .onHover { hover in
            withAnimation(.easeOut) {
                isHovered = hover
            }
        }
    }
}

#Preview {
    ServerCard(PreviewProperty.serverAttributes)
        .environmentObject(ValueStorage())
        .environment(ServerListVM())
}
