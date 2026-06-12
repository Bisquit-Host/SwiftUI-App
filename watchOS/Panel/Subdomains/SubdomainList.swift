import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let subdomainLimit: Int
    
    init(_ subdomainLimit: Int) {
        self.subdomainLimit = subdomainLimit
    }
    
    var body: some View {
        if subdomainLimit == 0 {
            ContentUnavailableView(
                "Subdomains are unavailable",
                systemImage: "globe"
            )
        } else if vm.subdomains.isEmpty {
            ContentUnavailableView(
                "No subdomains found",
                systemImage: "globe"
            )
        } else {
            Section {
                ForEach(vm.subdomains) {
                    SubdomainCard($0)
                }
                .onDelete(perform: delete)
            } header: {
                Text("\(vm.subdomains.count)/\(subdomainLimit)")
            }
        }
    }
    
    private func delete(at offsets: IndexSet) {
        for index in offsets {
            let subdomain = vm.subdomains[index]
            
            Task {
                await vm.deleteSubdomain(subdomain.id)
            }
        }
    }
}

#Preview {
    List {
        SubdomainList(4)
    }
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
}
