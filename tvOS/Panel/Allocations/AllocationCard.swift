import SwiftUI
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
//    .environment(AllocationVM(""))
//}
