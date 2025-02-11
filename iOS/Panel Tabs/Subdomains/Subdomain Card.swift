import SwiftUI

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    
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
        .contextMenu {
#if !os(tvOS)
            Button {
                UIPasteboard.general.string = fullDomain
            } label: {
                Label("Copy", systemImage: "document.on.document")
            }
            
            ShareLink(item: fullDomain)
#endif
            Section {
                Button(role: .destructive) {
                    Task {
                        await vm.deleteSubdomain(subdomain.id)
                    }
                } label: {
                    Label("Delete", systemImage: "trash")
                }
            }
        }
    }
}

#Preview {
    SubdomainCard(.init(
        id: 0,
        domain: "goida.host",
        subdomain: "super",
        createdAt: ""
    ))
    .environment(SubdomainVM(""))
}
