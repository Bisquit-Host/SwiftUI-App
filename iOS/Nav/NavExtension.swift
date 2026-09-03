import SwiftUI

extension View {
    func withNavDestinations() -> some View {
        self.navigationDestination(for: NavDestinations.self) {
            switch $0 {
                //#if os(watchOS)
                //            case .toServerList(let selectedServer):
                //                ServerList(selectedServer: selectedServer)
#if os(iOS)
            case .toSettings:
                CalagopusSettings()
                
            case .toBillingDashboard:
                Dashboard()
#endif
                
            case .toServerList:
                ServerList()
                
            case .toServerListParent:
                ServerListParent()
                
            case .toPanel(let id):
                PanelView(id)
                    .id(id)
                
#if !os(visionOS)
            case .toFileManager(let id, let root):
                FileTab(id, at: root)
#endif
                
#if os(watchOS)
            case .toSettings:
                CalagopusSettings()
#endif
            }
        }
    }
}
