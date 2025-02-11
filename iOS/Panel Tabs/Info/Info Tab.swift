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
                .frame(height: 25)
                .foregroundStyle(.foreground)
                .padding()
                .background(.ultraThinMaterial, in: .rect(cornerRadius: 16))
            
            InfoTabButtons(server)
        }
        .padding(5)
        .frame(maxWidth: 500)
        .toolbarBackground(.visible, for: .tabBar)
        .background(InfoTabBackground())
    }
}

#Preview {
    InfoTab(sampleJSON(.serverListAttributes))
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
