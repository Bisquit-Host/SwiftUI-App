import SwiftUI
import Calagopus

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: CalagopusServerAllocation
    
    init(_ allocation: CalagopusServerAllocation) {
        self.allocation = allocation
    }
    
    var body: some View {
        let ip = allocation.ipAlias ?? allocation.ip
        
        Button {
            
        } label: {
            HStack(spacing: 16) {
                if allocation.isPrimary {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
                }
                
                VStack(alignment: .leading) {
                    HStack(spacing: 0) {
                        Text(ip)
                        
                        Text(":")
                            .secondary()
                        
                        Text(allocation.port, format: .number)
                    }
                    
                    if let notes = allocation.notes {
                        Text(notes)
                            .secondary()
                    }
                }
            }
        }
        .animation(.default, value: allocation.isPrimary)
        .contextMenu {
            if !allocation.isPrimary {
                Button("Set default", systemImage: "star") {
                    Task {
                        await vm.setDefault(allocation.id)
                    }
                }
            }
            
            Button("Delete", systemImage: "trash", role: .destructive) {
                Task {
                    await vm.unassignAllocation(allocation.id)
                }
            }
        }
    }
}

//#Preview {
//    List {
//        AllocationCard()
//    }
//    .darkSchemePreferred()
//    .environment(AllocationVM(""))
//}
