import ScrechKit
import PteroNet

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
        self.allocation = allocation
        notes = allocation.notes ?? ""
    }
    
    @State private var notes: String
    
    private var showSaveButton: Bool {
        (allocation.notes != nil && notes != allocation.notes) || (allocation.notes == nil && !notes.isEmpty)
    }
    
    private var ip: String {
        allocation.ipAlias ?? allocation.ip
    }
    
    var body: some View {
        Section {
            ListParameter("IP", parameter: ip)
            
            ListParameter("Port", parameter: "\(allocation.port)")
            
            TextEditor(text: $notes)
            
            if showSaveButton {
                Button("Save") {
                    vm.updateNotes(allocation.id, notes: notes)
                }
            }
            
            if !allocation.isDefault {
                MenuButton("Set default", icon: "star") {
                    vm.setDefault(allocation.id)
                }
            }
            
            MenuButton("Delete", role: .destructive, icon: "trash") {
                vm.unassignAllocation(allocation.id)
            }
        } header: {
            if allocation.isDefault {
                Text("Default")
            }
        }
    }
}

//#Preview {
//    AllocationCard()
//        .environment(AllocationVM(""))
//}
