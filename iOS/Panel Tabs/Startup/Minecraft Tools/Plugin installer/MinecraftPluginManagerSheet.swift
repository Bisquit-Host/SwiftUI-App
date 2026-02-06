import SwiftUI

struct MinecraftPluginManagerSheet: View {
    @Environment(StartupVM.self) private var vm
    @Environment(\.openURL) private var openURL
    
    private let serverIdentifier: String
    
    init(serverIdentifier: String) {
        self.serverIdentifier = serverIdentifier
    }
    
    @State private var selectedProvider: MinecraftPluginProvider = .modrinth
    @State private var searchQuery = ""
    @State private var minecraftVersion = ""
    @State private var pluginLoader = ""
    @State private var page = 1
    @State private var selectedPlugin: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BillingSectionCard("Search") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Provider", selection: $selectedProvider) {
                                ForEach(MinecraftPluginProvider.allCases) { provider in
                                    Text(provider.name)
                                        .tag(provider)
                                }
                            }
                            
                            TextField("Search", text: $searchQuery)
                                .textFieldStyle(.roundedBorder)
                                .submitLabel(.search)
                                .onSubmit {
                                    reloadPlugins()
                                }
                            
                            TextField("Minecraft version (optional)", text: $minecraftVersion)
                                .textFieldStyle(.roundedBorder)
                            
                            TextField("Plugin loader (optional)", text: $pluginLoader)
                                .textFieldStyle(.roundedBorder)
                            
                            Button {
                                reloadPlugins()
                            } label: {
                                Label("Find plugins", systemImage: "magnifyingglass")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isLoadingMinecraftPlugins)
                        }
                    }
                    
                    if selectedProvider == .polymart {
                        BillingSectionCard("Polymart account") {
                            VStack(alignment: .leading, spacing: 12) {
                                if vm.isLoadingMinecraftPolymart {
                                    HStack(spacing: 10) {
                                        ProgressView()
                                        Text("Loading account state")
                                            .secondary()
                                    }
                                } else {
                                    Text(vm.isMinecraftPolymartLinked ? "Connected" : "Not connected")
                                        .subheadline(.semibold)
                                    
                                    Button {
                                        handlePolymartAction()
                                    } label: {
                                        Label(
                                            vm.isMinecraftPolymartLinked ? "Disconnect Polymart" : "Connect Polymart",
                                            systemImage: vm.isMinecraftPolymartLinked ? "link.badge.minus" : "link.badge.plus"
                                        )
                                    }
                                    .buttonStyle(.borderedProminent)
                                    .tint(vm.isMinecraftPolymartLinked ? .red : .blue)
                                }
                            }
                        }
                    }
                    
                    BillingSectionCard("Results") {
                        if vm.isLoadingMinecraftPlugins {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading plugins")
                                    .secondary()
                            }
                        } else if !vm.minecraftPluginManagerAvailable {
                            Text("Plugin manager is unavailable")
                                .secondary()
                        } else if vm.minecraftPlugins.isEmpty {
                            Text("No plugins found")
                                .secondary()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(vm.minecraftPlugins) { plugin in
                                    Button {
                                        selectedPlugin = plugin
                                    } label: {
                                        HStack(spacing: 12) {
                                            AsyncImage(url: plugin.iconURL) { image in
                                                image
                                                    .resizable()
                                                    .scaledToFill()
                                            } placeholder: {
                                                Image(systemName: "puzzlepiece.fill")
                                                    .secondary()
                                            }
                                            .frame(width: 28, height: 28)
                                            .clipShape(.rect(cornerRadius: 8))
                                            
                                            VStack(alignment: .leading, spacing: 2) {
                                                Text(plugin.name)
                                                    .subheadline(.semibold)
                                                    .foregroundStyle(.foreground)
                                                
                                                Text(plugin.description)
                                                    .caption()
                                                    .secondary()
                                                    .lineLimit(2)
                                            }
                                            
                                            Spacer()
                                            
                                            Image(systemName: "chevron.right")
                                                .secondary()
                                                .footnote()
                                        }
                                        .contentShape(.rect)
                                    }
                                    .buttonStyle(.plain)
                                }
                                
                                if vm.minecraftPluginsPagination.totalPages > 1 {
                                    HStack {
                                        Text("Page \(vm.minecraftPluginsPagination.currentPage) of \(vm.minecraftPluginsPagination.totalPages)")
                                            .footnote()
                                            .secondary()
                                        
                                        Spacer()
                                        
                                        Button("Previous") {
                                            movePage(-1)
                                        }
                                        .disabled(page <= 1 || vm.isLoadingMinecraftPlugins)
                                        
                                        Button("Next") {
                                            movePage(1)
                                        }
                                        .disabled(page >= vm.minecraftPluginsPagination.totalPages || vm.isLoadingMinecraftPlugins)
                                    }
                                }
                            }
                        }
                    }
                    
                    BillingSectionCard("Installed plugins") {
                        if vm.installedMinecraftPlugins.isEmpty {
                            Text("No installed plugins")
                                .secondary()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(vm.installedMinecraftPlugins) { plugin in
                                    HStack(spacing: 10) {
                                        AsyncImage(url: plugin.iconURL) { image in
                                            image
                                                .resizable()
                                                .scaledToFill()
                                        } placeholder: {
                                            Image(systemName: "puzzlepiece.fill")
                                                .secondary()
                                        }
                                        .frame(width: 22, height: 22)
                                        .clipShape(.rect(cornerRadius: 6))
                                        
                                        Text(plugin.fileName)
                                            .subheadline()
                                            .lineLimit(2)
                                        
                                        Spacer()
                                        
                                        if canUpdate(plugin) {
                                            Button("Update") {
                                                installPluginUpdate(plugin)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .controlSize(.small)
                                            .tint(.yellow)
                                            .disabled(vm.isInstallingMinecraftPlugin)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .scrollIndicators(.never)
            .navigationTitle("Plugin manager")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
#if !os(visionOS)
                ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            }
            .task {
                guard hasLoaded == false else {
                    return
                }
                
                hasLoaded = true
                vm.setMinecraftToolsServerId(serverIdentifier)
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
            _ = await vm.installMinecraftPlugin(
                provider: provider,
                pluginId: projectId,
                versionId: update.id
            )
        }
    }
}

#Preview {
    MinecraftPluginManagerSheet(serverIdentifier: "")
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
