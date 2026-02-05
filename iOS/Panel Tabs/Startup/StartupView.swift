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
    @State private var sheetVersionChanger = false
    @State private var isLoadingInstalledVersion = true
    
    var body: some View {
        List {
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
            async let installedVersion: () = fetchInstalledVersion()
            
            _ = await (startupVariables, installedVersion)
        }
        .onChange(of: currentDockerImage) { _, newDockerImage in
            updateDockerImage(newDockerImage)
        }
        .task {
            await fetchInstalledVersion()
        }
        .sheet(isPresented: $sheetVersionChanger) {
            VersionChangerSheet(serverUUID: server.uuid)
                .environment(vm)
        }
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
    
    private func fetchInstalledVersion() async {
        isLoadingInstalledVersion = true
        vm.setVersionChangerServerId(server.uuid)
        await vm.fetchVersionChangerData()
        isLoadingInstalledVersion = false
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
}
