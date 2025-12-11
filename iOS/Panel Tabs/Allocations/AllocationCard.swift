import SwiftUI
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
        (allocation.notes != nil && notes != allocation.notes) ||
        (allocation.notes == nil && !notes.isEmpty)
    }
    
    private var ip: String {
        (allocation.ipAlias ?? allocation.ip) +
        ":" + String(allocation.port)
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
                    
                    if allocation.isDefault {
                        Image(systemName: "star.fill")
                            .foregroundStyle(.yellow.gradient)
                    }
                }
                .animation(.default, value: allocation.isDefault)
                .contextMenu {
                    if !allocation.isDefault {
                        Button("Set default", systemImage: "star") {
                            setDefault()
                        }
                    }
                    
                    Divider()
                    
                    Button("Delete", systemImage: "trash", role: .destructive) {
                        delete()
                    }
                }
                
                TextField("Notes", text: $notes)
                    .limitInputLength($notes, length: 256)
                
                if showSaveButton {
                    Button("Save", action: save)
                }
            }
        }
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
    
    private func save() {
        Task {
            await vm.updateNotes(allocation.id, notes: notes)
        }
    }
}

#Preview {
    List {
        AllocationCard(PreviewProp.allocationAttributes)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
    .environmentObject(ValueStore())
}
