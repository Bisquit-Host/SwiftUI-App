import ScrechKit
import PteroNet

struct PanelDataTabView: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        DataTab(server)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PanelSettingsToolbarButton()
                }
            }
    }
}

