import SwiftUI

struct ServerListParent: View {
    private let showsSettingsToolbarItem: Bool
    @EnvironmentObject private var store: ValueStore
    
    init(showsSettingsToolbarItem: Bool = true) {
        self.showsSettingsToolbarItem = showsSettingsToolbarItem
    }
    
    var body: some View {
#if os(iOS)
        if canOpenPanel {
            ServerList(showsSettingsToolbarItem: showsSettingsToolbarItem)
        } else {
            StartPage()
        }
#else
        if store.isApiKeyValid {
            ServerList()
        } else {
            StartPage()
        }
#endif
    }
    
#if os(iOS)
    private var canOpenPanel: Bool {
        store.isApiKeyValid || !(store.accessToken?.isEmpty ?? true)
    }
#endif
}
