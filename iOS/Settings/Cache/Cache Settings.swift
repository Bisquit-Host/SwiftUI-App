import SwiftUI

struct CacheSettings: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    var body: some View {
        Section("Cache") {
            CacheSize()
            
            CacheLimit()
            
            CacheExpiration()
        }
        .listRowBackground(settings.transparentList ? .clear : Color.list)
    }
}
