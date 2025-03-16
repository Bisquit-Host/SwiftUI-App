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
                        VStack(spacing: 5) {
                            Text(server.name)
                                .largeTitle(.bold)
                                .lineLimit(1)
                            
                            Group {
                                if server.description.isEmpty {
                                    Button("Add a description") {
                                        vm.sheetSettings = true
                                    }
                                } else {
                                    Text(server.description)
                                }
                            }
                            .title3(.semibold)
                            .secondary()
                            .lineLimit(1)
                            
                            Text("\(server.id) • \(server.node)")
                                .footnote()
                                .foregroundStyle(.tertiary)
                                .shadow(color: .black, radius: 5)
                                .onTapGesture {
                                    UIPasteboard.general.string = server.id
                                    SystemAlert.copied()
                                }
                        }
                        .rounded()
                        
                        HStack {
#if canImport(ActivityKit)
                            InfoTabLAButton(server)
                            
                            PowerSwitch()
#endif
                        }
                        
                        InfoTabCard(server)
                        
                        InfoTabAllocation(server)
                        
                        InfoTabButtons(server)
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
