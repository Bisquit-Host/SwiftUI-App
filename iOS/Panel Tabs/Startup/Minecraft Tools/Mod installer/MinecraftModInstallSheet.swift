import SwiftUI

struct MinecraftModInstallSheet: View {
    @Environment(StartupVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    private let provider: MinecraftModProvider
    private let mod: MinecraftCatalogProject
    private let modLoader: String
    private let minecraftVersion: String
    
    init(
        provider: MinecraftModProvider,
        mod: MinecraftCatalogProject,
        modLoader: String,
        minecraftVersion: String
    ) {
        self.provider = provider
        self.mod = mod
        self.modLoader = modLoader
        self.minecraftVersion = minecraftVersion
    }
    
    @State private var selectedVersionId: String?
    @State private var isLoadingVersions = true
    @State private var askForInstall = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Install mod") {
                    VStack(alignment: .leading, spacing: 12) {
                        Text(mod.name)
                            .headline(.semibold)
                        
                        if isLoadingVersions {
                            HStack(spacing: 10) {
                                ProgressView()
                                Text("Loading versions")
                                    .secondary()
                            }
                        } else if vm.minecraftModVersions.isEmpty {
                            Text("No versions found")
                                .secondary()
                        } else {
                            Picker("Version", selection: $selectedVersionId) {
                                ForEach(vm.minecraftModVersions) { version in
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
                            .disabled(selectedVersionId == nil || vm.isInstallingMinecraftMod)
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle(mod.name)
        .alert("Install selected version", isPresented: $askForInstall) {
            Button("Install", role: .destructive) {
                install()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Install this mod now")
        }
    }
    
    private func loadVersions() async {
        isLoadingVersions = true
        
        await vm.fetchMinecraftModVersions(
            provider: provider,
            modId: mod.id,
            modLoader: modLoader,
            minecraftVersion: minecraftVersion
        )
        
        selectedVersionId = vm.minecraftModVersions.first?.id
        isLoadingVersions = false
    }
    
    private func install() {
        guard let selectedVersionId else {
            return
        }
        
        Task {
            let installed = await vm.installMinecraftMod(
                provider: provider,
                modId: mod.id,
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
    MinecraftModInstallSheet(
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
        minecraftVersion: ""
    )
    .darkSchemePreferred()
    .environment(StartupVM(""))
}
