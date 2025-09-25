import ScrechKit
import PteroNet

struct ServerList: View {
    @Environment(ServerListVM.self) private var vm
    @Environment(UpdateChecker.self) private var updater
    
    @Environment(\.openURL) private var openUrl
    
    private let gradient = Gradient(colors: [
        Color(0x3b58a4),
        Color(0x855da6)
    ])
    
    private let link = "https://apps.apple.com/app/bisquit-host/id1639409934"
    
    var body: some View {
        VStack(alignment: .leading) {
            ScrollView(showsIndicators: false) {
                ForEach(vm.filteredServers) {
                    ServerCardOld($0)
                        .id($0.id)
                }
            }
            .maxFrame(.infinity)
            .padding(.vertical)
            
            if updater.alertUpdate {
                if let url = URL(string: link) {
                    Link(destination: url) {
                        HStack {
                            Image(systemName: "app.badge")
                                .symbolRenderingMode(.multicolor)
                            
                            Text("Update available")
                        }
                        .title2(.semibold)
                    }
                    .buttonStyle(.plain)
                    .padding(5)
                }
            }
            
            SettingsLink {
                Label("Settings", systemImage: "gear")
                    .title2(.semibold)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .buttonStyle(.plain)
            .padding(5)
        }
        .background {
            ZStack {
                BackgroundBlur()
                
                Rectangle()
                    .fill(gradient)
                    .opacity(0.4)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ServerList()
        .padding()
        .darkSchemePreferred()
        .environment(ServerListVM())
        .environment(UpdateChecker())
}
