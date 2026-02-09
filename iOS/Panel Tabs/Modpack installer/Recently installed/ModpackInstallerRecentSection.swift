import SwiftUI

struct ModpackInstallerRecentSection: View {
    @EnvironmentObject private var store: ValueStore
    
    private let modpacks: [InstalledModpack]
    
    init(_ modpacks: [InstalledModpack]) {
        self.modpacks = modpacks
    }
    
    var body: some View {
        BillingSectionCard("Most recently installed modpacks", showsBackground: false) {
            VStack(alignment: .leading, spacing: 10) {
                ForEach(modpacks) {
                    ModpackInstallerRecentCard($0)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
