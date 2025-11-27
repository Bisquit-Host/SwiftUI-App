import ScrechKit
import PteroNet

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    @Environment(\.openURL) private var openURL
    
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
            
            TimelineView(.everyMinute) { _ in
                Text(timeSinceISO(subdomain.createdAt))
                    .footnote()
                    .secondary()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.foreground)
        .contextMenu {
#if !os(tvOS)
            Button("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                Task {
                    await vm.syncSubdomain(subdomain.id)
                }
            }
            
            Button("Copy", systemImage: "document.on.document") {
                Pasteboard.copy(fullDomain)
            }
            
            Button("Add to MC Stats", systemImage: "arrowshape.turn.up.right") {
                addToMCStats()
            }
            
            ShareLink(item: fullDomain)
#endif
            Section {
                Button("Delete", systemImage: "trash", role: .destructive) {
                    Task {
                        await vm.deleteSubdomain(subdomain.id)
                    }
                }
            }
        }
    }
    
    private func addToMCStats() {
        guard
            let url = URL(string: "mc-stats://add-server?address=\(fullDomain)&name=\(subdomain.subdomain)"),
            let fallbackURL = URL(string: "https://apps.apple.com/app/id6740754881")
        else {
            return
        }
        
        openURL(url) { success in
            if !success {
                openURL(fallbackURL)
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
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
#if os(visionOS)
    .padding()
    .glassBackgroundEffect()
#endif
}
