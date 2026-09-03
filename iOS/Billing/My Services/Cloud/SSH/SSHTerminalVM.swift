import SwiftUI
import SwiftTerm
import NIOCore

@Observable
final class SSHTerminalVM {
    var status = "Disconnected"
    private(set) var isConnected = false
    private(set) var isConnecting = false
    
    private let client = SSHClient()
    private weak var terminalView: TerminalView?
    private var shouldSuppressDisconnectErrors = false
    
    private let appendLog: (String) -> Void
    
    init(appendLog: @escaping (String) -> Void) {
        self.appendLog = appendLog
        
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
                guard let self else { return }
                let formatted = Self.formatError(error)
                self.appendLog("error: \(formatted)")

                guard self.shouldPresentErrors else {
                    self.appendLog("disconnect ignored error")
                    return
                }

                // Connection errors are presented by connectTapped with the
                // endpoint and a useful explanation instead of a raw NIO error
                guard !self.isConnecting else { return }

                Self.present(error)
            }
        }
    }
    
    func attach(terminalView: TerminalView) {
        self.terminalView = terminalView
        terminalView.terminalDelegate = self
    }
    
    func connectTapped(credentials: SSHCredentialsState) {
        guard !isConnecting else { return }

        let trimmedHost = credentials.host.trimmingCharacters(in: .whitespacesAndNewlines)
        let username = credentials.username.trimmingCharacters(in: .whitespacesAndNewlines)
        
        guard let portValue = Int(credentials.port), portValue > 0 else {
            SystemAlert.error("Invalid port")
            return
        }
        
        guard !trimmedHost.isEmpty else {
            SystemAlert.error("Host is required")
            return
        }
        
        guard !username.isEmpty else {
            SystemAlert.error("Username is required")
            return
        }
        
        let (cols, rows) = self.currentTerminalSizeFallback()
        var sanitizedCredentials = credentials
        sanitizedCredentials.host = trimmedHost
        sanitizedCredentials.port = String(portValue)
        sanitizedCredentials.username = username
        let info = SSHConnectionInfo(credentials: sanitizedCredentials)

        isConnecting = true

        Task {
            defer { isConnecting = false }

            do {
                shouldSuppressDisconnectErrors = false
                self.appendLog("connect requested: \(trimmedHost):\(portValue) user=\(username)")
                try await client.connect(info, initialCols: cols, initialRows: rows)
            } catch {
                let formatted = Self.formatError(error)
                guard shouldPresentErrors else {
                    appendLog("connect ignored error: \(formatted)")
                    return
                }
                
                appendLog("connect failed: \(formatted)")
                Self.presentConnectionError(error, host: trimmedHost, port: portValue)
            }
        }
    }
    
    func disconnectTapped() {
        disconnect(suppressErrors: true, logMessage: "disconnect requested")
    }
    
    func closeConsole() {
        disconnect(suppressErrors: true, logMessage: "close requested")
    }
    
    private func disconnect(suppressErrors: Bool, logMessage: String) {
        Task {
            if suppressErrors {
                shouldSuppressDisconnectErrors = true
            }
            
            do {
                self.appendLog(logMessage)
                try await client.disconnect()
            } catch {
                let formatted = Self.formatError(error)
                guard shouldPresentErrors else {
                    appendLog("disconnect ignored error: \(formatted)")
                    return
                }
                
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
    
    private var shouldPresentErrors: Bool {
        !shouldSuppressDisconnectErrors
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

    private static func presentConnectionError(_ error: Error, host: String, port: Int) {
        if let channelError = error as? ChannelError, case .connectTimeout = channelError {
            SystemAlert.error(
                "SSH connection timed out",
                subtitle: "\(host):\(port) did not respond. Check that the server is running and the SSH port is allowed by its firewall"
            )
            return
        }

        present(error)
    }

    private static func present(_ error: Error) {
        let description = error.localizedDescription
        SystemAlert.error(
            "SSH connection failed",
            subtitle: description.isEmpty ? String(reflecting: error) : description
        )
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
        UIPasteboard.general.string = text
    }
    
    func iTermContent(source: TerminalView, content: ArraySlice<UInt8>) {}
    
    func rangeChanged(source: TerminalView, startY: Int, endY: Int) {}
}
