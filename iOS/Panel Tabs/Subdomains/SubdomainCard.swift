import ScrechKit
import Calagopus

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    @Environment(\.openURL) private var openURL
    
    let subdomain: CalagopusSubdomainRecord
    let fullDomain: String
    
    init(_ subdomain: CalagopusSubdomainRecord) {
        self.subdomain = subdomain
        fullDomain = subdomain.subdomain + "." + subdomain.domain.domain
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fullDomain)
            
            TimelineView(.everyMinute) { _ in
                Text(subdomain.created, style: .relative)
                    .footnote()
                    .secondary()
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }
        }
        .foregroundStyle(.foreground)
        .swipeActions {
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.deleteSubdomain(subdomain)
            }
            .labelStyle(.iconOnly)
        }
        .contextMenu {
            AsyncButton("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                await vm.syncSubdomain(subdomain)
            }
            
            Button("Copy", systemImage: "document.on.document") {
                Pasteboard.copy(fullDomain)
            }
            
            Button("Add to MC Stats", systemImage: "arrowshape.turn.up.right") {
                addToMCStats()
            }
            
            ShareLink(item: fullDomain)
            
            Section {
                AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                    await vm.deleteSubdomain(subdomain)
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
            uuid: UUID().uuidString,
            domain: .init(id: UUID().uuidString, domain: "goida.host"),
            allocation: nil,
            subdomain: "super",
            created: Date()
        ))
    }
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
#if os(visionOS)
    .padding()
    .glassBackgroundEffect()
#endif
}
