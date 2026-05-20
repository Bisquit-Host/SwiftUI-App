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
                PterodactylSettings()
                
            case .toBillingDashboard:
                Dashboard()
#endif
                
#if !os(macOS)
            case .toServerList:
                ServerList()
                
            case .toServerListParent:
                ServerListParent()
#endif
                
#if os(visionOS)
            case .toPanel(let server):
                PanelView(server)
#elseif !os(macOS)
            case .toPanel(let id):
                PanelView(id)
#endif
                
#if !os(visionOS)
            case .toFileManager(let id, let root):
                FileTab(id, at: root)
#endif
                
#if os(watchOS)
            case .toSettings:
                PterodactylSettings()
#endif
            }
        }
    }
}
