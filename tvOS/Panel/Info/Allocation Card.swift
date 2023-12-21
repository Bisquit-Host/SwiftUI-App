import SwiftUI
import PteroNet

struct AllocationCard: View {
    private let allocation: AllocationAttributes
    
    init(_ allocation: AllocationAttributes) {
        self.allocation = allocation
    }
    
    var body: some View {
        Text(allocation.ip + ":\(allocation.port)")
        
        if let ipAlias = allocation.ipAlias {
            Text(ipAlias)
        }
        
        if let notes = allocation.notes {
            Text(notes)
        }
    }
}

//#Preview {
//    List {
//        AllocationCard()
//    }
//}
