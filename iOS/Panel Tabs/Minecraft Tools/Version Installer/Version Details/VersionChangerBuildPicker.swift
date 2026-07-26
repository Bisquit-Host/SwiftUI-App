import SwiftUI

struct VersionChangerBuildPicker: View {
    @Binding private var selectedBuild: String?
    
    private let builds: [VersionChangerBuild]
    private let selectedBuildName: String
    private let latestBuildName: String
    
    init(
        selectedBuild: Binding<String?>,
        builds: [VersionChangerBuild],
        selectedBuildName: String,
        latestBuildName: String
    ) {
        _selectedBuild = selectedBuild
        self.builds = builds
        self.selectedBuildName = selectedBuildName
        self.latestBuildName = latestBuildName
    }
    
    var body: some View {
        if builds.isEmpty {
            GlassyButton("Build", subtitle: latestBuildName, icon: "hammer.fill", tint: .mint)
        } else {
            VStack(alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    GlassyIcon("hammer.fill", tint: .mint)
                    
                    Text("Build")
                        .subheadline(.semibold)
                    
                    Spacer()
                }
                
                Picker(selection: $selectedBuild) {
                    ForEach(Array(builds.enumerated()), id: \.offset) { _, build in
                        let suffix = build.experimental ? " (experimental)" : ""
                        
                        Text("Build \(build.name)\(suffix)")
                            .tag(Optional(build.id))
                    }
                } label: {
                    Text(selectedBuildName)
                        .lineLimit(1)
                        .truncationMode(.tail)
                }
                .pickerStyle(.menu)
                .tint(.primary)
            }
        }
    }
}

#Preview {
    VersionChangerBuildPicker(
        selectedBuild: .constant("preview-build-2"),
        builds: [
            VersionChangerBuild(
                id: "preview-build-1",
                type: "PAPER",
                projectVersionId: "1.21.1",
                versionId: "1.21.1",
                name: "118",
                experimental: false,
                created: nil
            ),
            VersionChangerBuild(
                id: "preview-build-2",
                type: "PAPER",
                projectVersionId: "1.21.1",
                versionId: "1.21.1",
                name: "119",
                experimental: true,
                created: nil
            )
        ],
        selectedBuildName: "119",
        latestBuildName: "119"
    )
    .padding()
    .darkSchemePreferred()
}
