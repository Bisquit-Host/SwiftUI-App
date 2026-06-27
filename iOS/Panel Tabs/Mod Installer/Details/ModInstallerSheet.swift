import SwiftUI
import Calagopus
import SafariCover

struct ModInstallerSheet: View {
    @Environment(ModInstallerVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject private var store: ValueStore
    
    let provider: ModManagerProvider
    let mod: MinecraftCatalogProject
    let modLoader: String
    let version: String
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var alertInstall = false
    @State private var showSafari = false
    
    var body: some View {
        ScrollView {
            BillingSectionCard(showsBackground: false) {
                VStack(alignment: .leading, spacing: 12) {
                    if isLoadingVersions {
                        HStack(spacing: 10) {
                            ProgressView()
                            
                            Text("Loading versions")
                                .secondary()
                        }
                    } else if vm.modVersions.isEmpty {
                        Text("No versions found")
                            .secondary()
                        
                    } else {
                        Picker("Version", selection: $selectedVersionId) {
                            ForEach(vm.modVersions) {
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
                        .disabled(selectedVersionId == nil || vm.isInstallingMod)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
            
            if !mod.description.isEmpty {
                MinecraftCatalogDescriptionSection(mod)
            }
            
            MinecraftCatalogTimelineDetails(mod)
            
            if provider == .modrinth {
                ModrinthProjectLinksSection(mod)
            }
        }
        .navigationTitle(mod.name)
        .scrollIndicators(.never)
        .scenePadding(.horizontal)
        .safariCover($showSafari, url: modWebPageURL)
        .task {
            await loadVersions()
        }
        .alert("Install selected version", isPresented: $alertInstall) {
            Button("Install", role: .confirm, action: install)
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Install this mod now")
        }
        .toolbar {
            if hasModWebPageURL {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Open in browser", systemImage: "safari") {
                        showSafari = true
                    }
                }
                
                ToolbarItem(placement: .topBarTrailing) {
                    ShareLink(item: modWebPageURL)
                }
            }
        }
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        
        await vm.fetchMinecraftModVersions(
            provider: provider,
            modId: mod.id,
            modLoader: modLoader,
            version: version
        )
        
        selectedVersionId = vm.modVersions.first?.id
        isLoadingVersions = false
    }
    
    private var modWebPageURL: String {
        mod.webPageURL ?? ""
    }
    
    private var hasModWebPageURL: Bool {
        mod.webPageURL != nil
    }
    
    private func install() {
        guard let selectedVersionId else { return }
        
        Task {
            let installed = await vm.installMinecraftMod(
                provider: provider,
                modId: mod.id,
                versionId: selectedVersionId
            )
            
            guard installed else { return }
            dismiss()
        }
    }
}

#Preview {
    ModInstallerSheet(
        provider: .modrinth,
        mod: MinecraftCatalogProject(
            id: "1",
            name: "Preview",
            description: "Preview",
            url: nil,
            iconURLString: nil,
            externalURL: nil
        ),
        modLoader: "",
        version: ""
    )
    .darkSchemePreferred()
    .environment(ModInstallerVM(""))
    .environmentObject(ValueStore())
}
