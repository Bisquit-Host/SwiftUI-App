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
#if !os(macOS)
                ServerList()
#else
                Sidebar()
#endif
                
            case .toPanel(let id):
                PanelView(id)
#if !os(xrOS)
            case .toFileManager(let id, let path):
                FileTab(id, path: path)
                
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
