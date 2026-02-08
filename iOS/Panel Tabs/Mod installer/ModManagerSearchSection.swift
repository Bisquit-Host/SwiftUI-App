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
    
    private let modLoaders = [
        "fabric", "forge", "neoforge", "quilt"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Search", showsBackground: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Provider", selection: $selectedProvider) {
                            ForEach(ModManagerProvider.allCases) {
                                Text($0.name)
                                    .tag($0)
                            }
                        }
                        .pickerStyle(.segmented)
                        .tint(.primary)
                        
                        TextField("Search", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                            .onSubmit {
                                reloadMods()
                            }
                        
                        HStack {
                            Text("Minecraft version")
                            
                            Spacer()
                            
                            Picker("Minecraft version", selection: $version) {
                                Text("Any")
                                    .tag("")
                                
                                ForEach(vm.versionOptions, id: \.self) {
                                    Text($0)
                                        .tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                        
                        HStack {
                            Text("Mod loader")
                            
                            Spacer()
                            
                            Picker("Mod loader", selection: $modLoader) {
                                Text("Any")
                                    .tag("")
                                
                                ForEach(displayedModLoaders, id: \.self) {
                                    Text($0.capitalized)
                                        .tag($0)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }
                        
                        Button("Find mods", systemImage: "magnifyingglass", action: reloadMods)
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isLoadingMods)
                    }
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                BillingSectionCard("Results", showsBackground: false) {
                    if !vm.modManagerAvailable {
                        Text("Mod manager is unavailable")
                            .secondary()
                        
                    } else if vm.mods.isEmpty {
                        Text("No mods found")
                            .secondary()
                        
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.mods) { mod in
                                Button {
                                    selectedMod = mod
                                } label: {
                                    HStack(spacing: 12) {
                                        MinecraftCatalogIcon(
                                            mod.iconURL,
                                            placeholderSystemImage: "shippingbox.fill",
                                            size: 28,
                                            cornerRadius: 8
                                        )
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(mod.name)
                                                .subheadline(.semibold)
                                                .foregroundStyle(.foreground)
                                            
                                            Text(mod.description)
                                                .caption()
                                                .secondary()
                                                .lineLimit(2)

                                            MinecraftCatalogProjectStatsView(project: mod)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .secondary()
                                            .footnote()
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                                .minecraftProjectContextMenu(webPageURL: mod.webPageURL)
                            }
                            
                            if vm.modsPagination.totalPages > 1 {
                                MinecraftToolsPaginationView(
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
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                .animation(.default, value: vm.mods)
                .animation(.default, value: vm.isLoadingMods)
            }
            .padding()
        }
        .scrollIndicators(.never)
        .background(BackgroundImage())
    }
    
    private var displayedModLoaders: [String] {
        if vm.modLoaderOptions.isEmpty {
            return modLoaders
        }
        
        return vm.modLoaderOptions
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
        movePage: { _ in }
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
    .environmentObject(ValueStore())
}
