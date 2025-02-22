import SwiftUI
import PteroNet

struct AllocationList: View {
    @Environment(AllocationVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        List {
            ForEach(vm.allocations) { allocation in
                AllocationCard(allocation)
            }
            
            Section {
                Button {
                    vm.assignAllocation()
                } label: {
                    Label("Assign allocation", systemImage: "plus")
                }
                .disabled(vm.allocations.count >= server.featureLimits.allocations)
            }
        }
        .navigationTitle("Allocations")
        .animation(.default, value: vm.allocations.count)
        .task {
            vm.fetchAllocations()
        }
    }
}

#Preview {
    AllocationList(sampleJSON(.serverListAttributes))
}
