import SwiftUI

struct PluginManagerTab: View {
    @Environment(PluginInstallerVM.self) private var vm
    @EnvironmentObject private var valueStore: ValueStore
    @Environment(\.openURL) private var openURL
    
    private let serverIdentifier: String
    private let showsDismissButton: Bool
    
    init(_ serverIdentifier: String, showsDismissButton: Bool = true) {
        self.serverIdentifier = serverIdentifier
        self.showsDismissButton = showsDismissButton
    }
    
    @State private var selectedProvider: PluginProvider = .modrinth
    @State private var searchQuery = ""
    @State private var version = ""
    @State private var pluginLoader = ""
    @State private var page = 1
    @State private var selectedPlugin: MinecraftCatalogProject?
    @State private var installedPluginsPresented = false
    @State private var hasLoaded = false
    
    var body: some View {
        PluginSearchSection(
            selectedProvider: $selectedProvider,
            searchQuery: $searchQuery,
            version: $version,
            pluginLoader: $pluginLoader,
            page: $page,
            selectedPlugin: $selectedPlugin,
            reloadPlugins: reloadPlugins,
            movePage: movePage,
            openInstalledPlugins: openInstalledPlugins,
            handlePolymartAction: handlePolymartAction
        )
        .navigationTitle("Plugins")
        .background(BackgroundImage())
        .refreshable {
            await refreshSearchTab()
        }
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
        }
        .task {
            guard hasLoaded == false else { return }
            
            hasLoaded = true
            
            if let storedProvider = PluginProvider(rawValue: valueStore.panelPluginInstallerProvider) {
                selectedProvider = storedProvider
            }
            
            vm.setServerId(serverIdentifier)
            
            await loadPlugins()
            await vm.fetchInstalledMinecraftPlugins()
            await vm.fetchMinecraftPolymartLinkStatus()
        }
        .onChange(of: selectedProvider) { _, newProvider in
            valueStore.panelPluginInstallerProvider
            = newProvider.rawValue
            
            guard hasLoaded else {
                return
            }
            
            if newProvider == .polymart {
                Task {
                    await vm.fetchMinecraftPolymartLinkStatus()
                }
            }
            
            reloadPlugins()
        }
        .sheet(item: $selectedPlugin) { plugin in
            NavigationStack {
                PluginInstallSheet(
                    provider: selectedProvider,
                    plugin: plugin,
                    pluginLoader: pluginLoader,
                    version: version
                )
                .environment(vm)
            }
        }
        .navigationDestination(isPresented: $installedPluginsPresented) {
            InstalledPluginList(canUpdate: canUpdate, installPluginUpdate: installPluginUpdate)
                .navigationTitle("Installed Plugins")
                .toolbarTitleDisplayMode(.inline)
                .refreshable {
                    await refreshInstalledTab()
                }
                .environment(vm)
        }
    }
    
    private func loadPlugins(forceRefresh: Bool = false) async {
        await vm.fetchMinecraftPlugins(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery,
            version: version,
            pluginLoader: pluginLoader,
            forceRefresh: forceRefresh
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
    
    private func openInstalledPlugins() {
        installedPluginsPresented = true
    }
    
    private func refreshSearchTab() async {
        await loadPlugins(forceRefresh: true)
        await vm.fetchInstalledMinecraftPlugins()
        
        if selectedProvider == .polymart {
            await vm.fetchMinecraftPolymartLinkStatus()
        }
    }
    
    private func refreshInstalledTab() async {
        await vm.fetchInstalledMinecraftPlugins()
        await loadPlugins(forceRefresh: true)
    }
    
    private func handlePolymartAction() {
        Task {
            if vm.isPolymartLinked {
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
        && PluginProvider(providerValue: plugin.provider) != nil
    }
    
    private func installPluginUpdate(_ plugin: MinecraftInstalledProject) {
        guard
            let update = plugin.update,
            let projectId = plugin.projectId,
            let provider = PluginProvider(providerValue: plugin.provider)
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
            try? await Task.sleep(for: .milliseconds(500))
            
            await vm.fetchInstalledMinecraftPlugins()
            await loadPlugins()
        }
    }
}

#Preview {
    PluginManagerTab("")
        .darkSchemePreferred()
        .environment(PluginInstallerVM(""))
        .environmentObject(ValueStore())
}
