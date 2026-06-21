import SwiftUI
import Calagopus

struct ServerCardContextMenu: View {
    @Environment(\.dismiss) private var dismiss
    
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
                    await CalagopusNet.powerSignal(id, do: .start)
                }
                
                dismiss()
            }
            
            Button("Stop", systemImage: "pause") {
                Task {
                    await CalagopusNet.powerSignal(id, do: .stop)
                }
                
                dismiss()
            }
            
            Button("Restart", systemImage: "arrow.triangle.2.circlepath") {
                Task {
                    await CalagopusNet.powerSignal(id, do: .restart)
                }
                
                dismiss()
            }
            
            Button("Kill", systemImage: "power") {
                confirmKill = true
                dismiss()
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
            ServerCardContextMenu(PreviewProp.serverAttributes)
        }
        .darkSchemePreferred()
}
