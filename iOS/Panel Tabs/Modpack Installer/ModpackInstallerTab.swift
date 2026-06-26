import SwiftUI
import Calagopus

struct ModpackInstallerTab: View {
    @Environment(ModpackInstallerVM.self) private var vm
    @EnvironmentObject private var valueStore: ValueStore
    
    private let serverIdentifier: String
    
    init(_ serverIdentifier: String) {
        self.serverIdentifier = serverIdentifier
    }
    
    @State private var selectedProvider: ModpackProvider = .modrinth
    @State private var searchQuery = ""
    @State private var page = 1
    @State private var selectedModpack: MinecraftCatalogProject?
    @State private var hasLoaded = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                ModpackInstallerSearchSection(
                    selectedProvider: $selectedProvider,
                    searchQuery: $searchQuery,
                    reloadModpacks: reloadModpacks
                )
                
                if !recentlyInstalledModpacks.isEmpty {
                    ModpackInstallerRecentSection(recentlyInstalledModpacks)
                }
                
                ModpackInstallerResultsSection(selectedModpack: $selectedModpack, movePage: movePage)
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle("Modpacks")
        .background(BackgroundImage())
        .refreshable {
            await loadModpacks(forceRefresh: true)
        }
        .task {
            guard hasLoaded == false else { return }
            hasLoaded = true
            
            if let storedProvider = ModpackProvider(rawValue: valueStore.panelModpackInstallerProvider) {
                selectedProvider = storedProvider
            }
            
            vm.setServerId(serverIdentifier)
            await loadModpacks()
        }
        .onChange(of: selectedProvider) { _, newProvider in
            valueStore.panelModpackInstallerProvider = newProvider.rawValue
            guard hasLoaded else { return }
            reloadModpacks()
        }
        .sheet(item: $selectedModpack) { modpack in
            NavigationStack {
                ModpackInstallSheet(provider: selectedProvider, modpack: modpack)
            }
        }
    }
    
    private var recentlyInstalledModpacks: [InstalledModpack] {
        Array(vm.installedModpacks.prefix(5))
    }
    
    private func loadModpacks(forceRefresh: Bool = false) async {
        await vm.fetchMinecraftModpacks(
            provider: selectedProvider,
            page: page,
            pageSize: 50,
            searchQuery: searchQuery,
            forceRefresh: forceRefresh
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
    ModpackInstallerTab("")
        .darkSchemePreferred()
        .environment(ModpackInstallerVM(""))
        .environmentObject(ValueStore())
}
