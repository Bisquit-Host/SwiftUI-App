import SwiftUI
import PteroNet

struct AllocationCard: View {
    @Environment(AllocationVM.self) private var vm
    
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
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
                    Image(systemName: allocation.isDefault ? "star.fill" : "link")
                        .foregroundStyle(allocation.isDefault ? .yellow : .secondary)
                    
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
        AllocationCard(PreviewProp.allocationAttributes)
    }
    .darkSchemePreferred()
    .environment(AllocationVM(""))
}
