import ScrechKit
import PteroNet

struct InfoTab: View {
    @Environment(PanelVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    @State private var selectedImage: UIImage? = nil
    private let width = UIScreen.main.bounds.width
    
    private var ip: String? {
        let allocation = server.relationships.allocations.data.map(\.attributes).filter {
            $0.isDefault
        }.first
        
        guard let allocation else {
            return nil
        }
        
        if let ipAlias = allocation.ipAlias {
            return ipAlias
        } else {
            return allocation.ip
        }
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                Image(uiImage: selectedImage ?? .darkBackgroundInfo)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: width, height: width)
                    .clipped()
                
                ZStack(alignment: .top) {
                    Image(uiImage: selectedImage ?? .darkBackgroundInfo)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: width * 1.1)
                        .frame(height: 1000)
                        .clipped()
                        .blur(radius: 55, opaque: true)
                        .offset(y: -30)
                        .blur(radius: 10)
                    
                    VStack(spacing: 10) {
                        InfoTabHeading(server)
                        
                        HStack {
#if canImport(ActivityKit)
                            InfoTabLA(server)
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
                        
                        MapSection(ip, node: server.node)
                    }
                    .padding(.horizontal, 10)
                    .frame(width: width)
                }
            }
        }
        .ignoresSafeArea()
        .toolbarBackground(.visible, for: .tabBar)
        .onAppear {
            if let fileName = UserDefaults.standard.string(forKey: "background_image_fileName"),
               let image = loadImageFromDisk(fileName) {
                selectedImage = image
            }
        }
    }
}

#Preview {
    InfoTab(PreviewProp.serverAttributes)
        .environment(PanelVM(""))
        .environmentObject(ValueStore())
}
