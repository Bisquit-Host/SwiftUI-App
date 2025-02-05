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
    
    var body: some View {
        HStack {
            InfoStat(
                "IP Address",
                value: ip,
                alignment: .leading
            )
            
            Spacer()
            
            HStack(spacing: 16) {
                SFButton("doc.on.doc") {
                    UIPasteboard.general.string = ip
                    
                    SystemAlert.copied()
                    trigger.toggle()
                }
                .changeEffect(
                    .spray(origin: .bottom) {
                        Image(systemName: "doc.on.doc")
                            .foregroundStyle(.white)
                            .footnote()
                    },
                    value: trigger
                )
                
                ShareLink(item: ip) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            .title3(.medium)
            .foregroundStyle(.primary)
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
