import SwiftUI

struct VersionChangerInstalledSection: View {
    @Environment(VersionChangerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @State private var isInstallingUpdate = false
    
    var body: some View {
        BillingSectionCard("Currently installed", showsBackground: false) {
            if vm.isLoadingVersionChanger && vm.versionChangerInstalled == nil {
                HStack(spacing: 10) {
                    ProgressView()
                    
                    Text("Loading installed version")
                        .secondary()
                }
            } else if let installed = vm.versionChangerInstalled, let build = installed.build {
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 12) {
                        VersionChangerTypeLogo(url: vm.installedVersionChangerType?.iconURL, size: 34)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(displayTypeName(for: build))
                                .subheadline(.semibold)
                            
                            Text(displayVersion(for: build))
                                .secondary()
                                .footnote()
                        }
                        
                        Spacer()
                    }
                    
                    if installed.isOutdated, let latest = installed.latest {
                        HStack {
                            Text("Update available: build \(latest.name)")
                                .footnote()
                                .foregroundStyle(.orange)
                            
                            Spacer()
                            
                            Button("Update", systemImage: "arrow.down.circle.fill") {
                                update(latest)
                            }
                            .buttonStyle(.borderedProminent)
                            .tint(.yellow)
                            .controlSize(.small)
                            .disabled(isInstallingUpdate || vm.isInstallingVersionChanger)
                        }
                    }
                }
            } else {
                Text("No installed version")
                    .secondary()
            }
        }
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
    
    private func displayTypeName(for build: VersionChangerBuild) -> String {
        if let type = vm.installedVersionChangerType?.name {
            type
        } else {
            build.type
        }
    }
    
    private func displayVersion(for build: VersionChangerBuild) -> String {
        let version = build.projectVersionId ?? build.versionId
        
        guard let version, version.isEmpty == false else {
            return "Version unknown"
        }
        
        return "Version \(version) \(build.name)"
    }
    
    private func update(_ latest: VersionChangerBuild) {
        isInstallingUpdate = true
        
        Task {
            let installed = await vm.installVersionChangerBuild(latest.id, deleteFiles: false, acceptEula: true)
            
            if installed {
                await vm.fetchVersionChangerData()
            }
            
            isInstallingUpdate = false
        }
    }
}
