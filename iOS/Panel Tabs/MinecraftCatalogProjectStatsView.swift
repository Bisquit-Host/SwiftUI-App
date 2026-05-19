import SwiftUI

struct MinecraftCatalogProjectStatsView: View {
    private let project: MinecraftCatalogProject
    
    init(_ project: MinecraftCatalogProject) {
        self.project = project
    }
    
    private var metricDownloads: Int? {
        project.downloads ?? project.installs
    }
    
    private var metricLikes: Int? {
        project.likes ?? project.plays
    }
    
    private var metricLikesSymbol: String {
        project.likes == nil ? "play.fill" : "heart.fill"
    }
    
    private func formatMetric(_ value: Int) -> String {
        max(0, value).formatted(.number.notation(.compactName))
    }
    
    var body: some View {
        if project.hasStats {
            HStack(spacing: 10) {
                if let metricDownloads {
                    Label(formatMetric(metricDownloads), systemImage: "square.and.arrow.down")
                }
                
                if let metricLikes {
                    Label(formatMetric(metricLikes), systemImage: metricLikesSymbol)
                }
            }
            .caption()
            .secondary()
        }
    }
}

#Preview {
    MinecraftCatalogProjectStatsView(
        MinecraftCatalogProject(
            id: "1",
            name: "Preview",
            description: "Preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil,
            likes: 1_598,
            downloads: 65_024,
            installs: 65_024,
            plays: 219_112
        )
    )
}
