import SwiftUI

struct MinecraftCatalogProjectStatsView: View {
    let project: MinecraftCatalogProject

    var body: some View {
        if project.hasStats {
            HStack(spacing: 10) {
                if let downloads = project.downloads {
                    Label(formatMetric(downloads), systemImage: "square.and.arrow.down")
                }

                if let likes = project.likes {
                    Label(formatMetric(likes), systemImage: "heart.fill")
                }
            }
            .caption()
            .secondary()
        }
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
            downloads: 65_024
        )
    )
}
