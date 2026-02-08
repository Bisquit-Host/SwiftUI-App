import SwiftUI

struct ModManagerSheet: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var valueStore: ValueStore
    
    private let serverIdentifier: String
    private let showsDismissButton: Bool
    
    init(_ serverIdentifier: String, showsDismissButton: Bool = true) {
        self.serverIdentifier = serverIdentifier
        self.showsDismissButton = showsDismissButton
    }
    
    @AppStorage("minecraft_mod_manager_selected_tab") private var selectedTab = ModManagerTab.search.rawValue
    @State private var selectedProvider: ModManagerProvider = .modrinth
    @State private var searchQuery = ""
    @State private var minecraftVersion = ""
    @State private var modLoader = ""
    @State private var page = 1
    @State private var selectedMod: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Tab("Search", systemImage: "magnifyingglass", value: ModManagerTab.search.rawValue) {
                ModManagerSearchSection(
                    selectedProvider: $selectedProvider,
                    searchQuery: $searchQuery,
                    minecraftVersion: $minecraftVersion,
                    modLoader: $modLoader,
                    page: $page,
                    selectedMod: $selectedMod,
                    reloadMods: reloadMods,
                    movePage: movePage
                )
                .refreshable {
                    await refreshSearchTab()
                }
            }
            
            Tab("Installed", systemImage: "square.stack.3d.down.right", value: ModManagerTab.installed.rawValue) {
                ModManagerInstalledSection(canUpdate: canUpdate, installModUpdate: installModUpdate)
                    .refreshable {
                        await refreshInstalledTab()
                    }
            }
        }
        .navigationTitle("Mod manager")
        .background(BackgroundImage())
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
        }
        .task {
            guard hasLoaded == false else {
                return
            }
            
            hasLoaded = true
            if let storedProvider = ModManagerProvider(rawValue: valueStore.panelModInstallerProvider) {
                selectedProvider = storedProvider
            }
            vm.setServerId(serverIdentifier)
            
            await loadMods()
            await vm.fetchInstalledMinecraftMods()
        }
        .onChange(of: selectedProvider) { _, newProvider in
            valueStore.panelModInstallerProvider = newProvider.rawValue
            guard hasLoaded else {
                return
            }
            
            reloadMods()
        }
        .sheet(item: $selectedMod) { mod in
            NavigationStack {
                ModInstallerSheet(
                    provider: selectedProvider,
                    mod: mod,
                    modLoader: modLoader,
                    minecraftVersion: minecraftVersion
                )
                .environment(vm)
            }
        }
    }
    
    private func loadMods(forceRefresh: Bool = false) async {
        await vm.fetchMinecraftMods(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery,
            minecraftVersion: minecraftVersion,
            modLoader: modLoader,
            forceRefresh: forceRefresh
        )
    }
    
    private func reloadMods() {
        page = 1
        
        Task {
            await loadMods()
            await vm.fetchInstalledMinecraftMods()
        }
    }
    
    private func movePage(_ change: Int) {
        let nextPage = max(1, page + change)
        page = nextPage
        
        Task {
            await loadMods()
        }
    }

    private func refreshSearchTab() async {
        await loadMods(forceRefresh: true)
        await vm.fetchInstalledMinecraftMods()
    }

    private func refreshInstalledTab() async {
        await vm.fetchInstalledMinecraftMods()
        await loadMods(forceRefresh: true)
    }
    
    private func canUpdate(_ mod: MinecraftInstalledProject) -> Bool {
        mod.update != nil
        && mod.projectId != nil
        && ModManagerProvider(providerValue: mod.provider) != nil
    }
    
    private func installModUpdate(_ mod: MinecraftInstalledProject) {
        guard
            let update = mod.update,
            let projectId = mod.projectId,
            let provider = ModManagerProvider(providerValue: mod.provider)
        else {
            return
        }
        
        Task {
            let installed = await vm.installMinecraftMod(
                provider: provider,
                modId: projectId,
                versionId: update.id
            )
            
            guard installed else {
                return
            }
            
            await vm.fetchInstalledMinecraftMods()
            try? await Task.sleep(nanoseconds: 500_000_000)
            await vm.fetchInstalledMinecraftMods()
            await loadMods()
        }
    }
}

#Preview {
    ModManagerSheet("")
        .darkSchemePreferred()
        .environment(ModInstallerVM(""))
        .environmentObject(ValueStore())
}
