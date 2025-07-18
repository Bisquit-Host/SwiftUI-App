import ScrechKit
import PteroNet

struct AllocationList: View {
    @Environment(\.dismiss) private var dismiss
    
    private var vm: AllocationVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        vm = AllocationVM(server.id)
    }
    
    @State private var sheetCreate = false
    
    var body: some View {
        List {
            ForEach(vm.allocations) { allocation in
                AllocationCard(allocation)
            }
            .onDelete(perform: delete)
        }
        .navigationTitle("Allocations")
        .refreshableTask {
            await vm.fetchAllocations()
        }
        .sheet($sheetCreate) {
            NavigationView {
                SheetCreateAllocation()
            }
        }
        .environment(vm)
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
    AllocationList(sampleJSON(.serverListAttributes))
        .environment(AllocationVM(""))
}
