import ScrechKit
import PteroNet

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
        self.allocation = allocation
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                if allocation.isDefault {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
                }
                
                VStack(alignment: .leading) {
                    if let ipAlias = allocation.ipAlias {
                        Text(ipAlias + ":\(allocation.port)")
                    } else {
                        Text(allocation.ip + ":\(allocation.port)")
                    }
                    
                    if let notes = allocation.notes {
                        Text(notes)
                    }
                }
            }
        }
        .animation(.default, value: allocation.isDefault)
        .contextMenu {
            if !allocation.isDefault {
                MenuButton("Set default", icon: "star") {
                    vm.setDefault(allocation.id)
                }
            }
            
            MenuButton("Delete", role: .destructive, icon: "trash") {
                vm.unassignAllocation(allocation.id)
            }
        }
    }
}

//#Preview {
//    List {
//        AllocationCard()
//    }
//    .environment(AllocationVM(""))
//}
