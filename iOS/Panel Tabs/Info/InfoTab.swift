import ScrechKit
import PteroNet

struct InfoTab: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                InfoTabResourceGraphs(server)
                MapSection(server)
            }
            .padding(.horizontal, 4)
        }
        .scrollIndicators(.never)
        .background(BackgroundImage())
        .toolbar {
            ToolbarItemGroup(placement: .topBarTrailing) {
                PowerSwitchToolbar()
                
#if canImport(ActivityKit)
                InfoTabLiveActivity(server)
#endif
            }
        }
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .darkSchemePreferred()
        .environment(PanelVM(""))
}
