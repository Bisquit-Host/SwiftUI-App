nonisolated struct SSHConnectionInfo: Equatable, Sendable {
    let credentials: SSHCredentialsState
    
    var host: String { credentials.host }
    var port: Int { Int(credentials.port) ?? 0 }
    var username: String { credentials.username }
    var password: String { credentials.password }
    
    init(credentials: SSHCredentialsState) {
        self.credentials = credentials
    }
}
