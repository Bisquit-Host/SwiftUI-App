import ScrechKit
import Calagopus

struct SubdomainCard: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let subdomain: CalagopusSubdomainRecord
    private let fullDomain: String
    
    init(_ subdomain: CalagopusSubdomainRecord) {
        self.subdomain = subdomain
        fullDomain = subdomain.subdomain + "." + subdomain.domain.domain
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(fullDomain)
                .lineLimit(2)
            
            TimelineView(.everyMinute) { _ in
                Text(subdomain.created, style: .relative)
                    .footnote()
                    .secondary()
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
            }
        }
        .swipeActions {
            AsyncButton("Sync", systemImage: "arrow.trianglehead.2.clockwise.rotate.90") {
                await vm.syncSubdomain(subdomain.id)
            }
            
            AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                await vm.deleteSubdomain(subdomain.id)
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
}
