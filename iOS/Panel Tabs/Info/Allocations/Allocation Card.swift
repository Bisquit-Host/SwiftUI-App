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
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                Text(allocation.ip + ":\(allocation.port)")
                
                if let ipAlias = allocation.ipAlias {
                    Text(ipAlias)
                }
                
                TextField("Notes", text: $notes)
            }
            
            if notes != allocation.notes {
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
