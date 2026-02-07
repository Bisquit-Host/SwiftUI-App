import SwiftUI

struct MinecraftModpackInstallerSheet: View {
    @Environment(MinecraftModpackInstallerVM.self) private var vm
    
    private let serverIdentifier: String
    
    var showsDismissButton: Bool
    
    init(
        _ serverIdentifier: String,
        showsDismissButton: Bool = true
    ) {
        self.serverIdentifier = serverIdentifier
        self.showsDismissButton = showsDismissButton
    }
    
    @State private var selectedProvider: MinecraftModpackProvider = .modrinth
    @State private var searchQuery = ""
    @State private var page = 1
    @State private var selectedModpack: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Search") {
                    VStack(alignment: .leading, spacing: 12) {
                        Picker("Provider", selection: $selectedProvider) {
                            ForEach(MinecraftModpackProvider.allCases) {
                                Text($0.name)
                                    .tag($0)
                            }
                        }
                        .tint(.primary)
                        
                        TextField("Search", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .disabled(selectedProvider == .voidswrath)
                            .submitLabel(.search)
                            .onSubmit {
                                reloadModpacks()
                            }
                        
                        Button("Find modpacks", systemImage: "magnifyingglass", action: reloadModpacks)
                            .buttonStyle(.borderedProminent)
                            .disabled(vm.isLoadingMinecraftModpacks)
                    }
                }
                
                if !vm.installedMinecraftModpacks.isEmpty {
                    BillingSectionCard("Most recently installed modpacks") {
                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(Array(vm.installedMinecraftModpacks.prefix(5)), id: \.id) { modpack in
                                HStack(alignment: .top, spacing: 10) {
                                    MinecraftCatalogIcon(
                                        modpack.iconURL,
                                        placeholderSystemImage: "square.stack.3d.up.fill",
                                        size: 28,
                                        cornerRadius: 8
                                    )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(modpack.name)
                                            .subheadline(.semibold)
                                        
                                        if !modpack.description.isEmpty {
                                            Text(modpack.description)
                                                .caption()
                                                .secondary()
                                                .lineLimit(2)
                                        }
                                        
                                        Text(modpack.provider)
                                            .caption()
                                            .secondary()
                                    }
                                }
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                
                BillingSectionCard("Results") {
                    if vm.isLoadingMinecraftModpacks {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading modpacks")
                                .secondary()
                        }
                    } else if !vm.minecraftModpackInstallerAvailable {
                        Text("Modpack installer is unavailable")
                            .secondary()
                        
                    } else if vm.minecraftModpacks.isEmpty {
                        Text("No modpacks found")
                            .secondary()
                        
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.minecraftModpacks) { modpack in
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
                            
                            if vm.minecraftModpacksPagination.totalPages > 1 {
                                MinecraftToolsPaginationView(
                                    currentPage: vm.minecraftModpacksPagination.currentPage,
                                    totalPages: vm.minecraftModpacksPagination.totalPages,
                                    isLoading: vm.isLoadingMinecraftModpacks,
                                    onPrevious: { movePage(-1) },
                                    onNext: { movePage(1) }
                                )
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle("Modpack installer")
        .background(BackgroundImage())
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
#if !os(visionOS)
            if showsDismissButton {
                ToolbarSpacer(.flexible, placement: .bottomBar)
            }
#endif
        }
        .task {
            guard hasLoaded == false else { return }
            
            hasLoaded = true
            vm.setServerId(serverIdentifier)
            
            await loadModpacks()
        }
        .onChange(of: selectedProvider) {
            reloadModpacks()
        }
        .sheet(item: $selectedModpack) { modpack in
            NavigationStack {
                MinecraftModpackInstallSheet(provider: selectedProvider, modpack: modpack)
                    .environment(vm)
            }
        }
    }
    
    private func loadModpacks() async {
        await vm.fetchMinecraftModpacks(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery
        )
    }
    
    private func reloadModpacks() {
        page = 1
        
        Task {
            await loadModpacks()
        }
    }
    
    private func movePage(_ change: Int) {
        let nextPage = max(1, page + change)
        page = nextPage
        
        Task {
            await loadModpacks()
        }
    }
}

#Preview {
    MinecraftModpackInstallerSheet("")
        .darkSchemePreferred()
        .environment(MinecraftModpackInstallerVM(""))
}
