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
                ForEach(vm.allocations, id: \.id) { allocation in
                    AllocationCard(allocation)
                }
            }
        }
        .navigationTitle("Allocations")
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            vm.fetchAllocations()
        }
        .onChange(of: id) { _, _ in
            vm.fetchAllocations()
        }
    }
}

#Preview {
    UserList("")
        .environment(UsersVM(""))
}
