import SwiftUI
import Calagopus

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
        self.allocation = allocation
    }
    
    var body: some View {
        let ip = allocation.ipAlias ?? allocation.ip
        
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
