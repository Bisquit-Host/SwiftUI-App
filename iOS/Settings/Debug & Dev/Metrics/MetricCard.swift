import SwiftUI

struct MetricCard: View {
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(url.lastPathComponent)
        }
    }
}

//#Preview {
//    List {
//        MetricCard()
//    }
//    .darkSchemePreferred()
//    .environment(MetricListVM())
//}
