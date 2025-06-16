import SwiftUI
import PteroNet

struct AllocationList: View {
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
            
            Button("Assign allocation") {
                sheetCreate = true
            }
            .disabled(vm.allocations.count >= server.featureLimits.allocations)
        }
        .navigationTitle("Allocations")
        .toolbarTitleDisplayMode(.inline)
        .refreshableTask {
            await vm.fetchAllocations()
        }
        .sheet($sheetCreate) {
            NavigationView {
                SheetCreateAllocation()
            }
        }
        .environment(vm)
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
