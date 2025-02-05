import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.subdomains) { subdomain in
                SubdomainCard(subdomain)
            }
        }
        .refreshableTask {
            await vm.fetchSubdomains()
        }
    }
}

#Preview {
    SubdomainList()
        .environment(SubdomainVM(""))
}
