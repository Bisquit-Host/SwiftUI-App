import ScrechKit

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    
    @Environment(\.openURL) private var openUrl
    
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
            
            Text(timeSinceISO(subdomain.createdAt))
                .footnote()
                .secondary()
                .minimumScaleFactor(0.5)
                .lineLimit(1)
        }
        .foregroundStyle(.foreground)
        .contextMenu {
#if !os(tvOS)
            Button {
                Task {
                    await vm.syncSubdomain(subdomain.id)
                }
            } label: {
                Label("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90")
            }
            
            Button {
#if os(macOS)
                NSPasteboard.general.setString(fullDomain, forType: .URL)
#else
                UIPasteboard.general.string = fullDomain
#endif
            } label: {
                Label("Copy", systemImage: "document.on.document")
            }
            
            Button {
                guard
                    let url = URL(string: "mc-stats://add-server?address=\(fullDomain)&name=\(subdomain.subdomain)"),
                    let fallbackUrl = URL(string: "https://apps.apple.com/app/id6740754881")
                else {
                    return
                }
                
                openUrl(url) { success in
                    if !success {
                        openUrl(fallbackUrl)
                    }
                }
            } label: {
                Label("Add to MC Stats", systemImage: "arrowshape.turn.up.right")
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
    List {
        SubdomainCard(.init(
            id: 0,
            domain: "goida.host",
            subdomain: "super",
            createdAt: "Yesterday"
        ))
    }
    .environment(SubdomainVM(""))
#if os(visionOS)
    .padding()
    .glassBackgroundEffect()
#endif
}
