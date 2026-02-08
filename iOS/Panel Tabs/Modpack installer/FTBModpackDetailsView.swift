import SwiftUI

struct FTBModpackDetailsView: View {
    let project: MinecraftCatalogProject

    var body: some View {
        if project.hasFTBMetadata {
            BillingSectionCard("FTB details") {
                VStack(alignment: .leading, spacing: 10) {
                    if let installs = project.installs {
                        Label("Installs: \(formatMetric(installs))", systemImage: "square.and.arrow.down")
                            .subheadline()
                    }

                    if let plays = project.plays {
                        Label("Plays: \(formatMetric(plays))", systemImage: "play.fill")
                            .subheadline()
                    }

                    if let minimumRAMMB = project.minimumRAMMB {
                        Label("Minimum RAM: \(formatRAM(minimumRAMMB))", systemImage: "memorychip")
                            .subheadline()
                    }

                    if let recommendedRAMMB = project.recommendedRAMMB {
                        Label("Recommended RAM: \(formatRAM(recommendedRAMMB))", systemImage: "memorychip.fill")
                            .subheadline()
                    }

                    if let javaVersion = project.javaVersion {
                        Label("Java: \(javaVersion)", systemImage: "cup.and.saucer.fill")
                            .subheadline()
                    }

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
        project: MinecraftCatalogProject(
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
}
