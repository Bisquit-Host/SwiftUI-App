import SwiftUI
import PteroNet

struct AllocationList: View {
    private var vm: AllocationVM
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        self.vm = AllocationVM(server.id)
    }
    
    var body: some View {
        List {
            ForEach(vm.allocations) { allocation in
                AllocationCard(allocation)
                    .transparentSection()
            }
            
            Button("Assign allocation") {
                vm.assignAllocation()
            }
            .disabled(vm.allocations.count >= server.featureLimits.allocations)
            .transparentSection()
        }
        .environment(vm)
        .navigationTitle("Allocations")
        .toolbarTitleDisplayMode(.inline)
        .transparentList()
        .refreshableTask {
            vm.fetchAllocations()
        }
    }
}

#Preview {
    AllocationList(sampleJSON(.serverListAttributes))
        .environment(AllocationVM(""))
}
