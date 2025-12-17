import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    
    var body: some View {
        BillingSectionCard("Cache") {
            CacheSize()
            CacheLimit()
            CacheExpiration()
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
