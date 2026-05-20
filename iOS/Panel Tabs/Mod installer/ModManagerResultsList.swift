import SwiftUI

struct ModManagerResultsList: View {
    @Environment(ModInstallerVM.self) private var vm
    
    @Binding var selectedMod: MinecraftCatalogProject?
    
    let movePage: (Int) -> Void
    
    var body: some View {
        if !vm.modManagerAvailable {
            Text("Mods are unavailable")
                .secondary()
            
        } else if vm.mods.isEmpty && !vm.isLoadingMods {
            Text("No mods found")
                .secondary()
            
        } else {
            VStack(alignment: .leading, spacing: 8) {
                ForEach(vm.mods) { mod in
                    Button {
                        selectedMod = mod
                    } label: {
                        ModManagerResultCard(mod)
                    }
                    .buttonStyle(.plain)
                    .minecraftProjectContextMenu(webPageURL: mod.webPageURL)
                }
                
                if vm.modsPagination.totalPages > 1 {
                    MinecraftToolsPagination(
                        currentPage: vm.modsPagination.currentPage,
                        totalPages: vm.modsPagination.totalPages,
                        isLoading: vm.isLoadingMods,
                        onPrevious: { movePage(-1) },
                        onNext: { movePage(1) }
                    )
                }
            }
        }
    }
}

#Preview {
    ModManagerResultsList(selectedMod: .constant(nil), movePage: { _ in })
        .padding()
        .environment(ModInstallerVM(""))
        .environmentObject(ValueStore())
}
