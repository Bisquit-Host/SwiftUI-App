import ScrechKit
import PteroNet

struct PanelSubdomainsTabView: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        InfoTabSubdomains(server)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    PanelSettingsToolbarButton()
                }
            }
    }
}

