import ScrechKit
import PteroNet

@Observable
final class PanelVM {
    private let id: String
    
    init(_ id: String) {
        self.id = id
    }
    
#if os(tvOS)
    var serverUsage = [0.0, 0, 0]
    var cpuValues: [Value] = []
    var ramValues: [Value] = []
    var diskValues: [Value] = []
#endif
    
    var searchRule = ""
    var fieldSearch = ""
    var showFormatting = false
    var sheetSettings = false
    var cpuUsage = 0.0
    var ramUsage = 0.0
    var diskUsage = 0.0
    private(set) var server: ServerAttributes? = nil
    private(set) var serverState: ServerState = .unknown
    private(set) var uptime = 0
    private(set) var stateColor: Color = .primary
    
    var updateBackups: (() -> Void)? = nil
    
    private var connection: WebSocketTaskConnection?
    private var delegate: MyWebSocketDelegate?
    
    var messages: [AttributedString] = []
    
    var searchedMessages: [AttributedString] {
        if searchRule.isEmpty {
            messages
        } else {
            messages.filter {
                $0.description
                    .lowercased()
                    .contains(searchRule.lowercased())
            }
        }
    }
    
    func fetchServerDetails() {
        serverDetailsAPI(id) { result in
            switch result {
            case .success(let model):
                if let model = model?.attributes {
                    self.server = model
                }
                
            case .failure(let error):
                SystemAlert.error(error)
            }
        }
    }
    
    func appendMessage(_ message: String) {
        main { [weak self] in
            if let jsonData = message.data(using: .utf8) {
                do {
                    let message = try JSONDecoder().decode(WebSocketMessage.self, from: jsonData)
                    
                    if let status = message.serverStatus {
                        print("Server status:", status)
                        
                        var state: ServerState
                        
                        switch status {
                        case "starting":
                            state = .starting
                            self?.stateColor = .yellow
                            
                        case "running":
                            state = .running
                            self?.stateColor = .green
                            
                        case "stopping":
                            state = .stopping
                            self?.stateColor = .yellow
                            
                        case "offline":
                            state = .offline
                            self?.stateColor = .red
                            
                        default:
                            state = .unknown
                            self?.stateColor = .primary
                        }
                        
                        self?.serverState = state
                        
                    } else if let consoleOutput = message.consoleOutput {
                        self?.messages
                            .append(convertAnsiToAttributedString(
                                consoleOutput
                                    .replacing(">....", with: "")
                            ))
                        
                    } else if let stats = message.serverStats {
                        do {
                            let jsonData = try JSONSerialization.data(withJSONObject: stats, options: [])
                            
                            let decoder = JSONDecoder()
                            let stats = try decoder.decode(ServerStats.self, from: jsonData)
                            
                            self?.uptime = stats.uptime
                            
                            withAnimation {
                                self?.cpuUsage = stats.cpuAbsolute
                                self?.ramUsage = stats.memoryBytes
                                self?.diskUsage = stats.diskBytes / pow(1024, 2)
#if os(tvOS)
                                self?.cpuValues.append(Value(id: self?.cpuValues.count ?? 0, value: self?.cpuUsage ?? 0))
                                self?.ramValues.append(Value(id: self?.ramValues.count ?? 0, value: self?.ramUsage ?? 0))
#endif
                            }
                        } catch {
                            print("Error converting dictionary to JSON Data or decoding JSON:", error)
                        }
                        
                    } else if message.backupCompleted != nil {
                        self!.updateBackups?()
                        
                    } else if message.authSuccess != nil {
                        print("WebSocket authentication successful")
                        
                    } else if message.tokenExpiring != nil {
                        print("WebSocket token expiring soon")
                        
                        self?.consoleDetails { data in
                            if let data {
                                self?.connectWebSocket(data)
                            }
                        }
                    } else if message.tokenExpired != nil {
                        self?.consoleDetails { data in
                            if let data {
                                self?.connectWebSocket(data)
                            }
                        }
                    }
                } catch {
                    networkCallError(#function, error)
                }
            }
        }
    }
    
    func changePower(_ signal: ServerSignal) {
        PteroNet.powerSignal(id, signal: signal)
    }
    
    func consoleDetails(completion: @escaping (ConsoleDetails?) -> Void) {
        consoleDetailsAPI(id) { result in
            switch result {
            case .success(let model):
                completion(model?.data)
                
            case .failure(let error):
                SystemAlert.error(error)
                completion(nil)
            }
        }
    }
    
    func connectWebSocket(_ data: ConsoleDetails) {
        connection = WebSocketTaskConnection(
            data.socket,
            token: data.token
        )
        
        delegate = MyWebSocketDelegate { [weak self] message in
            self?.appendMessage(message)
        }
        
        connection?.delegate = delegate
        connection?.connect()
    }
    
    func disconnectWebSocket() {
        connection?.disconnect()
        connection = nil
        delegate = nil
    }
}
