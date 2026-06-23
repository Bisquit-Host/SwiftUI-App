import ScrechKit
import Calagopus

struct ServerCardContextMenu: View {
    @Environment(\.openURL) private var openURL
    
    private let server: CalagopusServer
    @Binding private var showSafari: Bool
    @Binding private var confirmKill: Bool
    
    init(_ server: CalagopusServer, _ showSafari: Binding<Bool>, _ confirmKill: Binding<Bool>) {
        self.server = server
        _showSafari = showSafari
        _confirmKill = confirmKill
    }
    
    private var defaultAlloc: CalagopusServerAllocation? {
        server.allocation
    }
    
    var body: some View {
        let id = server.id
        let ip = defaultAlloc?.ipAlias ?? defaultAlloc?.ip
        let port = defaultAlloc?.port.description
        
        if !server.isSuspended {
            ControlGroup {
                Button("Start", systemImage: "play") {
                    Task {
                        await CalagopusNet.powerSignal(id, do: .start)
                    }
                }
                
                Button("Stop", systemImage: "pause") {
                    Task {
                        await CalagopusNet.powerSignal(id, do: .stop)
                    }
                }
                
                Button("Restart", systemImage: "arrow.triangle.2.circlepath") {
                    Task {
                        await CalagopusNet.powerSignal(id, do: .restart)
                    }
                }
            }
            
            Section {
                Button("Kill", systemImage: "power", role: .destructive) {
                    confirmKill = true
                }
            }
            
            if let ip, let port {
                Menu {
                    Button("Copy", systemImage: "doc.on.doc") {
                        Pasteboard.copy(ip + ":" + port)
                    }
                    
                    ShareLink(item: ip + ":" + port)
                    
                    Button("Add to MC Stats", systemImage: "arrowshape.turn.up.right") {
                        addToMCStats()
                    }
                } label: {
                    Label(ip, systemImage: "network")
                    Text(port)
                }
            }
        }
        
        Section {
            Button("Open in browser", systemImage: "safari") {
                showSafari = true
            }
        }
    }
    
    private func addToMCStats() {
        guard
            let ip = defaultAlloc?.ipAlias ?? defaultAlloc?.ip,
            let port = defaultAlloc?.port,
            var components = URLComponents(string: "mc-stats://add-server"),
            let fallbackURL = URL(string: "https://apps.apple.com/app/id6740754881")
        else {
            return
        }

        components.queryItems = [
            .init(name: "address", value: "\(ip):\(port)"),
            .init(name: "name", value: server.name)
        ]

        guard let url = components.url else {
            return
        }
        
        openURL(url) { success in
            if !success {
                openURL(fallbackURL)
            }
        }
    }
}

#Preview {
    Text("Preview")
        .contextMenu {
            ServerCardContextMenu(
                PreviewProp.serverAttributes,
                .constant(false),
                .constant(false)
            )
        }
        .darkSchemePreferred()
}
