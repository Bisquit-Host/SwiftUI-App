import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.subdomains) { subdomain in
                SubdomainCard(subdomain)
            }
#warning("Finish")
            Section {
                Button {
                    
                } label: {
                    Label("Create subdomain", systemImage: "plus")
                }
                .disabled(true)
                .secondary()
            } footer: {
                Text("Will be available soon")
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
