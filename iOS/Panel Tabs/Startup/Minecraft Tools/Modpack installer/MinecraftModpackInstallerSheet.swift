import SwiftUI
import Kingfisher

struct MinecraftModpackInstallerSheet: View {
    @Environment(StartupVM.self) private var vm
    
    private let serverIdentifier: String
    
    init(_ serverIdentifier: String) {
        self.serverIdentifier = serverIdentifier
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
                            ForEach(MinecraftModpackProvider.allCases) { provider in
                                Text(provider.name)
                                    .tag(provider)
                            }
                        }
                        
                        TextField("Search", text: $searchQuery)
                            .textFieldStyle(.roundedBorder)
                            .disabled(selectedProvider == .voidswrath)
                            .submitLabel(.search)
                            .onSubmit {
                                reloadModpacks()
                            }
                        
                        Button {
                            reloadModpacks()
                        } label: {
                            Label("Find modpacks", systemImage: "magnifyingglass")
                        }
                        .buttonStyle(.borderedProminent)
                        .disabled(vm.isLoadingMinecraftModpacks)
                    }
                }
                
                if let installedModpack = vm.installedMinecraftModpack {
                    BillingSectionCard("Most recently installed") {
                        VStack(alignment: .leading, spacing: 6) {
                            Text(installedModpack.name)
                                .subheadline(.semibold)
                            
                            if !installedModpack.description.isEmpty {
                                Text(installedModpack.description)
                                    .caption()
                                    .secondary()
                                    .lineLimit(3)
                            }
                            
                            Text(installedModpack.provider)
                                .caption()
                                .secondary()
                        }
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
                                        KFImage(modpack.iconURL)
                                            .resizable()
                                            .placeholder {
                                                Image(systemName: "square.stack.3d.up.fill")
                                                    .secondary()
                                            }
                                            .scaledToFill()
                                            .frame(width: 28, height: 28)
                                            .clipShape(.rect(cornerRadius: 8))
                                        
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
                                HStack {
                                    Text("Page \(vm.minecraftModpacksPagination.currentPage) of \(vm.minecraftModpacksPagination.totalPages)")
                                        .footnote()
                                        .secondary()
                                    
                                    Spacer()
                                    
                                    Button("Previous") {
                                        movePage(-1)
                                    }
                                    .disabled(page <= 1 || vm.isLoadingMinecraftModpacks)
                                    
                                    Button("Next") {
                                        movePage(1)
                                    }
                                    .disabled(page >= vm.minecraftModpacksPagination.totalPages || vm.isLoadingMinecraftModpacks)
                                }
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle("Modpack installer")
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
            await loadModpacks()
        }
        .onChange(of: selectedProvider) {
            reloadModpacks()
        }
        .sheet(item: $selectedModpack) { modpack in
            NavigationStack {
                MinecraftModpackInstallSheet(
                    provider: selectedProvider,
                    modpack: modpack
                )
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
        .environment(StartupVM(""))
}
