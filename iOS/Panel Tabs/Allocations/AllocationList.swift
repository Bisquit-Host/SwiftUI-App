import ScrechKit
import Calagopus

struct AllocationList: View {
    private var vm: AllocationVM
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
        vm = AllocationVM(server.id)
    }
    
    var body: some View {
        List {
            ForEach(vm.allocations) {
                AllocationCard($0)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Ports")
        .refreshableTask {
            async let allocations = vm.fetchAllocations()
            async let categories = vm.fetchCategories()
            
            _ = await (allocations, categories)
        }
        .environment(vm)
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .toolbar {
            Menu("Create Allocation", systemImage: "link.badge.plus") {
                ForEach(vm.categories) { allocation in
                    Button(allocation.name) {
                        assignAllocation(allocation.id)
                    }
                }
            }
            .disabled(vm.allocations.count >= server.featureLimits.allocations)
        }
    }
    
    private func assignAllocation(_ id: Int) {
        Task {
            await vm.assignAllocation(id)
        }
    }
    
    private func delete(offsets: IndexSet) {
        for index in offsets {
            let id = vm.allocations[index].id
            
            Task {
                await vm.unassignAllocation(id)
            }
        }
    }
}

#Preview {
    NavigationStack {
        AllocationList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
