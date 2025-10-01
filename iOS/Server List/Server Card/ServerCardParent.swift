import ScrechKit
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var nav
    @EnvironmentObject private var store: ValueStore
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var showSafari = false
    @State private var confirmKill = false
    
    private var serverUrl: String {
        "https://mgr.bisquit.host/server/\(server.id)"
    }
    
    var body: some View {
        VStack {
            Button {
                nav.navigate(.toPanel(server.id))
            } label: {
                if store.compactServerList {
                    CompactServerCard(server)
                } else {
                    ServerCard(server)
                }
            }
            .foregroundStyle(.foreground)
        }
        .buttonStyle(.plain)
        .hoverEffect()
        .safariCover($showSafari, url: serverUrl)
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await PteroNet.powerSignal(server.id, do: .kill)
                }
            }
        }
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .onDrag {
            if let url = URL(string: serverUrl), let itemProvider = NSItemProvider(contentsOf: url) {
                itemProvider
            } else {
                NSItemProvider()
            }
        }
    }
}

#Preview {
    ServerCardParent(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(NavState())
        .environmentObject(ValueStore())
}
