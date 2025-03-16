import ScrechKit
import Kingfisher
import PteroNet

struct InfoTab: View {
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    private let width = UIScreen.main.bounds.width
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Image(.darkBackgroundInfo)
                //                Image(.defaultIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipped()
                
                ZStack(alignment: .top) {
                    Image(.darkBackgroundInfo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1.1)
                        .frame(maxHeight: 800)
                        .clipped()
                        .blur(radius: 55, opaque: true)
                        .offset(y: -30)
                        .blur(radius: 10)
                    
                    VStack(spacing: 10) {
                        VStack(spacing: 5) {
                            Text(server.name)
                                .largeTitle(.bold)
                                .lineLimit(1)
                            
                            Text(server.description)
                                .secondary()
                                .lineLimit(1)
                            
                            Text("\(server.id) • \(server.node)")
                                .caption2()
                                .foregroundStyle(.tertiary)
                        }
                        .rounded()
                        
                        InfoTabCard(server)
#warning("Tip")
                        InfoTabAllocation(server)
                        
                        InfoTabButtons(server)
                        
#if canImport(ActivityKit)
                        InfoTabLAButton(server)
#endif
                    }
                    .padding(.horizontal, 10)
                    .frame(width: width)
                }
                
                // Text("А что вы делаете в моём холодильнике? Может вы хотите кушать?")
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
