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
        ControlGroup {
            MenuButton("Start", icon: "play") {
                PteroNet.powerSignal(id, signal: .start)
            }
            
            MenuButton("Stop", icon: "stop") {
                PteroNet.powerSignal(id, signal: .stop)
            }
            
            MenuButton("Restart", icon: "arrow.triangle.2.circlepath") {
                PteroNet.powerSignal(id, signal: .restart)
            }
            
            MenuButton("Kill", role: .destructive, icon: "xmark") {
                PteroNet.powerSignal(id, signal: .kill)
            }
        }
        
        MenuButton("Open in Safari", icon: "hammer") {
            showSafari = true
        }
    }
}

#Preview {
    Menu("Preview") {
        ServerCardContextMenu(.constant(false), id: "")
    }
    .semibold()
    .rounded()
    .largeTitle()
}
