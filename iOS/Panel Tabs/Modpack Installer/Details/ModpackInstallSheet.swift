import SwiftUI
import Calagopus
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
    @State private var alertInstall = false
    @State private var showSafari = false
    @State private var sheetFTBMods = false
    @State private var isLoadingFTBMods = false
    @State private var ftbMods: [FTBModpackVersionMod] = []
    
    var body: some View {
        ScrollView {
            BillingSectionCard(showsBackground: false) {
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
                    
                    Toggle("Delete server files", isOn: $deleteServerFiles)
                        .panelSearchField(showIcon: false)
                        
                    Button("Install", role: .confirm) {
                        alertInstall = true
                    }
                    .semibold()
                    .buttonStyle(.borderedProminent)
                    .buttonSizing(.flexible)
                    .buttonBorderShape(.roundedRectangle(radius: 12))
                    .disabled(selectedVersionId == nil || vm.isInstallingModpack)
                }
            }
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            
            if !modpack.description.isEmpty {
                MinecraftCatalogDescriptionSection(modpack)
            }
            
            FTBModpackDetailsView(
                modpack,
                canOpenModList: canOpenFTBModList,
                openModList: openFTBModListAction
            )
            
            if provider == .modrinth {
                ModrinthProjectLinksSection(modpack)
            }
        }
        .navigationTitle(modpack.name)
        .toolbarTitleDisplayMode(.inlineLarge)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .safariCover($showSafari, url: modpackWebPageURL)
        .sheet($sheetFTBMods) {
            NavigationStack {
                FTBModpackModsSheet(mods: ftbMods, isLoading: isLoadingFTBMods)
            }
        }
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
        }
        .task {
            await loadVersions()
        }
        .alert("Install selected version", isPresented: $alertInstall) {
            Button("Install", role: .confirm, action: install)
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
    
    private var canOpenFTBModList: Bool {
        provider == .feedthebeast && selectedVersionId != nil && isLoadingFTBMods == false
    }
    
    private var openFTBModListAction: (() -> Void)? {
        guard provider == .feedthebeast else {
            return nil
        }
        
        return {
            openFTBModList()
        }
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
    
    private func openFTBModList() {
        guard provider == .feedthebeast, let selectedVersionId else {
            return
        }
        
        ftbMods = []
        sheetFTBMods = true
        
        Task {
            await loadFTBMods(versionId: selectedVersionId)
        }
    }
    
    private func loadFTBMods(versionId: String) async {
        isLoadingFTBMods = true
        ftbMods = await vm.fetchFTBModpackVersionMods(modpackId: modpack.id, versionId: versionId)
        isLoadingFTBMods = false
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
