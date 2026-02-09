import SwiftUI
import SafariCover

struct PluginInstallSheet: View {
    @Environment(PluginInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    private let provider: PluginProvider
    private let plugin: MinecraftCatalogProject
    private let pluginLoader: String
    private let version: String
    
    init(
        provider: PluginProvider,
        plugin: MinecraftCatalogProject,
        pluginLoader: String,
        version: String
    ) {
        self.provider = provider
        self.plugin = plugin
        self.pluginLoader = pluginLoader
        self.version = version
    }
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var askForInstall = false
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard(showsBackground: false) {
                    VStack(alignment: .leading, spacing: 12) {
                        if isLoadingVersions {
                            HStack(spacing: 10) {
                                ProgressView()
                                
                                Text("Loading versions")
                                    .secondary()
                            }
                        } else if vm.pluginVersions.isEmpty {
                            Text("No versions found")
                                .secondary()
                        } else {
                            Picker("Version", selection: $selectedVersionId) {
                                ForEach(vm.pluginVersions) { version in
                                    Text(version.name)
                                        .tag(Optional(version.id))
                                }
                            }
                            
                            Button("Install", role: .confirm) {
                                askForInstall = true
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedVersionId == nil || vm.isInstallingPlugin)
                        }
                    }
                }
                .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
                
                MinecraftCatalogDescriptionSectionView(plugin)
                MinecraftCatalogTimelineDetailsView(plugin)
                ModrinthProjectLinksSection(project: plugin, isEnabled: provider == .modrinth)
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle(plugin.name)
        .safariCover($showSafari, url: pluginWebPageURL)
        .task {
            await loadVersions()
        }
        .alert("Install selected version", isPresented: $askForInstall) {
            Button("Install", role: .destructive, action: install)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Install this plugin now")
        }
        .toolbar {
            if hasPluginWebPageURL {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Open in browser", systemImage: "safari") {
                        showSafari = true
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: pluginWebPageURL)
                }
            }
        }
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        
        await vm.fetchMinecraftPluginVersions(
            provider: provider,
            pluginId: plugin.id,
            pluginLoader: pluginLoader,
            version: version
        )
        
        selectedVersionId = vm.pluginVersions.first?.id
        isLoadingVersions = false
    }
    
    private var pluginWebPageURL: String {
        plugin.webPageURL ?? ""
    }
    
    private var hasPluginWebPageURL: Bool {
        plugin.webPageURL != nil
    }
    
    private func install() {
        guard let selectedVersionId else { return }
        
        Task {
            let installed = await vm.installMinecraftPlugin(
                provider: provider,
                pluginId: plugin.id,
                versionId: selectedVersionId
            )
            
            guard installed else { return }
            dismiss()
        }
    }
}

#Preview {
    PluginInstallSheet(
        provider: .modrinth,
        plugin: MinecraftCatalogProject(
            id: "1",
            name: "Preview",
            description: "Preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        ),
        pluginLoader: "",
        version: ""
    )
    .darkSchemePreferred()
    .environment(PluginInstallerVM(""))
    .environmentObject(ValueStore())
}
