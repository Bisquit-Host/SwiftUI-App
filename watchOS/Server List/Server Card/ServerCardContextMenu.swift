import SwiftUI
import PteroNet

struct ServerCardContextMenu: View {
    private let server: ServerAttributes
    private let id: String
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.id = server.id
    }
    
    @State private var confirmKill = false
    
    private var defaultAllocation: String? {
        guard let allocation = server.relationships.allocations.data.map(\.attributes).first(where: {
            $0.isDefault
        }) else {
            return nil
        }
        
        let ip = allocation.ipAlias ?? allocation.ip
        
        return ip + ":" + String(allocation.port)
    }
    
    var body: some View {
        List {
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
            
            Button("Kill", systemImage: "power") {
                confirmKill = true
            }
            .foregroundStyle(.red)
            
            if let defaultAllocation {
                ShareLink(item: defaultAllocation) {
                    Label(defaultAllocation, systemImage: "square.and.arrow.up")
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
            }
        }
    }
}

#Preview {
    Text("Preview")
        .sheet {
            ServerCardContextMenu(sampleJSON(.serverListAttributes))
        }
}
