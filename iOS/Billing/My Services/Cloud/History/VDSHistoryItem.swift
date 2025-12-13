import SwiftUI

struct VDSHistoryItem: View {
    private let item: CloudServiceHistoryItem
    
    init(_ item: CloudServiceHistoryItem) {
        self.item = item
    }
    
    var body: some View {
        HStack {
            Capsule()
                .frame(width: 4, height: 32)
//                .foregroundStyle(item.state.color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(item.type)
                    .subheadline(.semibold)
                
                Text(item.state)
                    .footnote()
                    .secondary()
            }
            
            Spacer()
            
            if let date = item.date {
                Text(date.formatted(date: .omitted, time: .shortened))
                    .footnote()
                    .secondary()
            }
        }
        .padding(.vertical, 6)
    }
}
