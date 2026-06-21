import ScrechKit
import Calagopus

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let subdomain: SubdomainAttributes
    private let fullDomain: String
    
    init(_ subdomain: SubdomainAttributes) {
        self.subdomain = subdomain
        fullDomain = subdomain.subdomain + "." + subdomain.domain
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fullDomain)
                .lineLimit(2)
            
            TimelineView(.everyMinute) { _ in
                Text(timeSinceISO(subdomain.createdAt))
                    .footnote()
                    .secondary()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .swipeActions {
            Button("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                Task {
                    await vm.syncSubdomain(subdomain.id)
                }
            }
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    await vm.deleteSubdomain(subdomain.id)
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
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
}
