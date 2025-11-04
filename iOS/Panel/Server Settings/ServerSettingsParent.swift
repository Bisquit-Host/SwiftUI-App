import SwiftUI
import PteroNet

struct ServerSettingsParent: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        NavigationStack {
            ServerSettingsView(server)
        }
    }
}
