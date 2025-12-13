import SwiftUI

struct VDSHistoryItem: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    private let item: CloudServiceHistoryItem
    
    init(_ item: CloudServiceHistoryItem) {
        self.item = item
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(item.type)
                    .subheadline(.semibold)
                
                Text(item.state)
                    .footnote()
                    .secondary()
            }
            
            Spacer()
            
            if let date = item.date {
                Text(date.formatted(date: .numeric, time: .shortened))
                    .footnote()
                    .secondary()
            }
        }
        .padding(.vertical, 6)
    }
}
