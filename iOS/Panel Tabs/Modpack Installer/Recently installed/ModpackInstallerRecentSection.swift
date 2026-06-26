import Calagopus
import SwiftUI

struct ModpackInstallerRecentSection: View {
    @EnvironmentObject private var store: ValueStore
    
    private let modpacks: [InstalledModpack]
    
    init(_ modpacks: [InstalledModpack]) {
        self.modpacks = modpacks
    }
    
    var body: some View {
        BillingSectionCard("Most recently installed modpacks", showsBackground: false) {
            ForEach(modpacks) {
                ModpackInstallerRecentCard($0)
            }
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
