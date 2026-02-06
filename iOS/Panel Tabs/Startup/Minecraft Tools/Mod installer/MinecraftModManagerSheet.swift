import SwiftUI
import Kingfisher

struct MinecraftModManagerSheet: View {
    @Environment(StartupVM.self) private var vm
    
    private let serverIdentifier: String
    
    init(serverIdentifier: String) {
        self.serverIdentifier = serverIdentifier
    }
    
    @State private var selectedProvider: MinecraftModProvider = .modrinth
    @State private var searchQuery = ""
    @State private var minecraftVersion = ""
    @State private var modLoader = ""
    @State private var page = 1
    @State private var selectedMod: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    BillingSectionCard("Search") {
                        VStack(alignment: .leading, spacing: 12) {
                            Picker("Provider", selection: $selectedProvider) {
                                ForEach(MinecraftModProvider.allCases) { provider in
                                    Text(provider.name)
                                        .tag(provider)
                                }
                            }
                            
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
                            
                            Button {
                                reloadMods()
                            } label: {
                                Label("Find mods", systemImage: "magnifyingglass")
                            }
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
                    
                    BillingSectionCard("Installed mods") {
                        if vm.installedMinecraftMods.isEmpty {
                            Text("No installed mods")
                                .secondary()
                        } else {
                            VStack(alignment: .leading, spacing: 8) {
                                ForEach(vm.installedMinecraftMods) { mod in
                                    HStack(spacing: 10) {
                                        KFImage(mod.iconURL)
                                            .resizable()
                                            .placeholder {
                                                Image(systemName: "shippingbox.fill")
                                                    .secondary()
                                            }
                                            .scaledToFill()
                                            .frame(width: 22, height: 22)
                                            .clipShape(.rect(cornerRadius: 6))
                                        
                                        Text(mod.projectName ?? mod.path)
                                            .subheadline()
                                            .lineLimit(2)
                                        
                                        Spacer()
                                        
                                        if canUpdate(mod) {
                                            Button("Update") {
                                                installModUpdate(mod)
                                            }
                                            .buttonStyle(.borderedProminent)
                                            .controlSize(.small)
                                            .tint(.yellow)
                                            .disabled(vm.isInstallingMinecraftMod)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                .padding()
            }
            .scrollIndicators(.never)
            .navigationTitle("Mod manager")
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
#if !os(visionOS)
                ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
            }
            .task {
                guard hasLoaded == false else {
                    return
                }
                
                hasLoaded = true
                vm.setMinecraftToolsServerId(serverIdentifier)
                await loadMods()
                await vm.fetchInstalledMinecraftMods()
            }
            .onChange(of: selectedProvider) {
                reloadMods()
            }
            .sheet(item: $selectedMod) { mod in
                NavigationStack {
                    MinecraftModInstallSheet(
                        provider: selectedProvider,
                        mod: mod,
                        modLoader: modLoader,
                        minecraftVersion: minecraftVersion
                    )
                    .environment(vm)
                }
            }
        }
    }
    
    private func loadMods() async {
        await vm.fetchMinecraftMods(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery,
            minecraftVersion: minecraftVersion,
            modLoader: modLoader
        )
    }
    
    private func reloadMods() {
        page = 1
        
        Task {
            await loadMods()
            await vm.fetchInstalledMinecraftMods()
        }
    }
    
    private func movePage(_ change: Int) {
        let nextPage = max(1, page + change)
        page = nextPage
        
        Task {
            await loadMods()
        }
    }
    
    private func canUpdate(_ mod: MinecraftInstalledProject) -> Bool {
        mod.update != nil
            && mod.projectId != nil
            && MinecraftModProvider(providerValue: mod.provider) != nil
    }
    
    private func installModUpdate(_ mod: MinecraftInstalledProject) {
        guard
            let update = mod.update,
            let projectId = mod.projectId,
            let provider = MinecraftModProvider(providerValue: mod.provider)
        else {
            return
        }
        
        Task {
            _ = await vm.installMinecraftMod(
                provider: provider,
                modId: projectId,
                versionId: update.id
            )
        }
    }
}

#Preview {
    MinecraftModManagerSheet(serverIdentifier: "")
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
