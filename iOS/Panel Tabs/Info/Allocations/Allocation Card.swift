import SwiftUI
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
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                if let ipAlias = allocation.ipAlias {
                    Text(ipAlias + ":\(allocation.port)")
                } else {
                    Text(allocation.ip + ":\(allocation.port)")
                }
                
                TextField("Notes", text: $notes)
            }
            
            if showSaveButton {
                Button("Save") {
                    vm.updateNotes(allocation.id, notes: notes)
                }
            }
        }
    }
}

//#Preview {
//    AllocationCard()
//        .environment(AllocationVM(""))
//}
