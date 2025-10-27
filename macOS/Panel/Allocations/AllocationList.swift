import SwiftUI

struct AllocationList: View {
    @Environment(AllocationVM.self) private var vm
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
    var body: some View {
        ScrollView {
            LazyVStack(alignment: .leading) {
                ForEach(vm.allocations) {
                    AllocationCard($0)
                }
            }
        }
        .navigationTitle("Allocations")
        .scrollIndicators(.never)
        .animation(.default, value: vm.allocations.indices)
        .padding()
        .background(.clear)
        .clipShape(.rect(cornerRadius: 16))
        .task {
            await vm.fetchAllocations()
        }
    }
}

#Preview {
    NavigationStack {
        UserList("")
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
