import SwiftUI

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
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
        }
        .navigationTitle("Subdomains")
        .scrollContentBackground(.hidden)
        .refreshableTask {
            await vm.fetchSubdomains()
        }
        //        .sheet($sheetCreate) {
        //            SheetCreateSubdomain()
        //        }
        .overlay {
            if vm.subdomains.isEmpty {
                ContentUnavailableView(
                    "No subdomains have been created yet",
                    systemImage: "link.badge.plus",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
        }
        //        .toolbar {
        //            ToolbarItem(placement: .topBarTrailing) {
        //                Button {
        //                    sheetCreate = true
        //                } label: {
        //                    Image(systemName: "link.badge.plus")
        //                        .foregroundStyle(.foreground)
        //                        .footnote(.bold)
        //                        .frame(width: 35, height: 35)
        //                        .background(.ultraThinMaterial, in: .circle)
        //                }
        //            }
        //        }
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
