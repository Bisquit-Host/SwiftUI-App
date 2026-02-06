import SwiftUI

struct MinecraftModManagerSheet: View {
    @Environment(StartupVM.self) private var vm
    
    private let serverIdentifier: String
    
    init(serverIdentifier: String) {
        self.serverIdentifier = serverIdentifier
    }
    
    @State private var selectedTab: MinecraftModManagerTab = .search
    @State private var selectedProvider: MinecraftModProvider = .modrinth
    @State private var searchQuery = ""
    @State private var minecraftVersion = ""
    @State private var modLoader = ""
    @State private var page = 1
    @State private var selectedMod: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MinecraftModSearchTab(
                selectedProvider: $selectedProvider,
                searchQuery: $searchQuery,
                minecraftVersion: $minecraftVersion,
                modLoader: $modLoader,
                page: $page,
                selectedMod: $selectedMod,
                reloadMods: reloadMods,
                movePage: movePage
            )
            .tag(MinecraftModManagerTab.search)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            MinecraftModInstalledTab(
                canUpdate: canUpdate,
                installModUpdate: installModUpdate
            )
            .tag(MinecraftModManagerTab.installed)
            .tabItem {
                Label("Installed", systemImage: "square.stack.3d.down.right")
            }
        }
        .navigationTitle("Mod manager")
        .toolbar {
            DismissButton()
        }
        .task {
            guard hasLoaded == false else { return }
            
            hasLoaded = true
            vm.setMinecraftToolsServerId(serverIdentifier)
            
            await loadMods()
            await vm.fetchInstalledMinecraftMods()
        }
        .onChange(of: selectedProvider) {
            reloadMods()
        }
        .sheet(item: $selectedMod) { mod in
            NavigationStack {
                MinecraftModInstallSheet(
                    provider: selectedProvider,
                    mod: mod,
                    modLoader: modLoader,
                    minecraftVersion: minecraftVersion
                )
                .environment(vm)
            }
        }
    }
    
    private func loadMods() async {
        await vm.fetchMinecraftMods(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery,
            minecraftVersion: minecraftVersion,
            modLoader: modLoader
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
    
    private func canUpdate(_ mod: MinecraftInstalledProject) -> Bool {
        mod.update != nil
        && mod.projectId != nil
        && MinecraftModProvider(providerValue: mod.provider) != nil
    }
    
    private func installModUpdate(_ mod: MinecraftInstalledProject) {
        guard
            let update = mod.update,
            let projectId = mod.projectId,
            let provider = MinecraftModProvider(providerValue: mod.provider)
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
    MinecraftModManagerSheet(serverIdentifier: "")
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
