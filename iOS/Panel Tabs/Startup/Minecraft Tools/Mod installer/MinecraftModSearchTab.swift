import SwiftUI
import Kingfisher

struct MinecraftModSearchTab: View {
    @Environment(MinecraftModInstallerVM.self) private var vm
    
    @Binding var selectedProvider: MinecraftModProvider
    @Binding var searchQuery: String
    @Binding var minecraftVersion: String
    @Binding var modLoader: String
    @Binding var page: Int
    @Binding var selectedMod: MinecraftCatalogProject?
    
    let reloadMods: () -> Void
    let movePage: (Int) -> Void
    
    private let minecraftVersions = [
        "",
        "1.21.8", "1.21.7", "1.21.6", "1.21.5", "1.21.4", "1.21.3", "1.21.2", "1.21.1", "1.21",
        "1.20.6", "1.20.5", "1.20.4", "1.20.3", "1.20.2", "1.20.1", "1.20"
    ]
    
    private let modLoaders = [
        "",
        "fabric", "forge", "neoforge", "quilt"
    ]
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Search") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Provider", selection: $selectedProvider) {
                            ForEach(MinecraftModProvider.allCases) {
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
                            
                            Picker("Minecraft version", selection: $minecraftVersion) {
                                Text("Any")
                                    .tag("")
                                
                                ForEach(minecraftVersions.filter { !$0.isEmpty }, id: \.self) { version in
                                    Text(version)
                                        .tag(version)
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
                                
                                ForEach(modLoaders.filter { !$0.isEmpty }, id: \.self) { loader in
                                    Text(loader.capitalized)
                                        .tag(loader)
                                }
                            }
                            .pickerStyle(.menu)
                            .tint(.primary)
                        }

                        Button("Find mods", systemImage: "magnifyingglass", action: reloadMods)
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isLoadingMinecraftMods)
                    }
                }
                
                BillingSectionCard("Results") {
                    if vm.isLoadingMinecraftMods {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading mods")
                                .secondary()
                        }
                    } else if !vm.minecraftModManagerAvailable {
                        Text("Mod manager is unavailable")
                            .secondary()
                        
                    } else if vm.minecraftMods.isEmpty {
                        Text("No mods found")
                            .secondary()
                        
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.minecraftMods) { mod in
                                Button {
                                    selectedMod = mod
                                } label: {
                                    HStack(spacing: 12) {
                                        KFImage(mod.iconURL)
                                            .resizable()
                                            .placeholder {
                                                Image(systemName: "shippingbox.fill")
                                                    .secondary()
                                            }
                                            .scaledToFill()
                                            .frame(28)
                                            .clipShape(.rect(cornerRadius: 8))
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text(mod.name)
                                                .subheadline(.semibold)
                                                .foregroundStyle(.foreground)
                                            
                                            Text(mod.description)
                                                .caption()
                                                .secondary()
                                                .lineLimit(2)
                                        }
                                        
                                        Spacer()
                                        
                                        Image(systemName: "chevron.right")
                                            .secondary()
                                            .footnote()
                                    }
                                    .contentShape(.rect)
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if vm.minecraftModsPagination.totalPages > 1 {
                                MinecraftToolsPaginationView(
                                    currentPage: vm.minecraftModsPagination.currentPage,
                                    totalPages: vm.minecraftModsPagination.totalPages,
                                    isLoading: vm.isLoadingMinecraftMods,
                                    onPrevious: { movePage(-1) },
                                    onNext: { movePage(1) }
                                )
                            }
                        }
                    }
                }
                .animation(.default, value: vm.minecraftMods)
                .animation(.default, value: vm.isLoadingMinecraftMods)
            }
            .padding()
        }
        .scrollIndicators(.never)
    }
}

#Preview {
    MinecraftModSearchTab(
        selectedProvider: .constant(.modrinth),
        searchQuery: .constant(""),
        minecraftVersion: .constant(""),
        modLoader: .constant(""),
        page: .constant(1),
        selectedMod: .constant(nil),
        reloadMods: {},
        movePage: { _ in }
    )
    .darkSchemePreferred()
    .environment(MinecraftModInstallerVM(""))
}
