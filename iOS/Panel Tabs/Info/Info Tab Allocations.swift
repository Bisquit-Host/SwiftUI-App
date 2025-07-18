import ScrechKit
import PteroNet

struct InfoTabAllocation: View {
    @Environment(\.openURL) private var openUrl
    
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
            Button("Copy", systemImage: "doc.on.doc") {
                UIPasteboard.general.string = ip
                
                SystemAlert.copied()
                trigger.toggle()
            }
            
            Button("Add to MC Stats", systemImage: "arrowshape.turn.up.right") {
                addToMCStats()
            }
            
            ShareLink(item: ip)
            
            Section {
                Button("View all allocations") {
                    sheetAllocations = true
                }
            }
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    Text("IP Address")
                        .footnote()
                        .secondary()
                        .rounded()
                    
                    Text(ip)
                        .monospaced()
                }
                
                Spacer()
                
                let chevron = Image(systemName: "arrow.right")
                
                Text("All allocations \(chevron)")
                    .caption2()
                    .tertiary()
            }
            .padding(.horizontal)
            .frame(maxWidth: .infinity, alignment: .leading)
            .foregroundStyle(.foreground)
            .frame(height: 55)
            .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            .overlay {
                RoundedRectangle(cornerRadius: 16)
                    .stroke(.gray.opacity(0.25), lineWidth: 1)
            }
        }
        .sheet($sheetAllocations) {
            AllocationListParent(server)
        }
    }
    
    private func addToMCStats() {
        guard
            let url = URL(string: "mc-stats://add-server?address=\(ip)&name=\(server.name)"),
            let fallbackURL = URL(string: "https://apps.apple.com/app/id6740754881")
        else {
            return
        }
        
        openUrl(url) { success in
            if !success {
                openUrl(fallbackURL)
            }
        }
    }
    
    private func getDefaultIp(_ server: ServerAttributes) -> String {
        let allocations = server.relationships.allocations.data
        
        let defaultAllocation = allocations.first {
            $0.attributes.isDefault
        }
        
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
