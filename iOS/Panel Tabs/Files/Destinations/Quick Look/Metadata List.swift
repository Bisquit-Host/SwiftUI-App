import SwiftUI

struct MetadataList: View {
    private let metadata: [URLResourceKey: Any]?
    
    init(_ metadata: [URLResourceKey : Any]?) {
        self.metadata = metadata
    }
    
    var body: some View {
        if let metadata {
            let sorted = metadata.sorted {
                $0.key.rawValue < $1.key.rawValue
            }
            
            List(sorted, id: \.key) { key, value in
                HStack {
                    Text(key.rawValue)
                        .headline()
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("\(value)")
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .secondary()
                }
            }
        } else {
#warning("ContentUnavailableView")
            Text("No metadata available")
                .secondary()
        }
    }
}
