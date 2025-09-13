import SwiftUI

struct HeaderCell: View {
    var text: String
    
    init(_ t: String) {
        text = t
    }
    
    var body: some View {
        Text(text)
            .caption()
            .secondary()
    }
}
