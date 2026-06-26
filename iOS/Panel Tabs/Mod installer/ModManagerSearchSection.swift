import Calagopus
import SwiftUI

struct ModManagerSearchSection: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedProvider: ModManagerProvider
    @Binding var searchQuery: String
    @Binding var version: String
    @Binding var modLoader: String
    @Binding var page: Int
    @Binding var selectedMod: MinecraftCatalogProject?
    
    let reloadMods: () -> Void
    let movePage: (Int) -> Void
    let openInstalledMods: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard(showsBackground: false) {
                    Button(action: openInstalledMods) {
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
                        ModManagerSearchField(searchQuery: $searchQuery, reloadMods: reloadMods)
                        
                        ModManagerProviderPicker($selectedProvider)
                        ModManagerMinecraftVersionPicker($version)
                        ModManagerLoaderPicker($modLoader)
                    }
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                ModManagerResultsList(selectedMod: $selectedMod, movePage: movePage)
            }
            .animation(.default, value: vm.mods)
            .animation(.default, value: vm.isLoadingMods)
            .padding()
        }
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
        reloadMods: {},
        movePage: { _ in },
        openInstalledMods: {}
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
    .environmentObject(ValueStore())
}
