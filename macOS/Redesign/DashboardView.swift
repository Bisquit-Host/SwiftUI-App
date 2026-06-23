import ScrechKit
import Calagopus

struct DashboardView: View {
    @Environment(ServerListVM.self) private var serverListVM
    
    private let serverId: String
    
    init(_ serverId: String) {
        self.serverId = serverId
    }
    
    var body: some View {
        if let server = serverListVM.servers.first(where: { $0.id == serverId }) {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    DashboardViewHeader(server)
                    
                    StatRows(server)
                    
                    //                HStack(alignment: .top, spacing: 20) {
                    FileSection(server.id)
                    //                }
                    
                    //                HStack(alignment: .top, spacing: 20) {
                    LogSection(server.id)
                    //                }
                }
                .padding(.horizontal, 24)
            }
            .navigationTitle("")
            .scrollIndicators(.never)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    SFButton("slider.horizontal.3") {
                        
                    }
                }
            }
        } else {
            ContentUnavailableView("Server unavailable", systemImage: "externaldrive")
        }
    }
}
