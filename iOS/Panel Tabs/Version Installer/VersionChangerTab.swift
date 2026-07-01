import SwiftUI

struct VersionChangerTab: View {
    @Environment(VersionChangerVM.self) private var vm
    
    private let serverUUID: String
    private let showsDismissButton: Bool
    
    init(_ serverUUID: String, showsDismissButton: Bool = true) {
        self.serverUUID = serverUUID
        self.showsDismissButton = showsDismissButton
    }
    
    @State private var hasLoadedVersionChangerData = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                VersionChangerInstalledSection()
                VersionChangerTypeListSection()
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .navigationTitle("Versions")
        .scenePadding(.horizontal)
        .environment(vm)
        .scrollIndicators(.never)
        .refreshable {
            await vm.fetchVersionChangerData()
        }
        .frame(maxWidth: .infinity)
        .background(BackgroundImage())
        .toolbar {
            if showsDismissButton {
                ToolbarItem(placement: .bottomBar) {
                    DismissButton()
                }
            }
#if !os(visionOS)
            if showsDismissButton {
                ToolbarSpacer(.flexible, placement: .bottomBar)
            }
#endif
        }
        .task {
            guard hasLoadedVersionChangerData == false else { return }
            
            hasLoadedVersionChangerData = true
            vm.setServerID(serverUUID)
            
            await vm.fetchVersionChangerData()
        }
    }
}

#Preview {
    VersionChangerTab("")
        .darkSchemePreferred()
        .environment(VersionChangerVM(""))
}
