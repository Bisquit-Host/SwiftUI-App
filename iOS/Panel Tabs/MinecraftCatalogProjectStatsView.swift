import SwiftUI

struct MinecraftCatalogProjectStatsView: View {
    let project: MinecraftCatalogProject
    
    var body: some View {
        if project.hasStats {
            HStack(spacing: 10) {
                if let downloads = metricDownloads {
                    Label(formatMetric(downloads), systemImage: "square.and.arrow.down")
                }
                
                if let likes = metricLikes {
                    Label(formatMetric(likes), systemImage: metricLikesSymbol)
                }
            }
            .caption()
            .secondary()
        }
    }
    
    private var metricDownloads: Int? {
        project.downloads ?? project.installs
    }
    
    private var metricLikes: Int? {
        project.likes ?? project.plays
    }
    
    private var metricLikesSymbol: String {
        if project.likes != nil {
            return "heart.fill"
        }
        
        return "play.fill"
    }
    
    private func formatMetric(_ value: Int) -> String {
        max(0, value).formatted(.number.notation(.compactName))
    }
}

#Preview {
    MinecraftCatalogProjectStatsView(
        project: MinecraftCatalogProject(
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
