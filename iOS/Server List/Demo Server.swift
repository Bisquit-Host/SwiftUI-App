import PteroNet

extension ServerListGrid {
    var demoServer: ServerAttributes {
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
                port: 228
            ),
            isSuspended: false,
            relationships: .init(
                allocations: .init(
                    data: []
                )
            )
        )
    }
}
