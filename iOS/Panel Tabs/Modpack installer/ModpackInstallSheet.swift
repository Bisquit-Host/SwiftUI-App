import SwiftUI
import SafariCover

struct ModpackInstallSheet: View {
    @Environment(ModpackInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let provider: ModpackProvider
    private let modpack: MinecraftCatalogProject
    
    init(
        provider: ModpackProvider,
        modpack: MinecraftCatalogProject
    ) {
        self.provider = provider
        self.modpack = modpack
    }
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var deleteServerFiles = false
    @State private var askForInstall = false
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Install modpack") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(modpack.name)
                            .headline(.semibold)
                        
                        if modpack.webPageURL != nil {
                            Button("Open page", systemImage: "safari") {
                                showSafari = true
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if isLoadingVersions {
                            HStack(spacing: 10) {
                                ProgressView()
                                
                                Text("Loading versions")
                                    .secondary()
                            }
                        } else if vm.minecraftModpackVersions.isEmpty {
                            Text("No versions found")
                                .secondary()
                        } else {
                            Picker("Version", selection: $selectedVersionId) {
                                ForEach(vm.minecraftModpackVersions) { version in
                                    Text(version.name)
                                        .tag(Optional(version.id))
                                }
                            }
                            
                            Toggle("Delete server files first", isOn: $deleteServerFiles)
                            
                            Button("Install selected version", systemImage: "square.and.arrow.down.fill", role: .destructive) {
                                askForInstall = true
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedVersionId == nil || vm.isInstallingMinecraftModpack)
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle(modpack.name)
        .safariCover($showSafari, url: modpackWebPageURL)
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        }
        .task {
            await loadVersions()
        }
        .alert("Install selected version", isPresented: $askForInstall) {
            Button("Install", role: .destructive, action: install)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Start modpack installation now")
        }
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        await vm.fetchMinecraftModpackVersions(provider: provider, modpackId: modpack.id)
        
        selectedVersionId = vm.minecraftModpackVersions.first?.id
        isLoadingVersions = false
    }
    
    private var modpackWebPageURL: String {
        modpack.webPageURL ?? ""
    }
    
    private func install() {
        guard let selectedVersionId else { return }
        
        Task {
            let installed = await vm.installMinecraftModpack(
                provider: provider,
                modpackId: modpack.id,
                versionId: selectedVersionId,
                deleteServerFiles: deleteServerFiles
            )
            
            guard installed else {
                return
            }
            
            dismiss()
        }
    }
}

#Preview {
    ModpackInstallSheet(
        provider: .modrinth,
        modpack: MinecraftCatalogProject(
            id: "1",
            name: "Preview",
            description: "Preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        )
    )
    .darkSchemePreferred()
    .environment(ModpackInstallerVM(""))
}
