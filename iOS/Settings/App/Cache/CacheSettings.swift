import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    
    var body: some View {
        BillingSectionCard("Cache") {
            CacheSize()
        }
        .environment(cache)
    }
}

#Preview {
    List {
        CacheSettings()
    }
    .darkSchemePreferred()
}
