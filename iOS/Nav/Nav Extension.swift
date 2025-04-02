import SwiftUI

extension View {
    func withNavDestinations() -> some View {
        self.navigationDestination(for: NavDestinations.self) { destination in
            switch destination {
                //#if os(watchOS)
                //            case .toServerList(let selectedServer):
                //                ServerList(selectedServer: selectedServer)
            case .toServerList:
#if os(macOS)
                Home()
#else
                ServerList()
#endif
                
#if !os(macOS)
            case .toPanel(let id):
                PanelView(id)
#endif
                
#if !os(visionOS)
            case .toFileManager(let id, let root):
                FileTab(id, at: root)
                
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
