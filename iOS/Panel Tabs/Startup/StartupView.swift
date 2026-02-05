import SwiftUI
import PteroNet

struct StartupView: View {
    @Environment(StartupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
        currentDockerImage = server.dockerImage
    }
    
    @State private var currentDockerImage: String
    @State private var selectedType = ""
    @State private var selectedVersion = ""
    @State private var selectedBuild: Int?
    @State private var showSnapshots = false
    @State private var deleteFiles = false
    @State private var acceptEula = true
    @State private var alertInstallVersion = false
    
    private var filteredVersions: [VersionChangerVersion] {
        vm.versionChangerVersions.filter {
            guard let type = $0.type else {
                return true
            }
            
            if type == .snapshot {
                return showSnapshots
            }
            
            return true
        }
    }
    
    private var selectedVersionObject: VersionChangerVersion? {
        vm.versionChangerVersions.first {
            $0.version == selectedVersion
        }
    }
    
    private var selectedBuildObject: VersionChangerBuild? {
        if let selectedBuild {
            return vm.versionChangerBuilds.first {
                $0.id == selectedBuild
            }
        }
        
        return selectedVersionObject?.latest
    }
    
    private var installButtonTitle: String {
        if let selectedBuildObject {
            return "Install Build \(selectedBuildObject.name)"
        }
        
        return "Install Version"
    }
    
    private var canInstallVersion: Bool {
        guard vm.versionChangerAvailable else {
            return false
        }
        
        guard !selectedType.isEmpty else {
            return false
        }
        
        guard !selectedVersion.isEmpty else {
            return false
        }
        
        guard selectedBuildObject != nil else {
            return false
        }
        
        return !vm.isInstallingVersionChanger
    }
    
    var body: some View {
        List {
            StartupCommand()
            
            Picker("Docker Image", selection: $currentDockerImage) {
                ForEach(vm.sortedDockerImages, id: \.key) { key, value in
                    Text(key)
                        .tag(value)
                }
            }
            
            Section("Version Changer") {
                if vm.isLoadingVersionChanger {
                    ProgressView()
                } else if !vm.versionChangerAvailable {
                    Text("Version changer addon is not available on this panel")
                        .foregroundStyle(.secondary)
                } else {
                    if let installed = vm.versionChangerInstalled,
                       let build = installed.build {
                        if let type = vm.installedVersionChangerType {
                            Label(type.name, systemImage: installed.isOutdated ? "arrow.trianglehead.clockwise" : "checkmark.circle")
                                .foregroundStyle(installed.isOutdated ? .yellow : .green)
                        }
                        
                        if let version = build.versionId ?? build.projectVersionId {
                            Text("Installed version: \(version)")
                        }
                        
                        if build.type.uppercased() != "VANILLA" {
                            Text("Installed build: \(build.name)")
                        }
                        
                        if installed.isOutdated, let latestBuild = installed.latest {
                            Text("Latest build: \(latestBuild.name)")
                                .foregroundStyle(.yellow)
                        }
                    } else {
                        Text("No installed Minecraft server version found")
                            .foregroundStyle(.secondary)
                    }
                    
                    Picker("Type", selection: $selectedType) {
                        Text("Select type")
                            .tag("")
                        
                        ForEach(vm.versionChangerTypes) { type in
                            Text(type.name)
                                .tag(type.identifier)
                        }
                    }
                    
                    if vm.versionChangerVersions.contains(where: { $0.type == .snapshot }) {
                        Toggle("Show snapshots", isOn: $showSnapshots)
                    }
                    
                    if !filteredVersions.isEmpty {
                        Picker("Version", selection: $selectedVersion) {
                            ForEach(filteredVersions) { version in
                                Text(version.version)
                                    .tag(version.version)
                            }
                        }
                    }
                    
                    if selectedType.uppercased() != "VANILLA", !vm.versionChangerBuilds.isEmpty {
                        Picker("Build", selection: $selectedBuild) {
                            ForEach(vm.versionChangerBuilds) { build in
                                let suffix = build.experimental ? " (experimental)" : ""
                                
                                Text("Build \(build.name)\(suffix)")
                                    .tag(Optional(build.id))
                            }
                        }
                    }
                    
                    Toggle("Wipe server files", isOn: $deleteFiles)
                        .foregroundStyle(deleteFiles ? .red : .primary)
                    
                    Toggle("Accept Minecraft EULA", isOn: $acceptEula)
                        .foregroundStyle(acceptEula ? .green : .primary)
                    
                    Button(installButtonTitle, role: .destructive) {
                        alertInstallVersion = true
                    }
                    .disabled(!canInstallVersion)
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
            vm.setVersionChangerServerId(server.uuid)
            await vm.fetchStartupVariables()
            await vm.fetchVersionChangerData()
        }
        .onChange(of: currentDockerImage) { _, newDockerImage in
            updateDockerImage(newDockerImage)
        }
        .onChange(of: selectedType) { _, newType in
            handleTypeChange(newType)
        }
        .onChange(of: selectedVersion) { _, newVersion in
            handleVersionChange(newVersion)
        }
        .onChange(of: showSnapshots) {
            selectFirstVersionIfNeeded()
        }
        .onChange(of: vm.versionChangerTypes) {
            selectInstalledTypeIfNeeded()
        }
        .onChange(of: vm.versionChangerInstalled) {
            selectInstalledTypeIfNeeded()
        }
        .alert("Install selected version", isPresented: $alertInstallVersion) {
            Button("Install", role: .destructive) {
                installVersion()
            }
            
            Button("Cancel", role: .cancel) {}
        } message: {
            if let selectedBuildObject {
                Text("Install build \(selectedBuildObject.name) now")
            } else {
                Text("Install selected version now")
            }
        }
        .task {
            vm.setVersionChangerServerId(server.uuid)
            await vm.fetchVersionChangerData()
            selectInstalledTypeIfNeeded()
        }
    }
    
    private func updateDockerImage(_ newImage: String) {
        Task {
            await vm.updateDockerImage(newImage)
        }
    }
    
    private func handleTypeChange(_ newType: String) {
        selectedVersion = ""
        selectedBuild = nil
        vm.clearVersionChangerSelection()
        
        guard !newType.isEmpty else {
            return
        }
        
        Task {
            await vm.fetchVersionChangerVersions(type: newType)
            selectFirstVersionIfNeeded()
        }
    }
    
    private func handleVersionChange(_ newVersion: String) {
        selectedBuild = nil
        
        guard !selectedType.isEmpty, !newVersion.isEmpty else {
            vm.clearVersionChangerBuildSelection()
            return
        }
        
        Task {
            await vm.fetchVersionChangerBuilds(type: selectedType, version: newVersion)
            selectedBuild = vm.versionChangerBuilds.first?.id
        }
    }
    
    private func selectInstalledTypeIfNeeded() {
        guard selectedType.isEmpty else {
            return
        }
        
        guard let type = vm.versionChangerInstalled?.build?.type else {
            return
        }
        
        guard vm.versionChangerTypes.contains(where: {
            $0.identifier.caseInsensitiveCompare(type) == .orderedSame
        }) else {
            return
        }
        
        selectedType = type.uppercased()
    }
    
    private func selectFirstVersionIfNeeded() {
        guard !selectedType.isEmpty else {
            return
        }
        
        let currentVersionExists = filteredVersions.contains(where: {
            $0.version == selectedVersion
        })
        
        guard currentVersionExists == false else {
            return
        }
        
        selectedVersion = filteredVersions.first?.version ?? ""
    }
    
    private func installVersion() {
        guard let selectedBuildObject else {
            return
        }
        
        Task {
            let installed = await vm.installVersionChangerBuild(
                selectedBuildObject.id,
                deleteFiles: deleteFiles,
                acceptEula: acceptEula
            )
            
            guard installed else {
                return
            }
            
            await vm.fetchVersionChangerData()
            
            if !selectedType.isEmpty {
                await vm.fetchVersionChangerVersions(type: selectedType)
            }
            
            if !selectedType.isEmpty, !selectedVersion.isEmpty {
                await vm.fetchVersionChangerBuilds(type: selectedType, version: selectedVersion)
                selectedBuild = vm.versionChangerBuilds.first?.id
            }
        }
    }
}

#Preview {
    StartupView(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(ServerSettingsVM(""))
        .environmentObject(ValueStore())
}
