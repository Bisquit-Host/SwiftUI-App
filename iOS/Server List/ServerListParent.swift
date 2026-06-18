import SwiftUI

struct ServerListParent: View {
    private let showsSettingsToolbarItem: Bool
    @EnvironmentObject private var store: ValueStore
    
    init(showsSettingsToolbarItem: Bool = true) {
        self.showsSettingsToolbarItem = showsSettingsToolbarItem
    }
    
    var body: some View {
        if store.isApiKeyValid {
#if os(iOS)
            ServerList(showsSettingsToolbarItem: showsSettingsToolbarItem)
#else
            ServerList()
#endif
        } else {
            StartPage()
        }
    }
}
