import PteroNet

final class PreviewProp {
    static let serverAttributes = ServerAttributes(
        id: "87c8b6a2",
        name: "Preview",
        uuid: "1234567890",
        node: "Vision",
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
            ip: "1.23.456.78",
            port: 1889
        ),
        isSuspended: false,
        serverOwner: true,
        relationships: .init(
            allocations: ServerAllocations(data: [])
        )
    )
}
