import SwiftUI
import PteroNet

struct AllocationCard: View {
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
        self.allocation = allocation
    }
    
    var body: some View {
        Button {
            
        } label: {
            VStack(alignment: .leading) {
                if let ipAlias = allocation.ipAlias {
                    Text(ipAlias + ":\(allocation.port)")
                } else {
                    Text(allocation.ip + ":\(allocation.port)")
                }
                
                if let notes = allocation.notes {
                    Text(notes)
                }
            }
        }
    }
}

//#Preview {
//    List {
//        AllocationCard()
//    }
//}
