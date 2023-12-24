import ScrechKit
import PteroNet

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    
    private let gradient = Gradient(colors: [Color(0x3b58a4), Color(0x855da6)])
    
    var body: some View {
        @Bindable var binding = vm
        
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                ForEach(vm.filteredServers, id: \.id) { server in
                    ServerCard(server)
                        .id(server.id)
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding(.vertical)
            
#if os(macOS)
            SettingsLink {
                Label("Settings", systemImage: "gear")
                    .title2(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(10)
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
