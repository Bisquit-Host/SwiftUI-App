import SwiftUI
import Calagopus
import TipKit

struct InfoTab: View {
    private let server: CalagopusServer
    
    init(_ server: CalagopusServer) {
        self.server = server
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                TipView(TipSwipeSidebar())
                    .tipBackground(.ultraThinMaterial)
                
                ResourceGraphSection(server)
                MapSection(server)
            }
            .scenePadding(.horizontal)
        }
        .scrollIndicators(.never)
        .background(BackgroundImage())
        .toolbar {
#if canImport(ActivityKit)
            ToolbarItem(placement: .topBarTrailing) {
                InfoTabLiveActivity(server)
            }
            
            ToolbarSpacer(.fixed, placement: .topBarTrailing)
#endif
            ToolbarItem(placement: .topBarTrailing) {
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
