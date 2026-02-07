import SwiftUI
import SafariCover

struct MinecraftPluginInstallSheet: View {
    @Environment(MinecraftPluginInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let provider: MinecraftPluginProvider
    private let plugin: MinecraftCatalogProject
    private let pluginLoader: String
    private let minecraftVersion: String
    
    init(
        provider: MinecraftPluginProvider,
        plugin: MinecraftCatalogProject,
        pluginLoader: String,
        minecraftVersion: String
    ) {
        self.provider = provider
        self.plugin = plugin
        self.pluginLoader = pluginLoader
        self.minecraftVersion = minecraftVersion
    }
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var askForInstall = false
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Install plugin") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(plugin.name)
                            .headline(.semibold)

                        if plugin.webPageURL != nil {
                            Button {
                                showSafari = true
                            } label: {
                                Label("Open page", systemImage: "safari")
                            }
                            .buttonStyle(.bordered)
                        }
                        
                        if isLoadingVersions {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading versions")
                                    .secondary()
                            }
                        } else if vm.minecraftPluginVersions.isEmpty {
                            Text("No versions found")
                                .secondary()
                        } else {
                            Picker("Version", selection: $selectedVersionId) {
                                ForEach(vm.minecraftPluginVersions) { version in
                                    Text(version.name)
                                        .tag(Optional(version.id))
                                }
                            }
                            
                            Button(role: .destructive) {
                                askForInstall = true
                            } label: {
                                Label("Install selected version", systemImage: "square.and.arrow.down.fill")
                            }
                            .buttonStyle(.borderedProminent)
                            .disabled(selectedVersionId == nil || vm.isInstallingMinecraftPlugin)
                        }
                    }
                }
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
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        
        await vm.fetchMinecraftPluginVersions(
            provider: provider,
            pluginId: plugin.id,
            pluginLoader: pluginLoader,
            minecraftVersion: minecraftVersion
        )
        
        selectedVersionId = vm.minecraftPluginVersions.first?.id
        isLoadingVersions = false
    }

    private var pluginWebPageURL: String {
        plugin.webPageURL ?? ""
    }
    
    private func install() {
        guard let selectedVersionId else {
            return
        }
        
        Task {
            let installed = await vm.installMinecraftPlugin(
                provider: provider,
                pluginId: plugin.id,
                versionId: selectedVersionId
            )
            
            guard installed else {
                return
            }
            
            dismiss()
        }
    }
}

#Preview {
    MinecraftPluginInstallSheet(
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
        minecraftVersion: ""
    )
    .darkSchemePreferred()
    .environment(MinecraftPluginInstallerVM(""))
}
