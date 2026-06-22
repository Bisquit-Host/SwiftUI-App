import Calagopus

final class PreviewProp {
    static let serverAttributes = CalagopusServer(
        uuid: UUID().uuidString,
        uuidShort: "a1b2c3d4",
        allocation: serverAllocation,
        egg: .init(
            uuid: UUID().uuidString,
            name: "Minecraft",
            description: nil,
            startupCommands: nil,
            separatePort: nil,
            features: nil,
            dockerImages: nil,
            created: Date()
        ),
        eggConfiguration: .init(
            allocationSelfAssignEnabled: true,
            allocationSelfAssignRequirePrimary: false,
            startupAllowCustomCommand: true,
            routeOrder: nil
        ),
        status: nil,
        isOwner: true,
        isSuspended: false,
        isTransferring: false,
        permissions: [],
        locationUuid: UUID().uuidString,
        locationName: "Frankfurt",
        locationFlag: nil,
        nodeUuid: UUID().uuidString,
        nodeName: "Vision",
        nodeMaintenanceEnabled: false,
        sftpHost: "1.23.456.78",
        sftpPort: 1889,
        name: "Preview",
        description: "Preview server description",
        limits: .init(
            cpu: 400,
            memory: 1_048_576,
            swap: 0,
            disk: 1024
        ),
        featureLimits: .init(
            allocations: 5,
            databases: 5,
            backups: 5,
            schedules: 5,
            subdomains: 5
        ),
        startup: "",
        image: "",
        autoKill: .init(enabled: false, seconds: 0),
        autoStartBehavior: .never,
        timezone: nil,
        created: Date()
    )
    
    static let userAttributes = CalagopusServerSubuser(
        user: .init(
            uuid: UUID().uuidString,
            username: "topscrech",
            avatar: "https://example.com/avatar.png",
            totpEnabled: false,
            created: Date()
        ),
        permissions: [
            "server.read", "server.write", "user.read"
        ],
        ignoredFiles: [],
        created: Date()
    )
    
    static let backupAttributes = CalagopusServerBackup(
        uuid: UUID().uuidString,
        name: "Initial Backup",
        ignoredFiles: [],
        isSuccessful: true,
        isLocked: false,
        isBrowsable: true,
        isStreaming: false,
        checksum: nil,
        bytes: 1_048_576,
        files: 12,
        metadata: .object([:]),
        completed: Date(),
        created: Date()
    )
    
    static let fileAttributes = CalagopusFileEntry(
        name: "README.md",
        mode: "0644",
        modeBits: "rw-r--r--",
        size: 2_048,
        sizePhysical: 2_048,
        editable: true,
        innerEditable: true,
        directory: false,
        file: true,
        symlink: false,
        mime: "text/markdown",
        created: Date(),
        modified: Date()
    )
    
    static let logAttributes = CalagopusServerLog(
        id: "log-0001",
        event: "server.install",
        timestamp: Date(),
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
                    username: userAttributes.user.username,
                    email: userAttributes.user.username,
                    image: userAttributes.user.avatar ?? ""
                )
            )
        )
    )
    
    static let databaseAttributes = CalagopusServerDatabase(
        uuid: "db-uuid-0001",
        type: "mysql",
        host: "127.0.0.1",
        port: 3306,
        name: "preview_db",
        isLocked: false,
        username: "preview_user",
        password: "preview_password",
        created: Date()
    )
    
    static let serverAllocation = CalagopusServerAllocation(
        uuid: UUID().uuidString,
        ip: "1.23.456.78",
        ipAlias: nil,
        port: 25565,
        notes: "Primary allocation for preview",
        isPrimary: true,
        created: Date()
    )
    
    static let apiKey = CalagopusAPIKey(
        id: "api-uuid-0001",
        name: "Preview API Key",
        lastUsedAt: "2024-02-01T08:00:00Z",
        createdAt: "2024-01-10T14:22:00Z"
    )
}
