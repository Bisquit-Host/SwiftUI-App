import SwiftUI

struct SubdomainCard: View {
    let subdomain: SubdomainAttributes
    
    init(_ subdomain: SubdomainAttributes) {
        self.subdomain = subdomain
    }
    
    private var fullDomain: String {
        "\(subdomain.subdomain).\(subdomain.domain)"
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fullDomain)
            
            Text(subdomain.createdAt)
                .footnote()
                .secondary()
        }
        .navigationTitle("Subdomains")
#if !os(tvOS)
        .contextMenu {
            Button {
                UIPasteboard.general.string = fullDomain
            } label: {
                Label("Copy", systemImage: "document.on.document")
            }
            
            ShareLink(item: fullDomain)
        }
#endif
    }
}

#Preview {
    SubdomainCard(.init(
        id: 0,
        domain: "goida.host",
        subdomain: "super",
        createdAt: ""
    ))
}
