import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    @EnvironmentObject private var store: ValueStore
    
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
        .listRowBackground(store.transparentList ? .clear : Color.list)
    }
}
