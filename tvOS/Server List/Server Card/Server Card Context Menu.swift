import ScrechKit

struct ServerCardContextMenu: View {
    private let id: String
    
    init(_ id: String) {
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
            
            MenuButton("Stop", icon: "pause") {
                PteroNet.powerSignal(id, signal: .stop)
            }
            
            Divider()
            
            MenuButton("Kill", role: .destructive, icon: "xmark") {
                PteroNet.powerSignal(id, signal: .kill)
            }
        } label: {
            Label("Actions", systemImage: "power")
        }
    }
}

#Preview {
    ServerCardContextMenu("")
}
