import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.subdomains) { subdomain in
                SubdomainCard(subdomain)
            }
            
            Section {
                Button {
                    sheetCreate = true
                } label: {
                    Label("Create Subdomain", systemImage: "plus")
                }
            }
        }
        .refreshableTask {
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            SheetCreateSubdomain()
        }
    }
}

#Preview {
    SubdomainList()
        .environment(SubdomainVM(""))
}
