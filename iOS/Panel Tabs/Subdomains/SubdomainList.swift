import ScrechKit
import Calagopus

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let allocations: [AllocationAttributes]
    
    init(_ allocations: [AllocationAttributes]) {
        self.allocations = allocations
    }
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.subdomains) {
                SubdomainCard($0)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Subdomains")
        .task {
            await vm.fetchSubdomains()
        }
        .refreshableTask {
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            SheetCreateSubdomain(allocations)
        }
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
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
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("link.badge.plus") {
                    sheetCreate = true
                }
                .disabled(vm.disabled)
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
