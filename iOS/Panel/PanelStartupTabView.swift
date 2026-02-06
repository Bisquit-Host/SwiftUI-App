import ScrechKit
import PteroNet

struct PanelStartupTabView: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        StartupView(server)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PanelSettingsToolbarButton()
                }
            }
    }
}

