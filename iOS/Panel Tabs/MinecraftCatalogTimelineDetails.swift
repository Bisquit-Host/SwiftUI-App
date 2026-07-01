import SwiftUI
import Calagopus

struct MinecraftCatalogTimelineDetails: View {
    @EnvironmentObject private var store: ValueStore
    
    private let project: MinecraftCatalogProject
    
    init(_ project: MinecraftCatalogProject) {
        self.project = project
    }
    
    var body: some View {
        if project.lastUpdatedAt != nil || project.releasedAt != nil {
            BillingSectionCard("Details", showsBackground: false) {
                VStack(alignment: .leading, spacing: 10) {
                    if let lastUpdatedAt = project.lastUpdatedAt {
                        HStack {
                            Label("Last update", systemImage: "clock.arrow.circlepath")
                            
                            Spacer()
                            
                            Text(formatDate(lastUpdatedAt))
                                .secondary()
                        }
                        .subheadline()
                    }
                    
                    if let releasedAt = project.releasedAt {
                        HStack {
                            Label("Release date", systemImage: "calendar")
                            
                            Spacer()
                            
                            Text(formatDate(releasedAt))
                                .secondary()
                        }
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
