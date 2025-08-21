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
                    HStack(spacing: 0) {
                        Text(ip)
                        
                        Text(":")
                            .secondary()
                        
                        Text(allocation.port)
                    }
                    
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
                    setDefault()
                }
            }
            
            MenuButton("Delete", role: .destructive, icon: "trash") {
                delete()
            }
        }
    }
    
    private func delete() {
        Task {
            await vm.unassignAllocation(allocation.id)
        }
    }
    
    private func setDefault() {
        Task {
            await vm.setDefault(allocation.id)
        }
    }
}

//#Preview {
//    List {
//        AllocationCard()
//    }
//    .environment(AllocationVM(""))
//    .darkSchemePreferred()
//}
