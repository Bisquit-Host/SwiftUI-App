import SwiftUI
import SafariCover

struct ModpackInstallSheet: View {
    @Environment(ModpackInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    private let provider: ModpackProvider
    private let modpack: MinecraftCatalogProject
    
    init(provider: ModpackProvider, modpack: MinecraftCatalogProject) {
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
                BillingSectionCard(showsBackground: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        if isLoadingVersions {
                            HStack(spacing: 10) {
                                ProgressView()
                                
                                Text("Loading versions")
                                    .secondary()
                            }
                        } else if vm.modpackVersions.isEmpty {
                            Text("No versions found")
                                .secondary()
                        } else {
                            Picker("Version", selection: $selectedVersionId) {
                                ForEach(vm.modpackVersions) {
                                    Text($0.name)
                                        .tag(Optional($0.id))
                                }
                            }
                            
                            Toggle("Delete server files first", isOn: $deleteServerFiles)
                            
                            Button("Install", role: .confirm) {
                                askForInstall = true
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedVersionId == nil || vm.isInstallingModpack)
                        }
                    }
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                FTBModpackDetailsView(modpack)
                MinecraftCatalogDescriptionSectionView(modpack)
                ModrinthProjectLinksSection(project: modpack, isEnabled: provider == .modrinth)
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle(modpack.name)
        .safariCover($showSafari, url: modpackWebPageURL)
        .toolbar {
            if hasModpackWebPageURL {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Open in browser", systemImage: "safari") {
                        showSafari = true
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: modpackWebPageURL)
                }
            }
            
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
        
        selectedVersionId = vm.modpackVersions.first?.id
        isLoadingVersions = false
    }
    
    private var modpackWebPageURL: String {
        modpack.webPageURL ?? ""
    }
    
    private var hasModpackWebPageURL: Bool {
        modpack.webPageURL != nil
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
            
            guard installed else { return }
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
    .environmentObject(ValueStore())
}
