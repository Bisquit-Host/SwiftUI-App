import SwiftUI

struct AllocationList: View {
    @Environment(AllocationVM.self) private var vm
    
    var body: some View {
        List {
            ForEach(vm.allocations, id: \.id) { allocation in
                AllocationCard(allocation)
            }
        }
        .navigationTitle("Allocations")
    }
}

#Preview {
    AllocationList()
}
