import ScrechKit
import PteroNet

struct ServerListGrid: View {
    @EnvironmentObject private var settings: SettingsStorage
    
    private let servers: [ServerAttributes]
    
    init(_ servers: [ServerAttributes]) {
        self.servers = servers
    }
    
    var body: some View {
#if os(watchOS)
        LazyVStack {
            ForEach(servers, id: \.id) { server in
                ServerCardParent(server)
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
                ForEach(servers, id: \.id) { server in
                    ServerCardParent(server)
                }
            } else {
                ServerCardParent(
                    .init(
                        id: "12345678",
                        name: "Demo Server",
                        uuid: "",
                        node: "",
                        description: "",
                        dockerImage: "",
                        limits: .init(
                            memory: 0,
                            cpu: 0,
                            disk: 0
                        ),
                        featureLimits: .init(
                            backups: 0,
                            databases: 0,
                            allocations: 0
                        ),
                        sftp: .init(
                            ip: "",
                            port: 0
                        ),
                        isSuspended: false,
                        relationships: .init(
                            allocations: .init(
                                data: []
                            )
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
