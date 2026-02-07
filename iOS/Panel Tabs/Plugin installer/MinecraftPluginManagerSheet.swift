import SwiftUI

struct MinecraftPluginManagerSheet: View {
    @Environment(MinecraftPluginInstallerVM.self) private var vm
    @Environment(\.openURL) private var openURL
    
    private let serverIdentifier: String
    
    var showsDismissButton: Bool
    
    init(
        _ serverIdentifier: String,
        showsDismissButton: Bool = true
    ) {
        self.serverIdentifier = serverIdentifier
        self.showsDismissButton = showsDismissButton
    }
    
    @AppStorage("minecraft_plugin_manager_selected_tab") private var selectedTab = MinecraftPluginManagerTab.search.rawValue
    @State private var selectedProvider: MinecraftPluginProvider = .modrinth
    @State private var searchQuery = ""
    @State private var minecraftVersion = ""
    @State private var pluginLoader = ""
    @State private var page = 1
    @State private var selectedPlugin: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        TabView(selection: $selectedTab) {
            MinecraftPluginSearchTab(
                selectedProvider: $selectedProvider,
                searchQuery: $searchQuery,
                minecraftVersion: $minecraftVersion,
                pluginLoader: $pluginLoader,
                page: $page,
                selectedPlugin: $selectedPlugin,
                reloadPlugins: reloadPlugins,
                movePage: movePage,
                handlePolymartAction: handlePolymartAction
            )
            .tag(MinecraftPluginManagerTab.search.rawValue)
            .tabItem {
                Label("Search", systemImage: "magnifyingglass")
            }
            
            MinecraftPluginInstalledTab(
                canUpdate: canUpdate,
                installPluginUpdate: installPluginUpdate
            )
            .tag(MinecraftPluginManagerTab.installed.rawValue)
            .tabItem {
                Label("Installed", systemImage: "square.stack.3d.down.right")
            }
        }
        .navigationTitle("Plugin manager")
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
            vm.setServerId(serverIdentifier)
            await loadPlugins()
            await vm.fetchInstalledMinecraftPlugins()
            await vm.fetchMinecraftPolymartLinkStatus()
        }
        .onChange(of: selectedProvider) { _, newProvider in
            if newProvider == .polymart {
                Task {
                    await vm.fetchMinecraftPolymartLinkStatus()
                }
            }
            
            reloadPlugins()
        }
        .sheet(item: $selectedPlugin) { plugin in
            NavigationStack {
                MinecraftPluginInstallSheet(
                    provider: selectedProvider,
                    plugin: plugin,
                    pluginLoader: pluginLoader,
                    minecraftVersion: minecraftVersion
                )
                .environment(vm)
            }
        }
    }
    
    private func loadPlugins() async {
        await vm.fetchMinecraftPlugins(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery,
            minecraftVersion: minecraftVersion,
            pluginLoader: pluginLoader
        )
    }
    
    private func reloadPlugins() {
        page = 1
        
        Task {
            await loadPlugins()
            await vm.fetchInstalledMinecraftPlugins()
        }
    }
    
    private func movePage(_ change: Int) {
        let nextPage = max(1, page + change)
        page = nextPage
        
        Task {
            await loadPlugins()
        }
    }
    
    private func handlePolymartAction() {
        Task {
            if vm.isMinecraftPolymartLinked {
                await vm.disconnectMinecraftPolymart()
                return
            }
            
            guard let link = await vm.connectMinecraftPolymart() else {
                return
            }
            
            openURL(link)
        }
    }
    
    private func canUpdate(_ plugin: MinecraftInstalledProject) -> Bool {
        plugin.update != nil
        && plugin.projectId != nil
        && MinecraftPluginProvider(providerValue: plugin.provider) != nil
    }
    
    private func installPluginUpdate(_ plugin: MinecraftInstalledProject) {
        guard
            let update = plugin.update,
            let projectId = plugin.projectId,
            let provider = MinecraftPluginProvider(providerValue: plugin.provider)
        else {
            return
        }
        
        Task {
            let installed = await vm.installMinecraftPlugin(
                provider: provider,
                pluginId: projectId,
                versionId: update.id
            )
            
            guard installed else {
                return
            }
            
            await vm.fetchInstalledMinecraftPlugins()
            try? await Task.sleep(nanoseconds: 500_000_000)
            await vm.fetchInstalledMinecraftPlugins()
            await loadPlugins()
        }
    }
}

#Preview {
    MinecraftPluginManagerSheet("")
        .darkSchemePreferred()
        .environment(MinecraftPluginInstallerVM(""))
}
