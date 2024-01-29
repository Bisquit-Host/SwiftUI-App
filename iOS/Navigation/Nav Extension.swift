import SwiftUI

extension View {
    func withNavDestinations() -> some View {
        self.navigationDestination(for: NavDestinations.self) { destination in
            switch destination {
            case .toAuth:
                AuthView()
                
                //#if os(watchOS)
                //            case .toServerList(let selectedServer):
                //                ServerList(selectedServer: selectedServer)
            case .toServerList:
#if os(macOS)
                Home()
#else
                ServerList()
#endif
            case .toPanel(let id):
                PanelView(id)
                
#if !os(visionOS)
            case .toFileManager(let id, let root):
                FileTab(id, root: root)
                
            case .toMap:
                MapView()
#endif
                
#if os(watchOS)
            case .toSettings:
                AppSettings()
#endif
            }
        }
    }
}
