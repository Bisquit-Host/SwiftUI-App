import ScrechKit
import Calagopus

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    @Environment(\.openURL) private var openURL
    
    let subdomain: SubdomainAttributes
    let fullDomain: String
    
    init(_ subdomain: SubdomainAttributes) {
        self.subdomain = subdomain
        fullDomain = subdomain.subdomain + "." + subdomain.domain
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
                    await vm.syncSubdomain(subdomain)
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
                        await vm.deleteSubdomain(subdomain)
                    }
                }
            }
        }
    }
    
    private func addToMCStats() {
        guard
            var components = URLComponents(string: "mc-stats://add-server"),
            let fallbackURL = URL(string: "https://apps.apple.com/app/id6740754881")
        else {
            return
        }
        
        components.queryItems = [
            .init(name: "address", value: fullDomain),
            .init(name: "name", value: subdomain.subdomain)
        ]
        
        guard let url = components.url else {
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
