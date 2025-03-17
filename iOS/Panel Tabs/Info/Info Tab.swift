import ScrechKit
import PteroNet

struct InfoTab: View {
    @Environment(PanelVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    private let width = UIScreen.main.bounds.width
    private let image: ImageResource = .darkBackgroundInfo
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Image(image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipped()
                
                ZStack(alignment: .top) {
                    Image(image)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1.1)
                        .frame(height: 800)
                        .clipped()
                        .blur(radius: 55, opaque: true)
                        .offset(y: -30)
                        .blur(radius: 10)
                    
                    VStack(spacing: 10) {
                        InfoTabHeading(server)
                        
                        HStack {
#if canImport(ActivityKit)
                            InfoTabLAButton(server)
#endif
                            PowerSwitch()
                                .overlay {
                                    Circle()
                                        .stroke(.gray.opacity(0.25), lineWidth: 1)
                                }
                        }
                        
                        InfoTabCard(server)
                        
                        InfoTabAllocation(server)
                        
                        InfoTabButtons(server)
                    }
                    .padding(.horizontal, 10)
                    .frame(width: width)
                }
            }
        }
        .ignoresSafeArea()
        .toolbarBackground(.visible, for: .tabBar)
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
