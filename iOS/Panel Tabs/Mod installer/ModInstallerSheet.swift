import SwiftUI
import SafariCover

struct ModInstallerSheet: View {
    @Environment(ModInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let provider: ModManagerProvider
    private let mod: MinecraftCatalogProject
    private let modLoader: String
    private let minecraftVersion: String
    
    init(
        provider: ModManagerProvider,
        mod: MinecraftCatalogProject,
        modLoader: String,
        minecraftVersion: String
    ) {
        self.provider = provider
        self.mod = mod
        self.modLoader = modLoader
        self.minecraftVersion = minecraftVersion
    }
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var askForInstall = false
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Install mod") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mod.name)
                            .headline(.semibold)

                        if mod.webPageURL != nil {
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
                        } else if vm.minecraftModVersions.isEmpty {
                            Text("No versions found")
                                .secondary()
                            
                        } else {
                            Picker("Version", selection: $selectedVersionId) {
                                ForEach(vm.minecraftModVersions) {
                                    Text($0.name)
                                        .tag(Optional($0.id))
                                }
                            }
                            
                            Button("Install selected version", systemImage: "square.and.arrow.down.fill", role: .destructive) {
                                askForInstall = true
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedVersionId == nil || vm.isInstallingMinecraftMod)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .scenePadding(.horizontal)
        }
        .scrollIndicators(.never)
        .navigationTitle(mod.name)
        .safariCover($showSafari, url: modWebPageURL)
        .task {
            await loadVersions()
        }
        .alert("Install selected version", isPresented: $askForInstall) {
            Button("Install", role: .destructive, action: install)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Install this mod now")
        }
        .toolbar {
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        }
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        
        await vm.fetchMinecraftModVersions(
            provider: provider,
            modId: mod.id,
            modLoader: modLoader,
            minecraftVersion: minecraftVersion
        )
        
        selectedVersionId = vm.minecraftModVersions.first?.id
        isLoadingVersions = false
    }

    private var modWebPageURL: String {
        mod.webPageURL ?? ""
    }
    
    private func install() {
        guard let selectedVersionId else {
            return
        }
        
        Task {
            let installed = await vm.installMinecraftMod(
                provider: provider,
                modId: mod.id,
                versionId: selectedVersionId
            )
            
            guard installed else {
                return
            }
            
            dismiss()
        }
    }
}

#Preview {
    ModInstallerSheet(
        provider: .modrinth,
        mod: MinecraftCatalogProject(
            id: "1",
            name: "Preview",
            description: "Preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        ),
        modLoader: "",
        minecraftVersion: ""
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
}
