import SwiftUI

struct ServerListParent: View {
    private let showsSettingsToolbarItem: Bool
    
    init(showsSettingsToolbarItem: Bool = true) {
        self.showsSettingsToolbarItem = showsSettingsToolbarItem
    }
    
    var body: some View {
#if os(iOS)
        ServerList(showsSettingsToolbarItem: showsSettingsToolbarItem)
#else
        ServerList()
#endif
    }
}
