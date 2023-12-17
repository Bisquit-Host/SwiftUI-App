import ScrechKit

struct ServerListToolbar: View {
    private let updateServers: () -> Void
    
    init(_ updateServers: @escaping () -> Void) {
        self.updateServers = updateServers
    }
    
    var body: some View {
        SFButton("arrow.triangle.2.circlepath") {
            updateServers()
        }
        .bold()
    }
}

#Preview {
    ServerListToolbar {}
        .padding()
        .glassBackgroundEffect()
}
