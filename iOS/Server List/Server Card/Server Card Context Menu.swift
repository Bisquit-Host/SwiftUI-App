import ScrechKit
import PteroNet

struct ServerCardContextMenu: View {
    @Environment(\.openURL) private var openUrl
    
    private let server: ServerAttributes
    @Binding private var showSafari: Bool
    @Binding private var confirmKill: Bool
    
    init(
        _ server: ServerAttributes,
        _ showSafari: Binding<Bool>,
        _ confirmKill: Binding<Bool>
    ) {
        self.server = server
        _showSafari = showSafari
        _confirmKill = confirmKill
    }
    
    private var defaultAlloc: AllocationAttributes? {
        guard let allocation = server.relationships.allocations.data.first(where: {
            $0.attributes.isDefault
        }).map(\.attributes) else {
            return nil
        }
        
        return allocation
    }
    
    private var ip: String? {
        defaultAlloc?.ipAlias ?? defaultAlloc?.ip
    }
    
    private var port: String? {
        defaultAlloc?.port.description
    }
    
    var body: some View {
        let id = server.id
        
        if !server.isSuspended {
            ControlGroup {
                Button("Start", systemImage: "play") {
                    Task {
                        await PteroNet.powerSignal(id, do: .start)
                    }
                }
                
                Button("Stop", systemImage: "pause") {
                    Task {
                        await PteroNet.powerSignal(id, do: .stop)
                    }
                }
                
                Button("Restart", systemImage: "arrow.triangle.2.circlepath") {
                    Task {
                        await PteroNet.powerSignal(id, do: .restart)
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
                        addToGoidacraft()
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
    
    private func addToGoidacraft() {
        guard
            let defaultAlloc,
            let url = URL(string: "mc-stats://add-server?address=\(defaultAlloc)&name=\(server.name)"),
            let fallbackURL = URL(string: "https://apps.apple.com/app/id6740754881")
        else {
            return
        }
        
        openUrl(url) { success in
            if !success {
                openUrl(fallbackURL)
            }
        }
    }
}

#Preview {
    Text("Preview")
        .contextMenu {
            ServerCardContextMenu(
                sampleJSON(.serverListAttributes),
                .constant(false),
                .constant(false)
            )
        }
}
