import AppIntents

struct ConfigurationAppIntent: WidgetConfigurationIntent {
    static let intentClassName = "ServerUsageIntent"
    
    static var title: LocalizedStringResource = "Configuration"
    static var description = IntentDescription("This is an example widget")
    
    @Parameter(title: "Server id", default: "")
    var serverId: String
}

struct StartServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Start Server"
    
    @Parameter(title: "Server id", default: "")
    var id: String
        
    init() {}
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        PteroNet.powerSignal(id, signal: .start)
        
        return .result()
    }
}

struct RestartServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Restart Server"
    
    @Parameter(title: "Server id", default: "")
    var id: String
        
    init() {}
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        PteroNet.powerSignal(id, signal: .restart)
        
        return .result()
    }
}

struct StopServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Stop Server"
    
    @Parameter(title: "Server id", default: "")
    var id: String
        
    init() {}
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        PteroNet.powerSignal(id, signal: .stop)
        
        return .result()
    }
}

struct KillServerIntent: AppIntent {
    static var title: LocalizedStringResource = "Kill Server"
    
    @Parameter(title: "Server id", default: "")
    var id: String
        
    init() {}
    
    init(id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        PteroNet.powerSignal(id, signal: .kill)
        
        return .result()
    }
}
