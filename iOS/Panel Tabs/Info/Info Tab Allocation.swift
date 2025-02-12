import ScrechKit
import PteroNet

struct InfoTabAllocation: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    private var ip: String {
        getDefaultIp(server)
    }
    
    @State private var trigger = false
    @State private var sheetAllocations = false
    
    var body: some View {
        Menu {
            Button {
                UIPasteboard.general.string = ip
                
                SystemAlert.copied()
                trigger.toggle()
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
            
            ShareLink(item: ip)
            
            Section {
                Button("View all allocations") {
                    sheetAllocations = true
                }
            }
        } label: {
            Text(ip)
                .monospaced()
                .frame(height: 25)
                .frame(maxWidth: .infinity, alignment: .leading)
                .foregroundStyle(.foreground)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        }
        .sheet($sheetAllocations) {
            AllocationListParent(server)
        }
    }
    
    private func getDefaultIp(_ server: ServerAttributes) -> String {
        let allocations = server.relationships.allocations.data
        
        let defaultAllocation = allocations.first(where: {
            $0.attributes.isDefault
        })
        
        let attributes = defaultAllocation?.attributes
        
        let port = attributes?.port ?? 0
        let ip = attributes?.ip ?? ""
        
        if let alias = attributes?.ipAlias {
            return "\(alias):\(port)"
        } else {
            return "\(ip):\(port)"
        }
    }
}

#Preview {
    InfoTabAllocation(sampleJSON(.serverListAttributes))
}
