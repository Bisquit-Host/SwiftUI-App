import SwiftUI
import Kingfisher

struct MinecraftModSearchTab: View {
    @Environment(StartupVM.self) private var vm
    
    @Binding var selectedProvider: MinecraftModProvider
    @Binding var searchQuery: String
    @Binding var minecraftVersion: String
    @Binding var modLoader: String
    @Binding var page: Int
    @Binding var selectedMod: MinecraftCatalogProject?
    
    let reloadMods: () -> Void
    let movePage: (Int) -> Void
    
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
                        
                        TextField("Search", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .submitLabel(.search)
                            .onSubmit {
                                reloadMods()
                            }
                        
                        TextField("Minecraft version (optional)", text: $minecraftVersion)
                            .textFieldStyle(.roundedBorder)
                        
                        TextField("Mod loader (optional)", text: $modLoader)
                            .textFieldStyle(.roundedBorder)
                        
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
                                            .frame(width: 28, height: 28)
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
                                HStack {
                                    Text("Page \(vm.minecraftModsPagination.currentPage) of \(vm.minecraftModsPagination.totalPages)")
                                        .footnote()
                                        .secondary()
                                    
                                    Spacer()
                                    
                                    Button("Previous") {
                                        movePage(-1)
                                    }
                                    .disabled(page <= 1 || vm.isLoadingMinecraftMods)
                                    
                                    Button("Next") {
                                        movePage(1)
                                    }
                                    .disabled(page >= vm.minecraftModsPagination.totalPages || vm.isLoadingMinecraftMods)
                                }
                            }
                        }
                    }
                }
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
    .environment(StartupVM(""))
}
