import SwiftUI
import Calagopus

struct AllocationDetails: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
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
                if !allocation.isDefault {
                    Button("Set default", systemImage: "star", action: setDefault)
                }
                
                Button("Delete", systemImage: "trash", role: .destructive, action: delete)
            }
        }
        .navigationTitle("Port")
    }
    
    private func setDefault() {
        Task {
            await vm.setDefault(allocation.id)
        }
    }
    
    private func delete() {
        Task {
            await vm.unassignAllocation(allocation.id)
        }
    }
}

#Preview {
    NavigationStack {
        AllocationDetails(PreviewProp.allocationAttributes)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
