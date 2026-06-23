import SwiftUI
import Calagopus

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: CalagopusServerAllocation
    
    init(_ allocation: CalagopusServerAllocation) {
        self.allocation = allocation
    }
    
    private var address: String {
        (allocation.ipAlias ?? allocation.ip) + ":" + String(allocation.port)
    }
    
    var body: some View {
        NavigationLink {
            AllocationDetails(allocation)
                .environment(vm)
        } label: {
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: allocation.isPrimary ? "star.fill" : "link")
                        .foregroundStyle(allocation.isPrimary ? .yellow : .secondary)
                    
                    Text(address)
                        .lineLimit(1)
                        .minimumScaleFactor(0.75)
                }
                
                if let notes = allocation.notes {
                    Text(notes)
                        .lineLimit(2)
                        .footnote()
                        .secondary()
                }
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
}
