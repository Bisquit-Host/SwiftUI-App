import SwiftUI

struct VersionChangerSheet: View {
    @Environment(VersionChangerVM.self) private var vm
    
    private let serverUUID: String
    
    var showsDismissButton: Bool
    
    init(
        _ serverUUID: String,
        showsDismissButton: Bool = true
    ) {
        self.serverUUID = serverUUID
        self.showsDismissButton = showsDismissButton
    }
    
    @State private var hasLoadedVersionChangerData = false
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                VersionChangerTypeListSection()
            }
            .scenePadding(.horizontal)
        }
        .navigationTitle("Available versions")
        .scrollIndicators(.never)
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
            vm.setServerId(serverUUID)
            
            await vm.fetchVersionChangerData()
        }
    }
}

#Preview {
    VersionChangerSheet("")
        .darkSchemePreferred()
        .environment(VersionChangerVM(""))
}
