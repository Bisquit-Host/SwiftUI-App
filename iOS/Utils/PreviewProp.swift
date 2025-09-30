import PteroNet

final class PreviewProp {
    static let serverAttributes = ServerAttributes(
        id: "a1b2c3d4",
        name: "Preview",
        uuid: "1234567890",
        node: "Vision",
        description: "Preview server description",
        dockerImage: "",
        limits: .init(
            memory: pow(1024, 2),
            cpu: 400,
            disk: 1024
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
    
    static let userAttributes = UserAttributes(
        uuid: "user-uuid-1234",
        email: "preview@example.com",
        username: "topscrech",
        image: "https://example.com/avatar.png",
        createdAt: "2024-01-01T12:00:00Z",
        twoFaEnabled: false,
        permissions: [
            "server.read",
            "server.write",
            "user.read"
        ]
    )
    
    static let backupAttributes = BackupAttributes(
        uuid: "backup-uuid-0001",
        name: "Initial Backup",
        createdAt: "2024-01-15T10:00:00Z",
        completedAt: "2024-01-15T10:05:00Z",
        isLocked: false,
        bytes: 1_048_576
    )
    
    static let fileAttributes = FileAttributes(
        name: "README.md",
        size: 2_048,
        isFile: true,
        isSymlink: false,
        mimetype: "text/markdown",
        mode: "0644",
        modeBits: "rw-r--r--",
        createdAt: "2024-01-20T09:00:00Z",
        modifiedAt: "2024-01-20T09:30:00Z"
    )
    
    static let logAttributes = LogAttributes(
        id: "log-0001",
        event: "server.install",
        timestamp: "2024-01-25T12:34:56Z",
        properties: [
            "status": .string("completed"),
            "code": .int(200),
            "success": .bool(true),
            "tags": .array(["preview", "install"])
        ],
        description: "Server installation completed successfully",
        ip: "203.0.113.42",
        isApi: true,
        relationships: .init(
            actor: .init(
                attributes: .init(
                    username: userAttributes.username,
                    email: userAttributes.email,
                    image: userAttributes.image
                )
            )
        )
    )
    
    static let databaseAttributes = DatabaseAttributes(
        id: "db-uuid-0001",
        name: "preview_db",
        username: "preview_user",
        password: "preview_password",
        host: DatabaseHost(
            address: "127.0.0.1",
            port: 3306
        )
    )
    
    static let allocationAttributes = AllocationAttributes(
        id: 1,
        ip: "1.23.456.78",
        ipAlias: nil,
        port: 25565,
        isDefault: true,
        notes: "Primary allocation for preview"
    )
    
    static let apiKeyAttributes = ApiKeyAttributes(
        id: "api-uuid-0001",
        description: "Preview API Key",
        lastUsed: "2024-02-01T08:00:00Z",
        created: "2024-01-10T14:22:00Z"
    )
    
    static let apiKeyListData = ApiKeyListData(
        attributes: PreviewProp.apiKeyAttributes,
        meta: nil
    )
}
