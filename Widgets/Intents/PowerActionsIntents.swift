import AppIntents

struct StartServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Start Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .start)
        
        return .result()
    }
}

struct RestartServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Restart Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .restart)
        
        return .result()
    }
}

struct StopServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Stop Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .stop)
        
        return .result()
    }
}

struct KillServerIntent: AppIntent {
    static let title: LocalizedStringResource = "Kill Server"
    
    @Parameter(title: "Server id", optionsProvider: ServerOptionsProvider())
    var id: String
    
    init() {}
    
    init(_ id: String) {
        self.id = id
    }
    
    func perform() async throws -> some IntentResult {
        await PteroNet.powerSignal(id, do: .kill)
        
        return .result()
    }
}
