import SwiftUI

struct MinecraftCatalogTimelineDetailsView: View {
    let project: MinecraftCatalogProject
    
    var body: some View {
        if project.lastUpdatedAt != nil || project.releasedAt != nil {
            BillingSectionCard("Project details") {
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
        }
    }
    
    private func formatDate(_ value: Date) -> String {
        value.formatted(date: .abbreviated, time: .omitted)
    }
}
