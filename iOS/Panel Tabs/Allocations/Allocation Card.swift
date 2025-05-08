import ScrechKit
import PteroNet

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
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
            HStack {
                Image(systemName: "app.connected.to.app.below.fill")
                
                VStack(alignment: .leading) {
                    Text(ip + ":" + allocation.port.description)
                        .semibold()
                    
                    if store.devMode {
                        Text(allocation.id)
                            .secondary()
                            .footnote()
                    }
                }
                
                Spacer()
                
                if allocation.isDefault {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
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
            
            TextField("Notes", text: $notes)
            
            if showSaveButton {
                Button("Save") {
                    vm.updateNotes(allocation.id, notes: notes)
                }
            }
        }
    }
}

#Preview {
    List {
        AllocationCard(sampleJSON(.allocationAttributes))
    }
    .environment(AllocationVM(""))
    .environmentObject(ValueStore())
}
