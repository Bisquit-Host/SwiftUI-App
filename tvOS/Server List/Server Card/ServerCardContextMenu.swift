import SwiftUI

struct ServerCardContextMenu: View {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        Button("Start", systemImage: "play") {
            Task {
                await PteroNet.powerSignal(id, do: .start)
            }
        }
        
        Button("Restart", systemImage: "arrow.triangle.2.circlepath") {
            Task {
                await PteroNet.powerSignal(id, do: .restart)
            }
        }
        
        Button("Stop", systemImage: "pause") {
            Task {
                await PteroNet.powerSignal(id, do: .stop)
            }
        }
        
        Divider()
        
        Button("Kill", systemImage: "xmark", role: .destructive) {
            Task {
                await PteroNet.powerSignal(id, do: .kill)
            }
        }
    }
}

#Preview {
    ServerCardContextMenu("")
        .darkSchemePreferred()
}
