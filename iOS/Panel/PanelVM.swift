import SwiftUI
import Calagopus
import ANSI

struct UsageSample: Identifiable, Equatable {
    let id: Int
    let timestamp: Date
    let value: Double
}

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
    var sheetSettings = false
    
    var searchRule = ""
    var fieldSearch = ""
    var showFormatting = false
    var cpuUsage = 0.0
    var ramUsage = 0.0
    var diskUsage = 0.0
    private var nextSampleId = 0
    private let historyLimit = 60
    private(set) var cpuHistory: [UsageSample] = []
    private(set) var ramHistory: [UsageSample] = []
    private(set) var diskHistory: [UsageSample] = []
    
    private(set) var server: CalagopusServer? = nil
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
                String(describing: $0).localizedStandardContains(searchRule)
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
    
    func changePower(_ signal: CalagopusServerPowerAction) async {
        await CalagopusNet.powerSignal(id, do: signal)
    }
    
    func fetchServerDetails() async {
        do {
            server = try await CalagopusNet.client().server(id: id)
        } catch {
            SystemAlert.error(error)
        }
    }
    
    func consoleDetails() async -> CalagopusWebSocketDetails? {
        do {
            return try await CalagopusNet.client().websocket(server: id)
        } catch {
            SystemAlert.error(error)
            return nil
        }
    }
    
    func connectWebSocket(_ data: CalagopusWebSocketDetails) {
        guard let url = URL(string: data.url) else {
            SystemAlert.error(CalagopusError.invalidURL(data.url))
            return
        }
        
        websocket.connect(to: url, token: data.token) {
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
                let cpu = doubleValue(stats["cpu_absolute"]) ?? 0
                let ram = doubleValue(stats["memory_bytes"]) ?? 0
                let disk = doubleValue(stats["disk_bytes"]) ?? 0
                let uptime = intValue(stats["uptime"]) ?? 0
                
                self.uptime = uptime
                
                let diskUsage = disk / pow(1024, 2)
                
                cpuUsage = cpu
                ramUsage = ram
                self.diskUsage = diskUsage
                
                appendUsageSamples(cpu: cpu, ram: ram, disk: diskUsage)
#if os(tvOS)
                cpuValues.append(Value(id: cpuValues.count, value: cpuUsage))
                ramValues.append(Value(id: ramValues.count, value: ramUsage))
#endif
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

private extension PanelVM {
    func doubleValue(_ value: Any?) -> Double? {
        if let value = value as? Double {
            return value
        }
        
        if let value = value as? Int {
            return Double(value)
        }
        
        if let value = value as? NSNumber {
            return value.doubleValue
        }
        
        if let value = value as? String {
            return Double(value)
        }
        
        return nil
    }
    
    func intValue(_ value: Any?) -> Int? {
        if let value = value as? Int {
            return value
        }
        
        if let value = value as? Double {
            return Int(value)
        }
        
        if let value = value as? NSNumber {
            return value.intValue
        }
        
        if let value = value as? String,
           let number = Double(value) {
            return Int(number)
        }
        
        return nil
    }
    
    func appendUsageSamples(cpu: Double, ram: Double, disk: Double) {
        let sample = UsageSample(id: nextSampleId, timestamp: Date(), value: cpu)
        let ramSample = UsageSample(id: sample.id, timestamp: sample.timestamp, value: ram)
        let diskSample = UsageSample(id: sample.id, timestamp: sample.timestamp, value: disk)
        
        nextSampleId += 1
        
        cpuHistory.append(sample)
        ramHistory.append(ramSample)
        diskHistory.append(diskSample)
        
        trimHistoryIfNeeded()
    }
    
    func trimHistoryIfNeeded() {
        if cpuHistory.count > historyLimit {
            cpuHistory.removeFirst(cpuHistory.count - historyLimit)
        }
        
        if ramHistory.count > historyLimit {
            ramHistory.removeFirst(ramHistory.count - historyLimit)
        }
        
        if diskHistory.count > historyLimit {
            diskHistory.removeFirst(diskHistory.count - historyLimit)
        }
    }
}
