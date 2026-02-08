import SwiftUI

struct PluginSearchTab: View {
    @Environment(PluginInstallerVM.self) private var vm
    
    @Binding var selectedProvider: PluginProvider
    @Binding var searchQuery: String
    @Binding var version: String
    @Binding var pluginLoader: String
    @Binding var page: Int
    @Binding var selectedPlugin: MinecraftCatalogProject?
    
    let reloadPlugins: () -> Void
    let movePage: (Int) -> Void
    let handlePolymartAction: () -> Void
    
    private let pluginLoaders = [
        "paper", "spigot", "bukkit", "purpur", "folia",
        "velocity", "waterfall", "bungeecord", "sponge"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Search") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Provider", selection: $selectedProvider) {
                            ForEach(PluginProvider.allCases) {
                                Text($0.name)
                                    .tag($0)
                            }
                        }
                        .tint(.primary)
                        
                        TextField("Search", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                            .onSubmit {
                                reloadPlugins()
                            }
                        
                        HStack {
                            Text("Minecraft version")
                            
                            Spacer()
                            
                            Picker("Minecraft version", selection: $version) {
                                Text("Any")
                                    .tag("")
                                
                                ForEach(vm.versionOptions, id: \.self) { version in
                                    Text(version)
                                        .tag(version)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                        
                        HStack {
                            Text("Plugin loader")
                            
                            Spacer()
                            
                            Picker("Plugin loader", selection: $pluginLoader) {
                                Text("Any")
                                    .tag("")
                                
                                ForEach(displayedPluginLoaders, id: \.self) { loader in
                                    Text(loader.capitalized)
                                        .tag(loader)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                        
                        Button("Find plugins", systemImage: "magnifyingglass", action: reloadPlugins)
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isLoadingPlugins)
                    }
                }
                
                if selectedProvider == .polymart {
                    BillingSectionCard("Polymart account") {
                        VStack(alignment: .leading, spacing: 12) {
                            if vm.isLoadingPolymart {
                                HStack(spacing: 10) {
                                    ProgressView()
                                    
                                    Text("Loading account state")
                                        .secondary()
                                }
                            } else {
                                Text(vm.isPolymartLinked ? "Connected" : "Not connected")
                                    .subheadline(.semibold)
                                
                                Button {
                                    handlePolymartAction()
                                } label: {
                                    Label(
                                        vm.isPolymartLinked ? "Disconnect Polymart" : "Connect Polymart",
                                        systemImage: vm.isPolymartLinked ? "link.badge.minus" : "link.badge.plus"
                                    )
                                }
                                .buttonStyle(.borderedProminent)
                                .tint(vm.isPolymartLinked ? .red : .blue)
                            }
                        }
                    }
                }
                
                BillingSectionCard("Results") {
                    if !vm.pluginManagerAvailable {
                        Text("Plugin manager is unavailable")
                            .secondary()
                        
                    } else if vm.plugins.isEmpty {
                        Text("No plugins found")
                            .secondary()
                        
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.plugins) { plugin in
                                Button {
                                    selectedPlugin = plugin
                                } label: {
                                    HStack(spacing: 12) {
                                        MinecraftCatalogIcon(
                                            plugin.iconURL,
                                            placeholderSystemImage: "puzzlepiece.fill",
                                            size: 28,
                                            cornerRadius: 8
                                        )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(plugin.name)
                                                .subheadline(.semibold)
                                                .foregroundStyle(.foreground)
                                            
                                            Text(plugin.description)
                                                .caption()
                                                .secondary()
                                                .lineLimit(2)

                                            MinecraftCatalogProjectStatsView(project: plugin)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .secondary()
                                            .footnote()
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .minecraftProjectContextMenu(webPageURL: plugin.webPageURL)
                            }
                            
                            if vm.pluginsPagination.totalPages > 1 {
                                MinecraftToolsPaginationView(
                                    currentPage: vm.pluginsPagination.currentPage,
                                    totalPages: vm.pluginsPagination.totalPages,
                                    isLoading: vm.isLoadingPlugins,
                                    onPrevious: { movePage(-1) },
                                    onNext: { movePage(1) }
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
    }
    
    private var displayedPluginLoaders: [String] {
        if vm.pluginLoaderOptions.isEmpty {
            return pluginLoaders
        }
        
        return vm.pluginLoaderOptions
    }
}

#Preview {
    PluginSearchTab(
        selectedProvider: .constant(.modrinth),
        searchQuery: .constant(""),
        version: .constant(""),
        pluginLoader: .constant(""),
        page: .constant(1),
        selectedPlugin: .constant(nil),
        reloadPlugins: {},
        movePage: { _ in },
        handlePolymartAction: {}
    )
    .darkSchemePreferred()
    .environment(PluginInstallerVM(""))
}
