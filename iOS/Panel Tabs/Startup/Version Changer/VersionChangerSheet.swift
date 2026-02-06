import SwiftUI

struct VersionChangerSheet: View {
    @Environment(StartupVM.self) private var vm
    
    private let serverUUID: String
    
    init(_ serverUUID: String) {
        self.serverUUID = serverUUID
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
            ToolbarItem(placement: .bottomBar) {
                DismissButton()
            }
#if !os(visionOS)
            ToolbarSpacer(.flexible, placement: .bottomBar)
#endif
        }
        .task {
            guard hasLoadedVersionChangerData == false else { return }
            
            hasLoadedVersionChangerData = true
            vm.setVersionChangerServerId(serverUUID)
            
            await vm.fetchVersionChangerData()
        }
    }
}

#Preview {
    VersionChangerSheet("")
        .darkSchemePreferred()
        .environment(StartupVM(""))
}
