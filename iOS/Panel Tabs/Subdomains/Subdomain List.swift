import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    @State private var sheetCreate = false
    
    private var disabled: Bool {
        vm.subdomains.count >= vm.limit ?? 3
    }
    
    var body: some View {
        List {
            ForEach(vm.subdomains) { subdomain in
                SubdomainCard(subdomain)
            }
            .onDelete(perform: delete)
            
            Section {
                Button {
                    sheetCreate = true
                } label: {
                    Label("Create Subdomain", systemImage: "plus")
                }
                .disabled(disabled)
                .foregroundStyle(disabled ? .secondary : .primary)
            }
        }
        .refreshableTask {
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            SheetCreateSubdomain()
        }
        .background {
            Image(.darkBackgroundInfo)
                .resizable()
                .blur(radius: 55, opaque: true)
        }
#if !os(tvOS)
        .scrollContentBackground(.hidden)
#endif
        .toolbarBackground(.visible, for: .tabBar)
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
    SubdomainList()
        .environment(SubdomainVM(""))
}
