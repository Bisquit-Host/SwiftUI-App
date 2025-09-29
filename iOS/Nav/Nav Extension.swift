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
                SettingsView()
#endif
            case .toServerList:
#if os(macOS)
                Home()
#else
                ServerList()
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
