import SwiftUI
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
    
    // Toolbar
    var alertNewFolder = false
    var sheetSettings = false
    
    var searchRule = ""
    var fieldSearch = ""
    var showFormatting = false
    var cpuUsage = 0.0
    var ramUsage = 0.0
    var diskUsage = 0.0
    
    private(set) var server: ServerAttributes? = nil
    private(set) var serverState: ServerState = .unknown
    private(set) var uptime = 0
    private(set) var stateColor: Color = .primary
    
    var updateBackups: (() async -> Void)? = nil
    
    private var connection: WebSocketTaskConnection?
    private var delegate: WebsocketDelegate?
    
    var messages: [AttributedString] = []
    
    var searchedMessages: [AttributedString] {
        if searchRule.isEmpty {
            messages
        } else {
            messages.filter {
                $0.description
                    .localizedStandardContains(searchRule)
            }
        }
    }
    
    func fetchServerDetails() async {
        do {
            server = try await serverDetailsAPI(id)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    @MainActor
    func appendMessage(_ message: String) async {
        guard
            let jsonData = message.data(using: .utf8)
        else {
            return
        }
        
        do {
            let message = try JSONDecoder().decode(WebsocketMessage.self, from: jsonData)
            
            if let status = message.serverStatus {
                print("Server status:", status)
                
                var state: ServerState
                
                switch status {
                case "starting":
                    state = .starting
                    stateColor = .yellow
                    
                case "running":
                    state = .running
                    stateColor = .green
                    
                case "stopping":
                    state = .stopping
                    stateColor = .yellow
                    
                case "offline":
                    state = .offline
                    stateColor = .red
                    
                default:
                    state = .unknown
                    stateColor = .primary
                }
                
                serverState = state
                
            } else if let consoleOutput = message.consoleOutput {
                messages.append(
                    ANSIConverter.convertAnsiToAttributedString(
                        consoleOutput.replacing(">....", with: "")
                    )
                )
                
            } else if let stats = message.serverStats {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: stats, options: [])
                    
                    let decoder = JSONDecoder()
                    let stats = try decoder.decode(ServerStats.self, from: jsonData)
                    
                    uptime = stats.uptime
                    
                    withAnimation {
                        cpuUsage = stats.cpuAbsolute
                        ramUsage = stats.memoryBytes
                        diskUsage = stats.diskBytes / pow(1024, 2)
#if os(tvOS)
                        cpuValues.append(Value(id: cpuValues.count, value: cpuUsage))
                        ramValues.append(Value(id: ramValues.count, value: ramUsage))
#endif
                    }
                } catch {
                    print("Error converting dictionary to JSON Data or decoding JSON:", error)
                }
                
            } else if message.backupCompleted {
                await updateBackups?()
                
            } else if message.authSuccess {
                print("WebSocket authentication successful")
                
            } else if message.tokenExpiring {
                print("WebSocket token expiring soon")
                
                if let data = await consoleDetails() {
                    connectWebSocket(data)
                }
                
            } else if message.tokenExpired {
                if let data = await consoleDetails() {
                    connectWebSocket(data)
                }
            }
        } catch {
            networkCallError(#function, error)
        }
    }
    
    func changePower(_ signal: ServerSignal) async {
        await PteroNet.powerSignal(id, do: signal)
    }
    
    func consoleDetails() async -> ConsoleDetails? {
        do {
            return try await consoleDetailsAPI(id)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    func connectWebSocket(_ data: ConsoleDetails) {
        connection = WebSocketTaskConnection(data.socket, token: data.token)
        
        delegate = WebsocketDelegate { message in
            Task {
                await self.appendMessage(message)
            }
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
