import SwiftUI

struct AllocationList: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocationLimit: Int
    
    init(_ allocationLimit: Int) {
        self.allocationLimit = allocationLimit
    }
    
    var body: some View {
        if allocationLimit == 0 {
            ContentUnavailableView(
                "Ports are unavailable",
                systemImage: "link.badge.plus"
            )
        } else if vm.allocations.isEmpty {
            ContentUnavailableView(
                "No ports found",
                systemImage: "link"
            )
        } else {
            Section {
                ForEach(vm.allocations) {
                    AllocationCard($0)
                }
            } header: {
                Text("\(vm.allocations.count)/\(allocationLimit)")
            }
        }
    }
}

#Preview {
    List {
        AllocationList(4)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
