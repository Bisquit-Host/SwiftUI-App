import ScrechKit
import PteroNet

struct ServerCardContextMenu: View {
    @Environment(\.openURL) private var openUrl
    
    private let server: ServerAttributes
    @Binding private var showSafari: Bool
    @Binding private var confirmKill: Bool
    
    init(_ server: ServerAttributes, _ showSafari: Binding<Bool>, _ confirmKill: Binding<Bool>) {
        self.server = server
        _showSafari = showSafari
        _confirmKill = confirmKill
    }
    
    private var defaultAllocation: String? {
        guard let allocation = server.relationships.allocations.data.first(where: {
            $0.attributes.isDefault
        }).map(\.attributes) else {
            return nil
        }
        
        let ip = allocation.ipAlias ?? allocation.ip
        return ip + ":" + String(allocation.port)
    }
    
    var body: some View {
        let id = server.id
        
        if !server.isSuspended {
            ControlGroup {
                MenuButton("Start", icon: "play") {
                    PteroNet.powerSignal(id, signal: .start)
                }
                
                MenuButton("Stop", icon: "pause") {
                    PteroNet.powerSignal(id, signal: .stop)
                }
                
                MenuButton("Restart", icon: "arrow.triangle.2.circlepath") {
                    PteroNet.powerSignal(id, signal: .restart)
                }
                
                MenuButton("Kill", role: .destructive, icon: "power") {
                    confirmKill = true
                }
            }
            
            if let defaultAllocation {
                Menu {
                    Button {
                        UIPasteboard.general.string = defaultAllocation
                    } label: {
                        Label("Copy", systemImage: "doc.on.doc")
                    }
                    
                    Button {
                        guard
                            let url = URL(string: "mc-stats://add-server?address=\(defaultAllocation)&name=\(server.name)"),
                            let fallbackURL = URL(string: "https://apps.apple.com/app/id6740754881")
                        else {
                            return
                        }
                        
                        openUrl(url) { success in
                            if !success {
                                openUrl(fallbackURL)
                            }
                        }
                    } label: {
                        Label("Add to MC Stats", systemImage: "arrowshape.turn.up.right")
                    }
                    
                    ShareLink(item: defaultAllocation)
                } label: {
                    Text(defaultAllocation)
                }
            }
        }
        
        Section {
            MenuButton("Open in Safari", icon: "safari") {
                showSafari = true
            }
            
            ShareLink(item: "https://mgr.bisquit.host/server/" + id)
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
