import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        currentDockerImage = server.dockerImage
        _modInstallerVM = State(initialValue: MinecraftModInstallerVM(server.uuid))
        _pluginInstallerVM = State(initialValue: MinecraftPluginInstallerVM(server.uuid))
        _modpackInstallerVM = State(initialValue: MinecraftModpackInstallerVM(server.uuid))
    }
    
    @State private var currentDockerImage: String
    @State private var modInstallerVM: MinecraftModInstallerVM
    @State private var pluginInstallerVM: MinecraftPluginInstallerVM
    @State private var modpackInstallerVM: MinecraftModpackInstallerVM
    @State private var sheetVersionChanger = false
    @State private var sheetMinecraftModManager = false
    @State private var sheetMinecraftPluginManager = false
    @State private var sheetMinecraftModpackInstaller = false
    @State private var isLoadingInstalledVersion = true
    
    var body: some View {
        List {
            if isMinecraftServer {
                Section("Installed version") {
                    HStack(spacing: 12) {
                        VersionChangerTypeLogo(url: installedVersionIconURL, size: 40)
                        
                        VStack(alignment: .leading, spacing: 3) {
                            Text(installedVersionText)
                                .subheadline(.semibold)
                            
                            if isLoadingInstalledVersion {
                                ProgressView()
                                    .controlSize(.small)
                            } else {
                                Text(installedBuildNumberText)
                                    .caption()
                                    .secondary()
                                    .lineLimit(2)
                            }
                        }
                        
                        Spacer()
                        
                        Button("Change") {
                            sheetVersionChanger = true
                        }
                        .foregroundStyle(.foreground)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                StartupMinecraftToolsSection(
                    modVM: modInstallerVM,
                    pluginVM: pluginInstallerVM,
                    modpackVM: modpackInstallerVM,
                    showModManager: {
                        sheetMinecraftModManager = true
                    },
                    showPluginManager: {
                        sheetMinecraftPluginManager = true
                    },
                    showModpackInstaller: {
                        sheetMinecraftModpackInstaller = true
                    }
                )
            }
            
            StartupCommand()
            
            Picker("Docker Image", selection: $currentDockerImage) {
                ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                    Text(key)
                        .tag(value)
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
            
            ForEach(vm.startupVariables) {
                StartupCard(server, variable: $0)
                    .listRowBackground(Color.gray.opacity(0.2))
            }
        }
        .scrollIndicators(.never)
        .frame(maxWidth: 500)
        .background(BackgroundImage())
        .scrollContentBackground(.hidden)
        .refreshableTask {
            async let startupVariables: () = vm.fetchStartupVariables()
            
            if isMinecraftServer {
                async let installedVersion: () = fetchInstalledVersion()
                async let minecraftTools: () = fetchMinecraftToolsSummary()
                
                _ = await (startupVariables, installedVersion, minecraftTools)
            } else {
                _ = await startupVariables
            }
        }
        .onChange(of: currentDockerImage) { _, newDockerImage in
            updateDockerImage(newDockerImage)
        }
        .task {
            guard isMinecraftServer else {
                return
            }
            
            async let installedVersion: () = fetchInstalledVersion()
            async let minecraftTools: () = fetchMinecraftToolsSummary()
            
            _ = await (installedVersion, minecraftTools)
        }
        .sheet($sheetVersionChanger) {
            NavigationStack {
                VersionChangerSheet(server.uuid)
            }
        }
        .sheet($sheetMinecraftModManager) {
            NavigationStack {
                MinecraftModManagerSheet(server.uuid)
                    .environment(modInstallerVM)
            }
        }
        .sheet($sheetMinecraftPluginManager) {
            NavigationStack {
                MinecraftPluginManagerSheet(server.uuid)
                    .environment(pluginInstallerVM)
            }
        }
        .sheet($sheetMinecraftModpackInstaller) {
            NavigationStack {
                MinecraftModpackInstallerSheet(server.uuid)
                    .environment(modpackInstallerVM)
            }
        }
        .environment(vm)
        .environment(modInstallerVM)
        .environment(pluginInstallerVM)
        .environment(modpackInstallerVM)
    }
    
    private var installedVersionText: String {
        if !vm.versionChangerAvailable {
            return "Unavailable"
        }
        
        guard let build = vm.versionChangerInstalled?.build else {
            return "Not installed"
        }
        
        if let version = build.versionId ?? build.projectVersionId {
            return "\(build.type) \(version)"
        }
        
        return build.name
    }
    
    private var installedBuildNumberText: String {
        if !vm.versionChangerAvailable {
            return "Unavailable"
        }
        
        guard let buildNumber = vm.versionChangerInstalled?.build?.id else {
            return "Not installed"
        }
        
        return "#\(buildNumber)"
    }
    
    private var installedVersionIconURL: URL? {
        vm.installedVersionChangerType?.iconURL
    }
    
    private var isMinecraftServer: Bool {
        server.eggId == 34
    }
    
    private func fetchInstalledVersion() async {
        isLoadingInstalledVersion = true
        vm.setVersionChangerServerId(server.uuid)
        await vm.fetchVersionChangerData()
        isLoadingInstalledVersion = false
    }
    
    private func fetchMinecraftToolsSummary() async {
        modInstallerVM.setServerId(server.uuid)
        pluginInstallerVM.setServerId(server.uuid)
        modpackInstallerVM.setServerId(server.uuid)
        
        async let mods: () = modInstallerVM.fetchInstalledMinecraftMods()
        async let plugins: () = pluginInstallerVM.fetchInstalledMinecraftPlugins()
        
        async let modpacks: () = modpackInstallerVM.fetchMinecraftModpacks(
            provider: .modrinth,
            page: 1,
            pageSize: 50
        )
        
        _ = await (mods, plugins, modpacks)
    }
    
    private func updateDockerImage(_ newImage: String) {
        Task {
            await vm.updateDockerImage(newImage)
        }
    }
}

#Preview {
    StartupView(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(ServerSettingsVM(""))
        .environmentObject(ValueStore())
        .environment(MinecraftModInstallerVM(""))
        .environment(MinecraftPluginInstallerVM(""))
        .environment(MinecraftModpackInstallerVM(""))
}
