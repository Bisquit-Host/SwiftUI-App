import ScrechKit

struct SectionHeader: View {
    private let name: LocalizedStringKey
    private let type: HeaderType
    
    init(_ name: LocalizedStringKey,
         type: HeaderType
    ) {
        self.name = name
        self.type = type
    }
    
    enum HeaderType {
        case backup(_ count: Int, limit: Int)
        case database(_ count: Int, limit: Int)
    }
    
    var body: some View {
        HStack(spacing: 5) {
            Text(name)
                .bold()
            
            Spacer()
            
            switch type {
            case .backup(let count, let limit):
                Text("\(count) of \(limit) used")
                    .foregroundStyle(count >= limit ? .yellow : .gray)
                
            case .database(let count, let limit):
                Text("\(count) of \(limit) used")
                    .foregroundStyle(count >= limit ? .yellow : .gray)
            }
        }
    }
}
