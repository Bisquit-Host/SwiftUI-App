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
                    .transparentSection()
            }
            
            Button("Assign allocation") {
                sheetCreate = true
            }
            .disabled(vm.allocations.count >= server.featureLimits.allocations)
            .transparentSection()
        }
        .navigationTitle("Allocations")
        .toolbarTitleDisplayMode(.inline)
        .transparentList()
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
}

#Preview {
    AllocationList(sampleJSON(.serverListAttributes))
        .environment(AllocationVM(""))
}
