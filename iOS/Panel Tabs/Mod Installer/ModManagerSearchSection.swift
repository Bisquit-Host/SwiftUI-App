import SwiftUI
import Calagopus

struct ModManagerSearchSection: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: ModManagerProvider
    @Binding var searchQuery: String
    @Binding var version: String
    @Binding var modLoader: String
    @Binding var page: Int
    @Binding var selectedMod: MinecraftCatalogProject?
    
    let hasFinishedInitialLoad: Bool
    let reloadMods: () -> Void
    let movePage: (Int) -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                BillingSectionCard(showsBackground: false) {
                    ModManagerSearchField(searchQuery: $searchQuery, reloadMods: reloadMods)
                    ModManagerProviderPicker($selectedProvider)
                    ModManagerMinecraftVersionPicker($version)
                    ModManagerLoaderPicker($modLoader)
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                ModManagerResultsList(
                    selectedMod: $selectedMod,
                    hasFinishedInitialLoad: hasFinishedInitialLoad,
                    movePage: movePage
                )
            }
            .animation(.default, value: vm.mods)
            .animation(.default, value: vm.isLoadingMods)
        }
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .background(BackgroundImage())
    }
}

#Preview {
    ModManagerSearchSection(
        selectedProvider: .constant(.modrinth),
        searchQuery: .constant(""),
        version: .constant(""),
        modLoader: .constant(""),
        page: .constant(1),
        selectedMod: .constant(nil),
        hasFinishedInitialLoad: true,
        reloadMods: {},
        movePage: { _ in }
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
    .environmentObject(ValueStore())
}
