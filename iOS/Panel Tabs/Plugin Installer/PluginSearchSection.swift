import SwiftUI
import Calagopus

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
            VStack(alignment: .leading, spacing: 12) {
                BillingSectionCard(showsBackground: false) {
                    Button(action: openInstalledPlugins) {
                        HStack {
                            Label("Installed", systemImage: "square.and.arrow.down")
                            
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
