import SwiftUI
import PteroNet

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    @Environment(\.dismiss) private var dismiss
    
    private let allocations: [AllocationAttributes]
    
    init(_ allocations: [AllocationAttributes]) {
        self.allocations = allocations
    }
    
    @State private var sheetCreate = false
    
    private var disabled: Bool {
        vm.subdomains.count >= vm.limit
    }
    
    var body: some View {
        List {
            ForEach(vm.subdomains) { subdomain in
                SubdomainCard(subdomain)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Subdomains")
        .refreshableTask {
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            SheetCreateSubdomain(allocations)
        }
        .overlay {
            if vm.subdomains.isEmpty {
                ContentUnavailableView(
                    "No subdomains have been created yet",
                    systemImage: "link.badge.plus",
                    description: Text("Use the button in the top right corner to create one")
                )
            }
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton {
                    dismiss()
                }
            }
#if os(iOS) || os(macOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            ToolbarItem(placement: .bottomBar) {
                Button {
                    sheetCreate = true
                } label: {
                    Image(systemName: "link.badge.plus")
                }
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
    SubdomainList([])
        .environment(SubdomainVM(""))
}
