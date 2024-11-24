import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    @EnvironmentObject private var settings: ValueStorage
    
    var body: some View {
        Section("Cache") {
            CacheSize()
            
            CacheLimit()
            
            CacheExpiration()
            
            NavigationLink("Retrieve cache") {
                CacheList()
            }
        }
        .environment(cache)
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}
