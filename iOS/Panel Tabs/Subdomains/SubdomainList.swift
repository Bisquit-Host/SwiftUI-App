import ScrechKit
import PteroNet

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let allocations: [AllocationAttributes]
    
    init(_ allocations: [AllocationAttributes]) {
        self.allocations = allocations
    }
    
    @State private var sheetCreate = false
    
#warning("Needed?")
    private var disabled: Bool {
        vm.subdomains.count >= vm.limit
    }
    
    var body: some View {
        List {
            ForEach(vm.subdomains) {
                SubdomainCard($0)
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
                DismissButton()
            }
#if os(iOS) || os(macOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            ToolbarItem(placement: .bottomBar) {
                SFButton("link.badge.plus") {
                    sheetCreate = true
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
    NavigationStack {
        SubdomainList([])
    }
    .darkSchemePreferred()
    .environment(SubdomainVM(""))
}
