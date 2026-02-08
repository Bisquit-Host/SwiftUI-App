import SwiftUI

struct ModpackInstallerResultsSection: View {
    @Environment(ModpackInstallerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    @Binding var selectedModpack: MinecraftCatalogProject?
    
    let movePage: (Int) -> Void
    
    var body: some View {
        BillingSectionCard("Results", showsBackground: false) {
            if !vm.modpackInstallerAvailable {
                Text("Modpack installer is unavailable")
                    .secondary()
                
            } else if vm.modpacks.isEmpty {
                Text("No modpacks found")
                    .secondary()
                
            } else {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(vm.modpacks) { modpack in
                        Button {
                            selectedModpack = modpack
                        } label: {
                            HStack(spacing: 12) {
                                MinecraftCatalogIcon(
                                    modpack.iconURL,
                                    placeholderSystemImage: "square.stack.3d.up.fill",
                                    size: 28,
                                    cornerRadius: 8
                                )
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(modpack.name)
                                        .subheadline(.semibold)
                                        .foregroundStyle(.foreground)
                                    
                                    Text(modpack.description)
                                        .caption()
                                        .secondary()
                                        .lineLimit(2)
                                    
                                    MinecraftCatalogProjectStatsView(project: modpack)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .secondary()
                                    .footnote()
                            }
                            .contentShape(.rect)
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
        .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
    }
}
