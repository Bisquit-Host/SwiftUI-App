import PteroNet

final class PreviewProp {
    static let serverAttributes = ServerAttributes(
        id: "12345678",
        name: "Preview",
        uuid: "1234567890",
        node: "preview",
        description: "Preview server description",
        dockerImage: "",
        limits: .init(
            memory: 10,
            cpu: 10,
            disk: 10
        ),
        featureLimits: .init(
            backups: 5,
            databases: 5,
            allocations: 5
        ),
        sftp: .init(
            ip: "",
            port: 0
        ),
        isSuspended: false,
        relationships: .init(
            allocations: .init(data: [])
        )
    )
}
