import SwiftUI

extension View {
    func withNavDestinations() -> some View {
        self.navigationDestination(for: NavDestinations.self) {
            switch $0 {
            case .toGuide:
                Guide()
                
            case .toPanel(let server):
                PanelView(server)
            }
        }
    }
}
