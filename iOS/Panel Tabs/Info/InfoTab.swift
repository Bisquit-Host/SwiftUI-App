import SwiftUI
import Calagopus

struct InfoTab: View {
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                ResourceGraphSection(server)
                MapSection(server)
            }
            .toolbarScenePadding()
        }
        .scrollIndicators(.never)
        .toolbar {
            PanelToolbarItem(placement: .topBarTrailing) {
                InfoTabLiveActivity(server)
            }
            
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
            
            PanelToolbarItem(placement: .topBarTrailing) {
                PowerSwitchToolbar()
            }
        }
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
