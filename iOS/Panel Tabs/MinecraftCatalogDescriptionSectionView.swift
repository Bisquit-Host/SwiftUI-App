import SwiftUI

struct MinecraftCatalogDescriptionSectionView: View {
    @EnvironmentObject private var store: ValueStore
    
    private let project: MinecraftCatalogProject
    
    init(_ project: MinecraftCatalogProject) {
        self.project = project
    }
    
    var body: some View {
        if !project.description.isEmpty {
            BillingSectionCard("Description", showsBackground: false) {
                Text(project.description)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        }
    }
}
