import SwiftUI

struct VersionChangerBuildSheet: View {
    @Environment(VersionChangerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let type: VersionChangerProviderType
    private let version: VersionChangerVersion
    
    init(type: VersionChangerProviderType, version: VersionChangerVersion) {
        self.type = type
        self.version = version
    }
    
    @State private var selectedBuild: Int?
    @State private var deleteFiles = false
    @State private var acceptEula = true
    @State private var alertInstallVersion = false
    @State private var isLoadingBuilds = true
    
    private var selectedBuildObject: VersionChangerBuild? {
        guard let selectedBuild else {
            return version.latest
        }
        
        return vm.versionChangerBuilds.first {
            $0.id == selectedBuild
        }
    }
    
    private var canInstallVersion: Bool {
        !isLoadingBuilds && !vm.isInstallingVersionChanger && selectedBuildObject != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard {
                    if isLoadingBuilds {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading builds")
                                .secondary()
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            if vm.versionChangerBuilds.isEmpty {
                                GlassyButton("Build", subtitle: version.latest.name, icon: "hammer.fill", tint: .mint)
                            } else {
                                VersionChangerPickerCard(title: "Build", icon: "hammer.fill", tint: .mint) {
                                    Picker(selection: $selectedBuild) {
                                        ForEach(Array(vm.versionChangerBuilds.enumerated()), id: \.offset) { _, build in
                                            let suffix = build.experimental ? " (experimental)" : ""
                                            
                                            Text("Build \(build.name)\(suffix)")
                                                .tag(Optional(build.id))
                                        }
                                    } label: {
                                        
                                    }
                                    .pickerStyle(.menu)
                                    .tint(.primary)
                                }
                            }
                            
                            Divider()
                            
                            GlassyToggle("Wipe server files", icon: "trash.fill", tint: .red, isOn: $deleteFiles)
                            GlassyToggle("Accept Minecraft EULA", icon: "text.document", tint: .gray, isOn: $acceptEula)
                            
                            Divider()
                            
                            Button("Install", role: .destructive) {
                                alertInstallVersion = true
                            }
                            .subheadline(.semibold)
                            .buttonStyle(.plain)
                            .opacity(canInstallVersion ? 1 : 0.5)
                            .allowsHitTesting(canInstallVersion)
                        }
                    }
                }
            }
            .padding()
        }
        .navigationTitle(version.version)
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .refreshable {
            await fetchBuilds()
        }
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        }
        .alert("Install selected version", isPresented: $alertInstallVersion) {
            Button("Install", role: .destructive, action: installVersion)
            Button("Cancel", role: .cancel) {}
        } message: {
            if let selectedBuildObject {
                Text("Install build \(selectedBuildObject.name) now")
            } else {
                Text("Install selected version now")
            }
        }
        .task(id: version.id) {
            await fetchBuilds()
        }
    }
    
    private func fetchBuilds() async {
        isLoadingBuilds = true
        
        await vm.fetchVersionChangerBuilds(type: type.identifier, version: version.version)
        
        if let latestBuild = vm.versionChangerBuilds.first(where: {
            $0.id == version.latest.id
        }) {
            selectedBuild = latestBuild.id
        } else {
            selectedBuild = vm.versionChangerBuilds.first?.id
        }
        
        isLoadingBuilds = false
    }
    
    private func installVersion() {
        guard let selectedBuildObject else {
            return
        }
        
        Task {
            let installed = await vm.installVersionChangerBuild(
                selectedBuildObject.id,
                deleteFiles: deleteFiles,
                acceptEula: acceptEula
            )
            
            guard installed else {
                return
            }
            
            await vm.fetchVersionChangerData()
            dismiss()
        }
    }
}

#Preview {
    VersionChangerBuildSheet(
        type: VersionChangerProviderType(
            category: "Preview",
            identifier: "PAPER",
            name: "Paper",
            icon: "",
            homepage: nil,
            description: "Preview",
            experimental: false,
            deprecated: false,
            builds: 100,
            versions: VersionChangerProviderVersions(minecraft: 20, project: 0)
        ),
        version: VersionChangerVersion(
            version: "1.21.1",
            type: .release,
            builds: 42,
            latest: VersionChangerBuild(
                id: 1,
                type: "PAPER",
                projectVersionId: "1.21.1",
                versionId: "1.21.1",
                name: "123",
                experimental: false,
                created: nil
            )
        )
    )
    .darkSchemePreferred()
    .environment(VersionChangerVM(""))
}
