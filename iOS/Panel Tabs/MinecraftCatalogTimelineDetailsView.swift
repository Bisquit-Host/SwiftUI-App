import SwiftUI

struct MinecraftCatalogTimelineDetailsView: View {
    @EnvironmentObject private var store: ValueStore
    
    let project: MinecraftCatalogProject
    
    var body: some View {
        if project.lastUpdatedAt != nil || project.releasedAt != nil {
            BillingSectionCard("Project details", showsBackground: false) {
                VStack(alignment: .leading, spacing: 10) {
                    if let lastUpdatedAt = project.lastUpdatedAt {
                        Label("Last update: \(formatDate(lastUpdatedAt))", systemImage: "clock.arrow.circlepath")
                            .subheadline()
                    }

                    if let releasedAt = project.releasedAt {
                        Label("Release date: \(formatDate(releasedAt))", systemImage: "calendar")
                            .subheadline()
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        }
    }
    
    private func formatDate(_ value: Date) -> String {
        value.formatted(date: .abbreviated, time: .omitted)
    }
}
