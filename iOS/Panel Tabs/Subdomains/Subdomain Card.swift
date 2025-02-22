import ScrechKit

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
            
            let timeDifference = Text(timeSinceISO(subdomain.createdAt))
                .foregroundStyle(.primary)
            
            Text("Created: \(timeDifference)")
                .footnote()
                .secondary()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .navigationTitle("Subdomains")
        .foregroundStyle(.foreground)
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
