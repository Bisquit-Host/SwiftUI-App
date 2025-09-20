import SwiftUI
import PteroNet

struct PanelSettingsParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        NavigationStack {
            PanelSettingsView(server)
        }
    }
}
