import SwiftUI

struct VersionChangerVersionListView: View {
    @Environment(VersionChangerVM.self) private var vm
    @EnvironmentObject private var store: ValueStore
    
    private let type: VersionChangerProviderType
    
    init(_ type: VersionChangerProviderType) {
        self.type = type
    }
    
    @State private var isLoading = true
    @State private var sheetInstallVersion: VersionChangerVersion?
    @State private var showsSnapshots = false
    
    var body: some View {
        ScrollView {
            BillingSectionCard("Versions", showsBackground: false) {
                if isLoading {
                    HStack(spacing: 10) {
                        ProgressView()
                        
                        Text("Loading versions")
                            .secondary()
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                } else if vm.versionChangerVersions.isEmpty {
                    Text("No versions available for this type")
                        .secondary()
                    
                } else {
                    if hasSnapshotVersions {
                        Toggle("Snapshots", isOn: $showsSnapshots)
                            .panelSearchField(showIcon: false)
                    }
                    
                    if visibleVersions.isEmpty {
                        Text("No release versions available")
                            .secondary()
                    } else {
                        ForEach(Array(visibleVersions.enumerated()), id: \.offset) { _, version in
                            Button {
                                sheetInstallVersion = version
                            } label: {
                                VersionChangerVersionCard(version)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .contentShape(.rect)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .backgroundStyling(store.panelSidebarBackgroundStyle, in: .rect(cornerRadius: 16))
        }
        .navigationTitle(type.name)
        .scenePadding(.horizontal)
        .scrollIndicators(.never)
        .refreshable {
            await refreshVersions(forceRefresh: true)
        }
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
        .sheet(item: $sheetInstallVersion) { version in
            NavigationStack {
                VersionChangerBuildSheet(type: type, version: version)
                    .environment(vm)
            }
        }
        .task(id: type.identifier) {
            await refreshVersions()
        }
    }
    
    private func refreshVersions(forceRefresh: Bool = false) async {
        isLoading = true
        
        let didFinish = await vm.fetchVersionChangerVersions(type: type.identifier, forceRefresh: forceRefresh)
        
        guard !Task.isCancelled else {
            return
        }
        
        isLoading = !didFinish && vm.versionChangerVersions.isEmpty
    }
    
    private var hasSnapshotVersions: Bool {
        vm.versionChangerVersions.contains {
            $0.type == .snapshot
        }
    }
    
    private var visibleVersions: [VersionChangerVersion] {
        guard hasSnapshotVersions, showsSnapshots == false else {
            return vm.versionChangerVersions
        }
        
        return vm.versionChangerVersions.filter {
            $0.type != .snapshot
        }
    }
}

#Preview {
    NavigationStack {
        VersionChangerVersionListView(
            VersionChangerProviderType(
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
    .environment(VersionChangerVM(""))
}
