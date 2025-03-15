import ScrechKit
import Kingfisher
import PteroNet

struct InfoTab: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    private let gradient = Gradient(colors: [.green, .orange, .red])
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            InfoTabCard(server)
            
#warning("Tip")
            InfoTabAllocation(server)
            
            InfoTabButtons(server)
        }
        .padding(5)
        .frame(maxWidth: 500)
        .toolbarBackground(.visible, for: .tabBar)
        .background(InfoTabBackground())
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
