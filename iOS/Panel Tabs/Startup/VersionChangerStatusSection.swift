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
                let typeIconURL = installedTypeIconURL(for: build.type)
                let typeName = vm.installedVersionChangerType?.name ?? build.type
                
                if let version = build.versionId ?? build.projectVersionId {
                    VersionChangerCurrentVersionCard(
                        typeName,
                        subtitle: version,
                        iconURL: typeIconURL,
                        trailingSymbol: installed.isOutdated ? "arrow.trianglehead.clockwise" : "checkmark.circle",
                        trailingTint: installed.isOutdated ? .yellow : .green
                    )
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
    
    private func installedTypeIconURL(for buildType: String) -> URL? {
        if let installedType = vm.installedVersionChangerType {
            return installedType.iconURL
        }
        
        let normalizedBuildType = normalizeVersionChangerType(buildType)
        
        let bestMatch = vm.versionChangerTypes.max { left, right in
            scoreVersionChangerTypeMatch(left, normalizedBuildType: normalizedBuildType)
            < scoreVersionChangerTypeMatch(right, normalizedBuildType: normalizedBuildType)
        }
        
        guard
            let bestMatch,
            scoreVersionChangerTypeMatch(bestMatch, normalizedBuildType: normalizedBuildType) > 0
        else {
            return nil
        }
        
        return bestMatch.iconURL
    }
    
    private func scoreVersionChangerTypeMatch(
        _ provider: VersionChangerProviderType,
        normalizedBuildType: String
    ) -> Int {
        let normalizedIdentifier = normalizeVersionChangerType(provider.identifier)
        let normalizedName = normalizeVersionChangerType(provider.name)
        
        if normalizedBuildType == normalizedIdentifier || normalizedBuildType == normalizedName {
            return 300
        }
        
        if normalizedBuildType.contains(normalizedIdentifier) || normalizedIdentifier.contains(normalizedBuildType) {
            return 200
        }
        
        if normalizedBuildType.contains(normalizedName) || normalizedName.contains(normalizedBuildType) {
            return 150
        }
        
        let buildTokens = tokenizeVersionChangerType(normalizedBuildType)
        let identifierTokens = tokenizeVersionChangerType(normalizedIdentifier)
        let nameTokens = tokenizeVersionChangerType(normalizedName)
        
        if buildTokens.intersection(identifierTokens).isEmpty == false {
            return 100
        }
        
        if buildTokens.intersection(nameTokens).isEmpty == false {
            return 80
        }
        
        return 0
    }
    
    private func normalizeVersionChangerType(_ value: String) -> String {
        value
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .lowercased()
            .replacingOccurrences(of: "[^a-z0-9]", with: " ", options: .regularExpression)
    }
    
    private func tokenizeVersionChangerType(_ value: String) -> Set<String> {
        Set(
            value
                .split(separator: " ")
                .filter {
                    $0.isEmpty == false
                }
                .map(String.init)
        )
    }
}

#Preview {
    VersionChangerStatusSection()
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
