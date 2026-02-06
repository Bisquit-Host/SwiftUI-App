import ScrechKit
import PteroNet

struct PanelInfoTabView: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        InfoTab(server)
            .toolbar {
                ToolbarItemGroup(placement: .topBarTrailing) {
                    PowerSwitchToolbar()
                    
#if canImport(ActivityKit)
                    InfoTabLiveActivity(server)
#endif
                    PanelSettingsToolbarButton()
                }
            }
    }
}

