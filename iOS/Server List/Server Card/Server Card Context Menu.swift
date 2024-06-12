import ScrechKit

struct ServerCardContextMenu: View {
    @Binding private var showSafari: Bool
    private let id: String
    
    init(_ showSafari: Binding<Bool>,
         id: String
    ) {
        _showSafari = showSafari
        self.id = id
    }
    
    var body: some View {
        Menu {
            MenuButton("Start", icon: "play") {
                PteroNet.powerSignal(id, signal: .start)
            }
            
            MenuButton("Restart", icon: "arrow.triangle.2.circlepath") {
                PteroNet.powerSignal(id, signal: .restart)
            }
            
            MenuButton("Stop", icon: "stop") {
                PteroNet.powerSignal(id, signal: .stop)
            }
            
            Divider()
            
            MenuButton("Kill", role: .destructive, icon: "xmark") {
                PteroNet.powerSignal(id, signal: .kill)
            }
        } label: {
            Label("Actions", systemImage: "power")
        }
        
        Divider()
        
        MenuButton("Open in Safari", icon: "hammer") {
            showSafari = true
        }
    }
}

#Preview {
    Text("Preview")
        .largeTitle()
        .contextMenu {
            ServerCardContextMenu(.constant(false), id: "")
        }
}
