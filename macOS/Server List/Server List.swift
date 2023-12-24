import ScrechKit
import PteroNet

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
        
    private let gradient = Gradient(colors: [Color(0x3b58a4), Color(0x855da6)])
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading) {
                ForEach(vm.servers, id: \.id) { server in
                    ServerCard(server)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical)
        }
#if os(macOS)
            .background {
                ZStack {
                    BackgroundBlur()
                    
                    Rectangle()
                        .fill(gradient)
                        .opacity(0.4)
                }
                .ignoresSafeArea()
            }
#endif
    }
}

//#Preview {
//    ServerList()
//        .padding()
//}
