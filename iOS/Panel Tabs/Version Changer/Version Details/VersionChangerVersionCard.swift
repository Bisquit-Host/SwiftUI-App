import SwiftUI

struct VersionChangerVersionCard: View {
    private let version: VersionChangerVersion
    
    init(_ version: VersionChangerVersion) {
        self.version = version
    }
    
    private var releaseLabel: String {
        switch version.type {
        case .snapshot: "Snapshot"
        case .release: "Release"
        case nil: "Version"
        }
    }
    
    var body: some View {
        HStack(spacing: 12) {
            GlassyIcon("number", tint: version.type == .snapshot ? .orange : .blue)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(version.version)
                    .subheadline(.semibold)
                
                Text("\(releaseLabel) • \(version.builds) builds")
                    .secondary()
                    .footnote()
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .secondary()
                .footnote()
        }
    }
}

#Preview {
    VersionChangerVersionCard(
        VersionChangerVersion(
            version: "1.21.1",
            type: .release,
            builds: 42,
            latest: VersionChangerBuild(
                id: "preview-build-1",
                type: "PAPER",
                projectVersionId: "1.21.1",
                versionId: "1.21.1",
                name: "123",
                experimental: false,
                created: nil
            )
        )
    )
    .padding()
    .darkSchemePreferred()
}
