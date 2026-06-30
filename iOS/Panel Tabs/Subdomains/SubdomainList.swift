import ScrechKit
import Calagopus

struct SubdomainList: View {
    @Environment(SubdomainVM.self) private var vm
    
    private let allocations: [CalagopusServerAllocation]
    private let subdomainLimit: Int?
    
    init(_ allocations: [CalagopusServerAllocation], limit: Int? = nil) {
        self.allocations = allocations
        subdomainLimit = limit
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
        .refreshableTask {
            vm.updateLimit(subdomainLimit)
            await vm.fetchSubdomains()
        }
        .sheet($sheetCreate) {
            NavigationStack {
                SheetCreateSubdomain(allocations)
            }
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
                await vm.deleteSubdomain(subdomain)
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
