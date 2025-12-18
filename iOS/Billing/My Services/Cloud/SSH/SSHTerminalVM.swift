#if canImport(NIOSSH) && canImport(SwiftTerm)
import SwiftUI
import Combine
import SwiftTerm

final class SSHTerminalVM: ObservableObject {
    @Published var status = "Disconnected"
    @Published var isConnected = false
    @Published var logs = ""
    
    private let client = SSHClient()
    private weak var terminalView: TerminalView?
    
    init() {
        client.onLog = { [weak self] message in
            Task { @MainActor in
                self?.appendLog(message)
            }
        }
        
        client.onOutput = { [weak self] bytes in
            Task { @MainActor in
                self?.terminalView?.feed(byteArray: bytes)
            }
        }
        
        client.onStateChange = { [weak self] state in
            Task { @MainActor in
                self?.apply(state: state)
            }
        }
        
        client.onError = { [weak self] error in
            Task { @MainActor in
                let formatted = Self.formatError(error)
                
                SystemAlert.error(formatted)
                self?.appendLog("error: \(formatted)")
            }
        }
    }
    
    func attach(terminalView: TerminalView) {
        self.terminalView = terminalView
        terminalView.terminalDelegate = self
    }
    
    func connectTapped(host: String, port: String, username: String, password: String) {
        guard let portValue = Int(port), portValue > 0 else {
            SystemAlert.error("Invalid port")
            return
        }
        
        let trimmedHost = host.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard !trimmedHost.isEmpty else {
            SystemAlert.error("Host is required")
            return
        }
        
        guard !username.isEmpty else {
            SystemAlert.error("Username is required")
            return
        }
        
        let (cols, rows) = self.currentTerminalSizeFallback()
        let info = SSHConnectionInfo(host: trimmedHost, port: portValue, username: username, password: password)
        
        Task {
            do {
                self.appendLog("connect requested: \(trimmedHost):\(portValue) user=\(username)")
                try await client.connect(info, initialCols: cols, initialRows: rows)
            } catch {
                let formatted = Self.formatError(error)
                SystemAlert.error(formatted)
                
                appendLog("connect failed: \(formatted)")
            }
        }
    }
    
    func disconnectTapped() {
        Task {
            do {
                self.appendLog("disconnect requested")
                try await client.disconnect()
            } catch {
                let formatted = Self.formatError(error)
                SystemAlert.error(formatted)
                
                appendLog("disconnect failed: \(formatted)")
            }
        }
    }
    
    private func currentTerminalSizeFallback() -> (cols: Int, rows: Int) {
        guard let terminalView else { return (80, 24) }
        let terminal = terminalView.getTerminal()
        
        return (max(terminal.cols, 20), max(terminal.rows, 5))
    }
    
    private func apply(state: SSHState) {
        switch state {
        case .idle, .disconnected:
            status = "Disconnected"
            isConnected = false
            
        case .connecting:
            status = "Connecting…"
            isConnected = false
            
        case .connected:
            status = "Connected"
            isConnected = true
        }
    }
    
    private func appendLog(_ message: String) {
        let line = "[\(Self.timestamp())] \(message)"
        
        if logs.isEmpty {
            logs = line
        } else {
            logs += "\n" + line
        }
    }
    
    private static func timestamp() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        return formatter.string(from: Date())
    }
    
    private static func formatError(_ error: Error) -> String {
        let ns = error as NSError
        var parts: [String] = []
        parts.append(String(reflecting: error))
        
        if !error.localizedDescription.isEmpty {
            parts.append(error.localizedDescription)
        }
        
        parts.append("NSError(domain: \(ns.domain), code: \(ns.code))")
        
        if !ns.userInfo.isEmpty {
            parts.append("userInfo: \(ns.userInfo)")
        }
        
        return parts.joined(separator: "\n")
    }
}

extension SSHTerminalVM: TerminalViewDelegate {
    func send(source: TerminalView, data: ArraySlice<UInt8>) {
        client.send(data)
    }
    
    func sizeChanged(source: TerminalView, newCols: Int, newRows: Int) {
        client.resize(cols: newCols, rows: newRows)
    }
    
    func setTerminalTitle(source: TerminalView, title: String) {}
    
    func hostCurrentDirectoryUpdate(source: TerminalView, directory: String?) {}
    
    func scrolled(source: TerminalView, position: Double) {}
    
    func requestOpenLink(source: TerminalView, link: String, params: [String : String]) {}
    
    func bell(source: TerminalView) {}
    
    func clipboardCopy(source: TerminalView, content: Data) {
        guard let text = String(data: content, encoding: .utf8) else { return }
        
#if canImport(UIKit)
        UIPasteboard.general.string = text
#elseif canImport(AppKit)
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
#endif
    }
    
    func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}
    
    func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}
}
#endif

