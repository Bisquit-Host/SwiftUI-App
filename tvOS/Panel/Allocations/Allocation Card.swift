import ScrechKit
import PteroNet

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
        self.allocation = allocation
    }
    
    private var ip: String {
        allocation.ipAlias ?? allocation.ip
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack(spacing: 16) {
                if allocation.isDefault {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
                }
                
                VStack(alignment: .leading) {
                    Text(ip) +
                    
                    Text(":")
                        .foregroundStyle(.secondary) +
                    
                    Text(allocation.port)
                    
                    if let notes = allocation.notes {
                        Text(notes)
                            .secondary()
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
