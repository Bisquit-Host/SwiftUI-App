import ScrechKit
import Calagopus

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let allocation: CalagopusServerAllocation
    
    init(_ allocation: CalagopusServerAllocation) {
        self.allocation = allocation
        notes = allocation.notes ?? ""
    }
    
    @State private var notes: String
    
    private var showSaveButton: Bool {
        (allocation.notes != nil && notes != allocation.notes) ||
        (allocation.notes == nil && !notes.isEmpty)
    }
    
    private var ip: String {
        (allocation.ipAlias ?? allocation.ip) + ":" + String(allocation.port)
    }
    
    var body: some View {
        Section {
            VStack(alignment: .leading) {
                HStack {
                    VStack(alignment: .leading) {
                        Text(ip)
                            .semibold()
                        
                        if store.devMode {
                            Text(allocation.id)
                                .secondary()
                                .footnote()
                        }
                    }
                    
                    Spacer()
                    
                    if allocation.isPrimary {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow.gradient)
                    }
                }
                .animation(.default, value: allocation.isPrimary)
                .contextMenu {
                    if !allocation.isPrimary {
                        AsyncButton("Set default", systemImage: "star") {
                            await vm.setDefault(allocation.id)
                        }
                    }
                    
                    Divider()
                    
                    AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                        await vm.unassignAllocation(allocation.id)
                    }
                }
                
                TextField("Notes", text: $notes)
                    .limitInputLength($notes, length: 256)
                
                if showSaveButton {
                    AsyncButton("Save") {
                        await vm.updateNotes(allocation.id, notes: notes)
                    }
                }
            }
            .swipeActions {
                AsyncButton("Delete", systemImage: "trash", role: .destructive) {
                    await vm.unassignAllocation(allocation.id)
                }
                .labelStyle(.iconOnly)
            }
        }
    }
}

#Preview {
    List {
        AllocationCard(PreviewProp.serverAllocation)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
    .environmentObject(ValueStore())
}
