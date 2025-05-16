import ScrechKit

struct ServerCardContextMenu: View {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        MenuButton("Start", icon: "play") {
            PteroNet.powerSignal(id, do: .start)
        }
        
        MenuButton("Restart", icon: "arrow.triangle.2.circlepath") {
            PteroNet.powerSignal(id, do: .restart)
        }
        
        MenuButton("Stop", icon: "pause") {
            PteroNet.powerSignal(id, do: .stop)
        }
        
        Divider()
        
        MenuButton("Kill", role: .destructive, icon: "xmark") {
            PteroNet.powerSignal(id, do: .kill)
        }
    }
}

#Preview {
    ServerCardContextMenu("")
}
