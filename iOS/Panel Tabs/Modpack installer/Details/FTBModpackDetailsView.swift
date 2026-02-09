import SwiftUI

struct FTBModpackDetailsView: View {
    @EnvironmentObject private var store: ValueStore
    
    private let project: MinecraftCatalogProject
    
    init(_ project: MinecraftCatalogProject) {
        self.project = project
    }
    
    var body: some View {
        if project.hasFTBMetadata {
            BillingSectionCard("Details", showsBackground: false) {
                VStack(alignment: .leading, spacing: 10) {
                    if let installs = project.installs {
                        LabeledContent {
                            Text(formatMetric(installs))
                        } label: {
                            Label("Installs", systemImage: "square.and.arrow.down")
                        }
                    }
                    
                    if let plays = project.plays {
                        LabeledContent {
                            Text(formatMetric(plays))
                        } label: {
                            Label("Plays", systemImage: "play.fill")
                        }
                    }
                    
                    if let minimumRAMMB = project.minimumRAMMB {
                        LabeledContent {
                            Text(formatRAM(minimumRAMMB))
                        } label: {
                            Label("Minimum RAM", systemImage: "memorychip")
                        }
                    }
                    
                    if let recommendedRAMMB = project.recommendedRAMMB {
                        LabeledContent {
                            Text(formatRAM(recommendedRAMMB))
                        } label: {
                            Label("Recommended RAM", systemImage: "memorychip.fill")
                        }
                    }
                    
                    if let javaVersion = project.javaVersion {
                        LabeledContent {
                            Text(javaVersion)
                        } label: {
                            Label("Java", systemImage: "cup.and.saucer.fill")
                        }
                    }
                    
                    if let lastUpdatedAt = project.lastUpdatedAt {
                        LabeledContent {
                            Text(formatDate(lastUpdatedAt))
                        } label: {
                            Label("Last update", systemImage: "clock.arrow.circlepath")
                        }
                    }
                    
                    if let releasedAt = project.releasedAt {
                        LabeledContent {
                            Text(formatDate(releasedAt))
                        } label: {
                            Label("Release date", systemImage: "calendar")
                        }
                    }
                }
                .subheadline()
                .frame(maxWidth: .infinity, alignment: .leading)
            }
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        }
    }
    
    private func formatMetric(_ value: Int) -> String {
        max(0, value).formatted(.number.notation(.compactName))
    }
    
    private func formatRAM(_ value: Int) -> String {
        guard value > 0 else {
            return "Unknown"
        }
        
        if value % 1024 == 0 {
            return "\((value / 1024).formatted()) GB"
        }
        
        let gbValue = Double(value) / 1024
        return "\(gbValue.formatted(.number.precision(.fractionLength(1)))) GB"
    }
    
    private func formatDate(_ value: Date) -> String {
        value.formatted(date: .abbreviated, time: .omitted)
    }
}

#Preview {
    FTBModpackDetailsView(
        MinecraftCatalogProject(
            id: "100",
            name: "FTB Preview",
            description: "Preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil,
            installs: 2_352_521,
            plays: 13_537_450,
            minimumRAMMB: 4096,
            recommendedRAMMB: 6144,
            javaVersion: "17.0.2+8",
            lastUpdatedAt: Date(),
            releasedAt: Date().addingTimeInterval(-60 * 60 * 24 * 30)
        )
    )
    .environmentObject(ValueStore())
}
