import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    
    var body: some View {
        Section("Cache") {
            CacheSize()
            
            CacheLimit()
            
            CacheExpiration()
            
            NavigationLink("Retrieve cached data") {
                CacheList()
            }
        }
        .environment(cache)
        .transparentSection()
    }
}
