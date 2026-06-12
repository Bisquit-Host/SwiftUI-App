import SwiftUI
import PteroNet

struct AllocationTab: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocationLimit: Int
    
    init(_ server: ServerAttributes) {
        allocationLimit = server.featureLimits.allocations
    }
    
    var body: some View {
        List {
            AllocationList(allocationLimit)
        }
        .navigationTitle("Ports")
        .refreshable {
            await vm.fetchAllocations()
        }
    }
}

#Preview {
    NavigationStack {
        AllocationTab(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
