import ScrechKit
import PteroNet

struct ServerListGrid: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let servers: [ServerListData]
    
    init(_ servers: [ServerListData]) {
        self.servers = servers
    }
    
    var body: some View {
#if os(watchOS)
        LazyVStack {
            ForEach(servers, id: \.attributes.id) { server in
                ServerCardParent(server.attributes)
            }
        }
#else
        LazyVGrid(
            columns: [
                GridItem(
                    .adaptive(minimum: settings.designCode == 0 ? 170 : 360)
                )
            ],
            spacing: 8
        ) {
            if settings.isApiKeyValid {
                ForEach(servers, id: \.attributes.id) { server in
                    ServerCardParent(server.attributes)
                }
            } else {
                ServerCardParent(
                    .init(
                        id: "12345678",
                        name: "Demo Server",
                        uuid: "",
                        node: "",
                        description: "",
                        docker_image: "",
                        limits: ServerListLimits(
                            memory: 0,
                            cpu: 0,
                            disk: 0
                        ),
                        feature_limits: ServerListFeatureLimits(
                            backups: 0,
                            databases: 0
                        ),
                        sftp: ServerListSftpDetails(
                            ip: "",
                            port: 0
                        ),
                        is_suspended: false,
                        relationships: .init(
                            allocations: .init(data: [])
                        )
                    )
                )
            }
        }
#endif
    }
}

#Preview {
    ServerListGrid(
        sampleJSON(.serverListDataArray)
    )
    .environment(NavState())
    .environmentObject(SettingsStorage())
}
