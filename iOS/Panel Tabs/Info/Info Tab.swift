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
            
            HStack {
                Button {
                    
                } label: {
                    VStack {
                        Image(systemName: "list.bullet.rectangle.fill")
                            .foregroundStyle(.secondary)
                        
                        Text("Logs")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: .capsule)
                    .overlay(
                        Capsule()
                            .stroke(.gray.opacity(0.8), lineWidth: 0.5)
                    )
                    .foregroundStyle(.foreground)
                }
                
                Button {
                    
                } label: {
                    VStack {
                        Image(systemName: "person.3.fill")
                        
                        Text("Users")
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(.ultraThinMaterial, in: .capsule)
                    .foregroundStyle(.foreground)
                }
            }
            
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
