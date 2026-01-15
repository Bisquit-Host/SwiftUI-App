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
    
    private let websocket = Websocket()
    
    var messages: [AttributedString] = []
    //#if DEBUG
    //    var rawMessages: [String] = []
    //#endif
    var searchedMessages: [AttributedString] {
        if searchRule.isEmpty {
            messages
        } else {
            messages.filter {
                $0.description.localizedStandardContains(searchRule)
            }
        }
    }
    
    //    func measure() {
    //        let start = Date()
    //
    //        for message in rawMessages {
    //            let _ = ANSIConverter.convertAnsiToAttributedString(message)
    //        }
    //
    //        let diff = Date().timeIntervalSince(start)
    //        Logger().info("Seconds to process: \(diff)")
    //    }
    
    func changePower(_ signal: ServerSignal) async {
        await PteroNet.powerSignal(id, do: signal)
    }
    
    func fetchServerDetails() async {
        do {
            server = try await serverDetailsAPI(id)
        } catch {
            SystemAlert.error(error)
        }
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
        websocket.connect(to: data.socket, token: data.token) {
            await self.appendMessage($0)
        } onError: {
            SystemAlert.error($0)
        }
    }
    
    func disconnectWebSocket() {
        websocket.disconnect()
    }
    
    func appendMessage(_ message: String) async {
        guard let jsonData = message.data(using: .utf8) else { return }
        
        do {
            let message = try BigAssDecoder.decode(WebsocketMessage.self, from: jsonData)
            
            if let status = message.serverStatus {
                Logger().info("Server status: \(status)")
                
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
                Logger().info("Console output: \(consoleOutput)")
                //#if DEBUG
                //                rawMessages.append(consoleOutput)
                //#endif
                let clearOutput = consoleOutput.replacing(">....", with: "")
                let attributedString = ANSIConverter.convertAnsiToAttributedString(clearOutput)
                
                messages.append(attributedString)
                
            } else if let stats = message.serverStats {
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: stats, options: [])
                    
                    let stats = try BigAssDecoder.decode(ServerStats.self, from: jsonData)
                    
                    uptime = stats.uptime
                    
                    withAnimation {
                        cpuUsage = stats.cpu
                        ramUsage = Double(stats.memory)
                        diskUsage = Double(stats.disk) / pow(1024, 2)
#if os(tvOS)
                        cpuValues.append(Value(id: cpuValues.count, value: cpuUsage))
                        ramValues.append(Value(id: ramValues.count, value: ramUsage))
#endif
                    }
                } catch {
                    Logger().info("Error converting dictionary to JSON Data or decoding JSON: \(error)")
                }
                
            } else if message.backupCompleted {
                await updateBackups?()
                
            } else if message.authSuccess {
                Logger().info("WebSocket authentication successful")
                
            } else if message.tokenExpiring {
                Logger().info("WebSocket token expiring soon")
                
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
}
