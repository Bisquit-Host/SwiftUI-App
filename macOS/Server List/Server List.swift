import ScrechKit
import PteroNet

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    
    private let gradient = Gradient(colors: [Color(0x3b58a4), Color(0x855da6)])
    
    var body: some View {
        @Bindable var binding = vm
        
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                //                VStack(alignment: .leading) {
                ForEach(vm.filteredServers, id: \.id) { server in
                    ServerCard(server)
                }
                //                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical)
            
#if os(macOS)
            SettingsLink {
                HStack {
                    Image(systemName: "gear")
                    
                    Text("Settings")
                }
                .title2(.semibold)
                .padding(10)
            }
            .buttonStyle(.plain)
#endif
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

#Preview {
    ServerList()
        .padding()
        .environment(ServerListVM())
}
