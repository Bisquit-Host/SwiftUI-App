import SwiftUI
import Calagopus
import SafariCover

struct PluginInstallSheet: View {
    @Environment(PluginInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    let provider: PluginProvider
    let plugin: MinecraftCatalogProject
    let pluginLoader: String
    let version: String
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var alertInstall = false
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            BillingSectionCard(showsBackground: false) {
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
                        ForEach(vm.pluginVersions) {
                            Text($0.name)
                                .tag(Optional($0.id))
                        }
                    }
                    
                    Button("Install", role: .confirm) {
                        alertInstall = true
                    }
                    .semibold()
                    .buttonStyle(.borderedProminent)
                    .buttonSizing(.flexible)
                    .buttonBorderShape(.roundedRectangle(radius: 12))
                    .disabled(selectedVersionId == nil || vm.isInstallingPlugin)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            
            if !plugin.description.isEmpty {
                MinecraftCatalogDescriptionSection(plugin)
            }
            
            MinecraftCatalogTimelineDetails(plugin)
            
            if provider == .modrinth {
                ModrinthProjectLinksSection(plugin)
            }
        }
        .navigationTitle(plugin.name)
        .toolbarTitleDisplayMode(.inlineLarge)
        .scenePadding()
        .scrollIndicators(.never)
        .safariCover($showSafari, url: pluginWebPageURL)
        .task {
            await loadVersions()
        }
        .alert("Install selected version", isPresented: $alertInstall) {
            Button("Install", role: .confirm, action: install)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Install this plugin now")
        }
        .toolbar {
            if hasPluginWebPageURL {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    Button("Open in browser", systemImage: "safari") {
                        showSafari = true
                    }
                    
                    ShareLink(item: pluginWebPageURL)
                }
            }
        }
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        
        await vm.fetchPluginVersions(
            provider: provider,
            pluginID: plugin.id,
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
            let installed = await vm.installPlugin(
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
