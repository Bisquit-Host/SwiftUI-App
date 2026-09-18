import SwiftUI
import Calagopus

struct PluginSearchSection: View {
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: PluginProvider
    @Binding var searchQuery: String
    @Binding var version: String
    @Binding var pluginLoader: String
    @Binding var selectedPlugin: MinecraftCatalogProject?
    
    let reloadPlugins: () -> Void
    let movePage: (Int) -> Void
    let handlePolymartAction: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                BillingSectionCard(showsBackground: false) {
                    TextField("Search", text: $searchQuery)
                        .panelSearchField()
                        .submitLabel(.search)
                        .onSubmit(reloadPlugins)
                    
                    PluginProviderPicker($selectedProvider)
                    PluginMinecraftVersionPicker(version: $version)
                    PluginLoaderPicker(pluginLoader: $pluginLoader)
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                if selectedProvider == .polymart {
                    PluginPolymartSection(handlePolymartAction: handlePolymartAction)
                        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                }
                
                PluginSearchResultsSection(selectedPlugin: $selectedPlugin, movePage: movePage)
            }
        }
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .frame(maxWidth: .infinity)
    }
}

#Preview {
    PluginSearchSection(
        selectedProvider: .constant(.modrinth),
        searchQuery: .constant(""),
        version: .constant(""),
        pluginLoader: .constant(""),
        selectedPlugin: .constant(nil),
        reloadPlugins: {},
        movePage: { _ in },
        handlePolymartAction: {}
    )
    .darkSchemePreferred()
    .environment(PluginInstallerVM(""))
    .environmentObject(ValueStore())
}
