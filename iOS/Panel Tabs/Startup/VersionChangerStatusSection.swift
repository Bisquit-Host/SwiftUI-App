import SwiftUI

struct VersionChangerStatusSection: View {
    @Environment(StartupVM.self) private var vm
    
    var body: some View {
        if vm.isLoadingVersionChanger {
            HStack(spacing: 10) {
                ProgressView()
                Text("Loading version data")
                    .secondary()
            }
        } else if !vm.versionChangerAvailable {
            HStack(spacing: 10) {
                Image(systemName: "exclamationmark.triangle")
                    .foregroundStyle(.yellow)
                
                Text("Version changer addon is not available on this panel")
                    .secondary()
            }
        } else if let installed = vm.versionChangerInstalled,
                  let build = installed.build {
            VStack(alignment: .leading, spacing: 10) {
                if let type = vm.installedVersionChangerType {
                    GlassyButton(
                        "Type",
                        subtitle: type.name,
                        icon: installed.isOutdated ? "arrow.trianglehead.clockwise" : "checkmark.circle",
                        tint: installed.isOutdated ? .yellow : .green
                    )
                }
                
                if let version = build.versionId ?? build.projectVersionId {
                    GlassyButton("Version", subtitle: version, icon: "shippingbox", tint: .blue)
                }
                
                if build.type.uppercased() != "VANILLA" {
                    GlassyButton("Build", subtitle: build.name, icon: "hammer", tint: .indigo)
                }
                
                if installed.isOutdated, let latestBuild = installed.latest {
                    GlassyButton("Latest build", subtitle: latestBuild.name, icon: "clock.arrow.trianglehead.2.counterclockwise.rotate.90", tint: .yellow)
                }
            }
        } else {
            HStack(spacing: 10) {
                Image(systemName: "questionmark.circle")
                    .foregroundStyle(.secondary)
                
                Text("No installed Minecraft server version found")
                    .secondary()
            }
        }
    }
}

#Preview {
    VersionChangerStatusSection()
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
