import SwiftUI

struct AllocationList: View {
    @State private var vm: AllocationVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        self.vm = AllocationVM(id)
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.allocations) { allocation in
                    AllocationCard(allocation)
                }
            }
        }
        .animation(.default, value: vm.allocations.indices)
        .navigationTitle("Allocations")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            await vm.fetchAllocations()
        }
        .onChange(of: id) {
            Task {
                await vm.fetchAllocations()
            }
        }
    }
}

#Preview {
    NavigationStack {
        UserList("")
    }
    .environment(AllocationVM(""))
}
