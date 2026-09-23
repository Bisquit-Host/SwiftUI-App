import ScrechKit
import Calagopus

struct AllocationDetails: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: CalagopusServerAllocation
    
    init(_ allocation: CalagopusServerAllocation) {
        self.allocation = allocation
    }
    
    private var address: String {
        (allocation.ipAlias ?? allocation.ip) + ":" + String(allocation.port)
    }
    
    var body: some View {
        List {
            Section {
                Text(address)
                
                if let notes = allocation.notes {
                    Text(notes)
                }
            }
            
            Section {
                if !allocation.isPrimary {
                    AsyncButton("Set default", systemImage: "star") {
                        await vm.setDefault(allocation.id)
                    }
                }
                
                AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                    await vm.unassignAllocation(allocation.id)
                }
            }
        }
        .navigationTitle("Port")
    }
}

#Preview {
    NavigationStack {
        AllocationDetails(PreviewProp.serverAllocation)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
