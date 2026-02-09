import SwiftUI

struct ModpackInstallerResultsSection: View {
    @Environment(ModpackInstallerVM.self) private var vm
    
    @Binding var selectedModpack: MinecraftCatalogProject?
    
    let movePage: (Int) -> Void
    
    var body: some View {
        if !vm.modpackInstallerAvailable {
            Text("Modpack installer is unavailable")
                .secondary()
            
        } else if vm.modpacks.isEmpty && !vm.isLoadingModpacks {
            Text("No modpacks found")
                .secondary()
            
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.modpacks) { modpack in
                    Button {
                        selectedModpack = modpack
                    } label: {
                        ModpackInstallerResultCard(modpack)
                    }
                    .buttonStyle(.plain)
                    .minecraftProjectContextMenu(webPageURL: modpack.webPageURL)
                }
                
                if vm.modpacksPagination.totalPages > 1 {
                    MinecraftToolsPaginationView(
                        currentPage: vm.modpacksPagination.currentPage,
                        totalPages: vm.modpacksPagination.totalPages,
                        isLoading: vm.isLoadingModpacks,
                        onPrevious: { movePage(-1) },
                        onNext: { movePage(1) }
                    )
                }
            }
        }
    }
}
