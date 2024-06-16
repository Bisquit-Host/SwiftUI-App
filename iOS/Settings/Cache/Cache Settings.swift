import SwiftUI

struct CacheSettings: View {
    @State private var cache = CacheVM()
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        Section("Cache") {
            CacheSize()
            
            CacheLimit()
            
            CacheExpiration()
            
#if DEBUG
            NavigationLink("Retrieve cache") {
                CacheList()
            }
#endif
        }
        .environment(cache)
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}
