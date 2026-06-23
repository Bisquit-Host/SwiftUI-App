import SwiftUI
import Calagopus

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: CalagopusServerAllocation
    
    init(_ allocation: CalagopusServerAllocation) {
        self.allocation = allocation
    }
    
    var body: some View {
        Button {
            
        } label: {
            HStack {
                VStack(alignment: .leading) {
                    if let ipAlias = allocation.ipAlias {
                        Text(ipAlias + ":\(allocation.port)")
                    } else {
                        Text(allocation.ip + ":\(allocation.port)")
                    }
                    
                    if let notes = allocation.notes {
                        Text(notes)
                            .secondary()
                    }
                }
                
                Spacer()
                
                if allocation.isPrimary {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow.gradient)
                }
            }
        }
        .buttonStyle(.plain)
        .animation(.default, value: allocation.isPrimary)
        .padding()
        .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
        .overlay {
            RoundedRectangle(cornerRadius: 16)
                .stroke(.gray.opacity(0.25), lineWidth: 1)
        }
        .frame(minWidth: 200, maxWidth: 800)
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
