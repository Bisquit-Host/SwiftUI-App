nonisolated enum SSHState: Equatable, Sendable {
    case idle, connecting, connected, disconnected
}

nonisolated struct SSHCredentialsState: Equatable, Sendable {
    var host: String
    var port: String
    var username: String
    var password: String
    
    init() {
        host = ""
        port = "22"
        username = "root"
        password = ""
    }
    
    init(info: SSHConnectionInfo) {
        self = info.credentials
    }
}
