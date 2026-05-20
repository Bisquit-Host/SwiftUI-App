import SwiftUI

struct StatRowAllocations: View {
    @State private var vm: AllocationVM
    
    private let id: String
    
    init(_ id: String) {
        self.id = id
        vm = AllocationVM(id)
    }
    
    @State private var sheetAllocations = false
    
    var body: some View {
        Button {
            sheetAllocations = true
        } label: {
            StatTile("Ports", value: vm.allocations.count, icon: "text.magnifyingglass")
        }
        .task {
            await vm.fetchAllocations()
        }
        .sheet($sheetAllocations) {
            AllocationList(id)
                .environment(vm)
                .frame(minHeight: StatRows.minHeight)
        }
    }
}

#Preview {
    StatRowAllocations("")
        .darkSchemePreferred()
}
