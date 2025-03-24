import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    
    var body: some View {
        Section("Cache") {
            CacheSize()
            
            CacheLimit()
            
            CacheExpiration()
            
            NavigationLink("View cache") {
                CacheList()
            }
        }
        .environment(cache)
        .transparentSection()
    }
}
