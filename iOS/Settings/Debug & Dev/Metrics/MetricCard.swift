import SwiftUI

struct MetricCard: View {
    @Environment(MetricListVM.self) private var vm
    
    private let url: URL
    
    init(_ url: URL) {
        self.url = url
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(url.lastPathComponent)
            
            if let modified = vm.modificationDate(url) {
                Text(modified, style: .date)
                    .caption()
                    .secondary()
            }
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
