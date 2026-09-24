import SwiftUI
import Calagopus

struct ModManagerTab: View {
    @Environment(ModInstallerVM.self) private var vm
    @EnvironmentObject private var valueStore: ValueStore
    
    private let serverIdentifier: String
    private let showsDismissButton: Bool
    
    init(_ serverIdentifier: String, showsDismissButton: Bool = true) {
        self.serverIdentifier = serverIdentifier
        self.showsDismissButton = showsDismissButton
    }
    
    @State private var selectedMod: MinecraftCatalogProject?
    @State private var installedModsPresented = false
    
    var body: some View {
        @Bindable var vm = vm

        ModManagerSearchSection(
            selectedProvider: $vm.selectedProvider,
            searchQuery: $vm.searchQuery,
            version: $vm.version,
            modLoader: $vm.modLoader,
            selectedMod: $selectedMod,
            hasFinishedInitialLoad: vm.hasFinishedInitialLoad,
            reloadMods: vm.reloadMods,
            movePage: vm.movePage
        )
        .panelNavigationTitle("Mods")
        .refreshable {
            await vm.refreshSearchTab()
        }
        .toolbar {
            PanelToolbarItem(placement: .primaryAction) {
                Button("Installed Mods", systemImage: "square.and.arrow.down", action: { installedModsPresented = true })
                    .badge(vm.availableUpdateCount)
            }
            
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
        }
        .task {
            await vm.loadManager(serverIdentifier: serverIdentifier, storedProvider: valueStore.panelModInstallerProvider)
        }
        .onChange(of: vm.selectedProvider) {
            valueStore.panelModInstallerProvider = vm.selectedProvider.rawValue
        }
        .sheet(item: $selectedMod) { mod in
            NavigationStack {
                ModInstallerSheet(
                    provider: vm.selectedProvider,
                    mod: mod,
                    modLoader: vm.modLoader,
                    version: vm.version
                )
            }
            .environment(vm)
        }
        .navigationDestination(isPresented: $installedModsPresented) {
            InstalledModList(canUpdate: vm.canUpdate, installUpdate: vm.installUpdate)
                .environment(vm)
                .refreshableTask {
                    await vm.refreshInstalledTab()
                }
        }
    }
    
}

#Preview {
    ModManagerTab("")
        .darkSchemePreferred()
        .environment(ModInstallerVM(""))
        .environmentObject(ValueStore())
}
