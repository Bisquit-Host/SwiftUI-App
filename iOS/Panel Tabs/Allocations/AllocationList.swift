import ScrechKit
import Calagopus

struct AllocationList: View {
    private var vm: AllocationVM
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
        vm = AllocationVM(server.id)
    }
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.allocations) {
                AllocationCard($0)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Ports")
        .refreshableTask {
            await vm.fetchAllocations()
        }
        .sheet($sheetCreate) {
            NavigationStack {
                SheetCreateAllocation()
            }
        }
        .environment(vm)
#if os(iOS) || os(macOS) || os(visionOS)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
#endif
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                SFButton("link.badge.plus") {
                    sheetCreate = true
                }
                .disabled(vm.allocations.count >= server.featureLimits.allocations)
            }
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
