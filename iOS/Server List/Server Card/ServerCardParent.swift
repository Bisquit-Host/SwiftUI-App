import ScrechKit
import PteroNet

struct ServerCardParent: View {
    @Environment(NavState.self) private var navState
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
#if !os(macOS)
                navState.navigate(.toPanel(server.id))
#endif
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
#if !os(macOS)
        .hoverEffect()
        .safariCover($showSafari, url: serverUrl)
        .confirmationDialog("Perform kill action", isPresented: $confirmKill, titleVisibility: .visible) {
            Button("Kill", role: .destructive) {
                Task {
                    await PteroNet.powerSignal(server.id, do: .kill)
                }
            }
        }
#endif
        .contextMenu {
            ServerCardContextMenu(server, $showSafari, $confirmKill)
        }
        .onDrag {
            let url = URL(string: serverUrl)
            
            if let itemProvider = NSItemProvider(contentsOf: url) {
                return itemProvider
            }
            
            return NSItemProvider()
        }
    }
}

#Preview {
    ServerCardParent(sampleJSON(.serverListAttributes))
        .environment(NavState())
        .environmentObject(ValueStore())
}
