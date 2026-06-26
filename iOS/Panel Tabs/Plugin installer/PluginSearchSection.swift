import SwiftUI

struct PluginSearchSection: View {
    @Environment(PluginInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: PluginProvider
    @Binding var searchQuery: String
    @Binding var version: String
    @Binding var pluginLoader: String
    @Binding var page: Int
    @Binding var selectedPlugin: MinecraftCatalogProject?
    
    let reloadPlugins: () -> Void
    let movePage: (Int) -> Void
    let openInstalledPlugins: () -> Void
    let handlePolymartAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard(showsBackground: false) {
                    Button(action: openInstalledPlugins) {
                        HStack {
                            Label("Installed", systemImage: "square.stack.3d.down.right")
                            
                            Spacer()
                            
                            Image(systemName: "chevron.right")
                                .secondary()
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(.rect)
                    }
                    .buttonStyle(.plain)
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                BillingSectionCard(showsBackground: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        TextField("Search", text: $searchQuery)
                            .panelSearchField()
                            .submitLabel(.search)
                            .onSubmit(reloadPlugins)
                        
                        PluginProviderPicker($selectedProvider)
                        PluginMinecraftVersionPicker(version: $version, versionOptions: vm.versionOptions)
                        PluginLoaderPicker(pluginLoader: $pluginLoader, pluginLoaderOptions: vm.pluginLoaderOptions)
                    }
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                if selectedProvider == .polymart {
                    PluginPolymartSection(
                        isLoadingPolymart: vm.isLoadingPolymart,
                        isPolymartLinked: vm.isPolymartLinked,
                        handlePolymartAction: handlePolymartAction
                    )
                    .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                }
                
                PluginSearchResultsSection(
                    pluginManagerAvailable: vm.pluginManagerAvailable,
                    plugins: vm.plugins,
                    pagination: vm.pluginsPagination,
                    isLoadingPlugins: vm.isLoadingPlugins,
                    selectedPlugin: $selectedPlugin,
                    movePage: movePage
                )
            }
            .padding()
        }
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
    }
}

#Preview {
    PluginSearchSection(
        selectedProvider: .constant(.modrinth),
        searchQuery: .constant(""),
        version: .constant(""),
        pluginLoader: .constant(""),
        page: .constant(1),
        selectedPlugin: .constant(nil),
        reloadPlugins: {},
        movePage: { _ in },
        openInstalledPlugins: {},
        handlePolymartAction: {}
    )
    .darkSchemePreferred()
    .environment(PluginInstallerVM(""))
    .environmentObject(ValueStore())
}
