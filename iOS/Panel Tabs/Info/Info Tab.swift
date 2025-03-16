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
                
                Image(.darkBackgroundInfo)
                //                Image(.defaultIcon)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 1.1)
                    .frame(maxHeight: 600)
                    .clipped()
                    .blur(radius: 55, opaque: true)
                    .offset(y: -30)
                    .blur(radius: 10)
                    .overlay(alignment: .top) {
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
                            .offset(y: -16)
                            
                            InfoTabCard(server)
#warning("Tip")
                            InfoTabAllocation(server)
                            
                            InfoTabButtons(server)
                        }
                        .padding(.horizontal, 10)
                        .frame(width: width)
                    }
                
                Image(.darkBackgroundInfo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width * 1.1)
                    .frame(maxHeight: 600)
                    .clipped()
                    .blur(radius: 55, opaque: true)
                    .offset(y: 60)
                    .blur(radius: 10)
                    .scaleEffect(x: 1, y: -1)
                
//                Text("А что вы делаете в моём холодильнике? Может вы хотите кушать?")
            }
        }
        .ignoresSafeArea()
        .toolbarBackground(.visible, for: .tabBar)
        .frame(maxWidth: 500)
//        .background {
//            Image(.darkBackgroundInfo)
//                .resizable()
//                .aspectRatio(contentMode: .fill)
//                .blur(radius: 100, opaque: true)
//        }
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
