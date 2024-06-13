import ScrechKit

struct ServerCardContextMenu: View {
    private let id: String
    @Binding private var showSafari: Bool
    @Binding private var confirmKill: Bool
    
    init(_ id: String, showSafari: Binding<Bool>, confirmKill: Binding<Bool>) {
        self.id = id
        _showSafari = showSafari
        _confirmKill = confirmKill
    }
        
    var body: some View {
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
        
        MenuButton("Open in Safari", icon: "safari") {
            showSafari = true
        }
    }
}

#Preview {
    Menu("Preview") {
        ServerCardContextMenu("", showSafari: .constant(false), confirmKill: .constant(false))
    }
    .semibold()
    .rounded()
    .largeTitle()
}
