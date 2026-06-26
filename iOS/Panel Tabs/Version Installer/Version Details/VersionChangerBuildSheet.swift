import SwiftUI
import Calagopus

struct VersionChangerBuildSheet: View {
    @Environment(VersionChangerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    private let type: VersionChangerProviderType
    private let version: VersionChangerVersion
    
    init(type: VersionChangerProviderType, version: VersionChangerVersion) {
        self.type = type
        self.version = version
    }
    
    @State private var selectedBuild: String?
    @State private var deleteFiles = false
    @State private var acceptEula = true
    @State private var alertInstallVersion = false
    @State private var isLoadingBuilds = true
    @State private var builds: [VersionChangerBuild] = []
    @State private var errorMessage: String?
    @State private var warningMessage: String?
    
    private var selectedBuildObject: VersionChangerBuild? {
        guard let selectedBuild else {
            return errorMessage == nil ? version.latest : nil
        }
        
        return builds.first {
            $0.id == selectedBuild
        }
    }
    
    private var canInstallVersion: Bool {
        !isLoadingBuilds && !vm.isInstallingVersionChanger && selectedBuildObject != nil
    }
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard(showsBackground: false) {
                    if isLoadingBuilds {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading builds")
                                .secondary()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    } else if let errorMessage {
                        VStack(alignment: .leading, spacing: 12) {
                            GlassyButton("Builds unavailable", subtitle: errorMessage, icon: "exclamationmark.triangle.fill", tint: .red)
                            
                            Button("Retry", systemImage: "arrow.clockwise") {
                                Task {
                                    await fetchBuilds()
                                }
                            }
                            .subheadline(.semibold)
                            .buttonStyle(.plain)
                        }
                    } else {
                        VStack(alignment: .leading, spacing: 12) {
                            if let warningMessage {
                                GlassyButton("Showing latest build", subtitle: warningMessage, icon: "exclamationmark.triangle.fill", tint: .orange)
                                
                                Button("Retry", systemImage: "arrow.clockwise") {
                                    Task {
                                        await fetchBuilds()
                                    }
                                }
                                .subheadline(.semibold)
                                .buttonStyle(.plain)
                                
                                Divider()
                            }
                            
                            VersionChangerBuildPicker(
                                selectedBuild: $selectedBuild,
                                builds: builds,
                                selectedBuildName: selectedBuildObject?.name ?? "-",
                                latestBuildName: version.latest.name
                            )
                            
                            Divider()
                            
                            GlassyToggle("Wipe server files", icon: "trash.fill", tint: .red, isOn: $deleteFiles)
                            GlassyToggle("Accept Minecraft EULA", icon: "text.document", tint: .gray, isOn: $acceptEula)
                            
                            Divider()
                            
                            Button("Install") {
                                alertInstallVersion = true
                            }
                            .semibold()
                            .buttonStyle(.borderedProminent)
                            .buttonSizing(.flexible)
                            .buttonBorderShape(.roundedRectangle(radius: 12))
                            .opacity(canInstallVersion ? 1 : 0.5)
                            .allowsHitTesting(canInstallVersion)
                        }
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle(version.version)
        .toolbarTitleDisplayMode(.inline)
        .scrollIndicators(.never)
        .refreshable {
            await fetchBuilds()
        }
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium])
        .alert("Install selected version", isPresented: $alertInstallVersion) {
            Button("Install", role: .confirm, action: installVersion)
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
        errorMessage = nil
        warningMessage = nil
        
        do {
            builds = try await vm.loadVersionChangerBuildDetails(type: type.identifier, version: version.version)
            
            if let latestBuild = builds.first(where: {
                $0.id == version.latest.id
            }) {
                selectedBuild = latestBuild.id
            } else {
                selectedBuild = builds.first?.id
            }
        } catch {
            if isPanelStatusError(error, code: 500) {
                builds = [version.latest]
                selectedBuild = version.latest.id
                warningMessage = "The panel returned status 500, showing the latest build"
                SystemAlert.error("Version details unavailable", subtitle: warningMessage)
            } else {
                builds = []
                selectedBuild = nil
                errorMessage = versionDetailsErrorMessage(error)
                SystemAlert.error("Version details unavailable", subtitle: errorMessage)
            }
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
            
            guard installed else { return }
            await vm.fetchVersionChangerData()
            dismiss()
        }
    }
    
    private func versionDetailsErrorMessage(_ error: Error) -> String {
        if case MinecraftInstallerRequestError.badStatusCode(let code) = error {
            return "The panel returned status \(code)"
        }
        
        return error.localizedDescription
    }
    
    private func isPanelStatusError(_ error: Error, code: Int) -> Bool {
        if case MinecraftInstallerRequestError.badStatusCode(let statusCode) = error, statusCode == code {
            return true
        }
        
        return false
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
    .darkSchemePreferred()
    .environment(VersionChangerVM(""))
}
