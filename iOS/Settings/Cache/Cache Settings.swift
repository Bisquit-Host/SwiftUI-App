import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    
    var body: some View {
        Section("Cache") {
            CacheSize()
            
            CacheLimit()
            
            CacheExpiration()
#if DEBUG
            NavigationLink("View cache") {
                CacheList()
            }
#endif
        }
        .environment(cache)
    }
}

#Preview {
    List {
        CacheSettings()
    }
}
