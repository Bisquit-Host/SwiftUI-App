import SwiftUI
import Calagopus

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
    
    @State private var selectedPlugin: MinecraftCatalogProject?
    @State private var installedPluginsPresented = false
    
    var body: some View {
        @Bindable var vm = vm

        PluginSearchSection(
            selectedProvider: $vm.selectedProvider,
            searchQuery: $vm.searchQuery,
            version: $vm.version,
            pluginLoader: $vm.pluginLoader,
            selectedPlugin: $selectedPlugin,
            reloadPlugins: vm.reloadPlugins,
            movePage: vm.movePage,
            handlePolymartAction: {
                Task {
                    if let url = await vm.performPolymartAction() {
                        openURL(url)
                    }
                }
            }
        )
        .panelNavigationTitle("Plugins")
        .refreshable {
            await vm.refreshSearchTab()
        }
        .toolbar {
            PanelToolbarItem(placement: .primaryAction) {
                
                Button("Installed Plugins", systemImage: "square.and.arrow.down") {
                    installedPluginsPresented = true
                }
            }
            
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
        }
        .task {
            await vm.loadManager(serverIdentifier: serverIdentifier, storedProvider: valueStore.panelPluginInstallerProvider)
        }
        .onChange(of: vm.selectedProvider) {
            valueStore.panelPluginInstallerProvider = vm.selectedProvider.rawValue
        }
        .sheet(item: $selectedPlugin) { plugin in
            NavigationStack {
                PluginInstallSheet(
                    provider: vm.selectedProvider,
                    plugin: plugin,
                    pluginLoader: vm.pluginLoader,
                    version: vm.version
                )
            }
            .environment(vm)
        }
        .navigationDestination(isPresented: $installedPluginsPresented) {
            InstalledPluginList(canUpdate: vm.canUpdate, installUpdate: vm.installUpdate)
                .environment(vm)
                .refreshableTask {
                    await vm.refreshInstalledTab()
                }
        }
    }
    
}

#Preview {
    PluginManagerTab("")
        .darkSchemePreferred()
        .environment(PluginInstallerVM(""))
        .environmentObject(ValueStore())
}
