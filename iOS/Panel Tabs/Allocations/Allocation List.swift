import SwiftUI
import PteroNet

struct AllocationList: View {
    @EnvironmentObject private var store: ValueStore
    
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
                    .listRowBackground(store.transparentList ? .clear : Color.list)
            }
            
            Button("Assign allocation") {
                vm.assignAllocation()
            }
            .disabled(vm.allocations.count >= server.featureLimits.allocations)
            .listRowBackground(store.transparentList ? .clear : Color.list)
        }
        .environment(vm)
        .navigationTitle("Allocations")
        .toolbarTitleDisplayMode(.inline)
        .scrollContentBackground(store.transparentSheet ? .hidden : .visible)
        .presentationBackground(store.transparentSheet ? .ultraThinMaterial : .regular)
        .refreshableTask {
            vm.fetchAllocations()
        }
    }
}

#Preview {
    AllocationList(sampleJSON(.serverListAttributes))
        .environment(AllocationVM(""))
}
