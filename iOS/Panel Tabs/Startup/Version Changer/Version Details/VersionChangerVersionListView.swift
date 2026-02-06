import SwiftUI

struct VersionChangerVersionListView: View {
    @Environment(StartupVM.self) private var vm
    
    private let type: VersionChangerProviderType
    
    init(type: VersionChangerProviderType) {
        self.type = type
    }
    
    @State private var isLoading = true
    @State private var sheetInstallVersion: VersionChangerVersion?
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                BillingSectionCard("Versions") {
                    if isLoading {
                        HStack(spacing: 10) {
                            ProgressView()
                            Text("Loading versions")
                                .secondary()
                        }
                    } else if vm.versionChangerVersions.isEmpty {
                        Text("No versions available for this type")
                            .secondary()
                    } else {
                        VStack(alignment: .leading, spacing: 8) {
                            ForEach(vm.versionChangerVersions) { version in
                                Button {
                                    sheetInstallVersion = version
                                } label: {
                                    VersionChangerVersionCard(version)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }
                }
            }
            .padding()
        }
        .scrollIndicators(.never)
        .navigationTitle(type.name)
        .sheet(item: $sheetInstallVersion) { version in
            NavigationStack {
                VersionChangerBuildSheet(type: type, version: version)
                    .environment(vm)
            }
        }
        .task(id: type.identifier) {
            isLoading = true
            await vm.fetchVersionChangerVersions(type: type.identifier)
            isLoading = false
        }
    }
}

#Preview {
    NavigationStack {
        VersionChangerVersionListView(
            type: VersionChangerProviderType(
                category: "Preview",
                identifier: "PAPER",
                name: "Paper",
                icon: "",
                homepage: nil,
                description: "Preview",
                experimental: false,
                deprecated: false,
                builds: 100,
                versions: VersionChangerProviderVersions(minecraft: 20, project: 0)
            )
        )
    }
    .darkSchemePreferred()
    .environment(StartupVM(""))
}
