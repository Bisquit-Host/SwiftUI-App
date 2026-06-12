import SwiftUI

struct SubdomainTab: View {
    @Environment(SubdomainVM.self) private var vm
    
    var body: some View {
        List {
            SubdomainList(vm.limit)
        }
        .navigationTitle("Subdomains")
        .refreshableTask {
            await vm.fetchSubdomains()
        }
    }
}

#Preview {
    NavigationStack {
        SubdomainTab()
    }
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
}
