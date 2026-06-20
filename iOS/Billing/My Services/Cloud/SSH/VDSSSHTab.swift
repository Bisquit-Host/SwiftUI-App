import SwiftUI

struct VDSSSHTab: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @StateObject private var viewModel: SSHTerminalVM
    
    @Binding private var credentials: SSHCredentialsState
    @Binding private var logs: [String]
    @Binding private var sshStatus: String
    
    @State private var hasAutoConnected = false
    
    init(credentials: Binding<SSHCredentialsState>, logs: Binding<[String]>, sshStatus: Binding<String>) {
        _credentials = credentials
        _logs = logs
        _sshStatus = sshStatus
        
        let logWriter = Self.makeLogWriter(logs: logs)
        _viewModel = StateObject(wrappedValue: SSHTerminalVM(appendLog: logWriter))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            SSHTerminalView(viewModel: viewModel)
                .ignoresSafeArea(.keyboard)
        }
        .task {
            hydrateFromServiceIfNeeded()
            attemptAutoConnectIfPossible()
        }
        .onChange(of: vm.service?.ip) {
            hydrateFromServiceIfNeeded()
            attemptAutoConnectIfPossible()
        }
        .onChange(of: viewModel.status) { _, newStatus in
            sshStatus = newStatus
        }
        .onChange(of: vm.service?.password) {
            hydrateFromServiceIfNeeded()
            attemptAutoConnectIfPossible()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                if viewModel.isConnected {
                    Button("Disconnect", action: viewModel.disconnectTapped)
                }
            }
        }
        .onDisappear {
            viewModel.closeConsole()
            hasAutoConnected = false
        }
    }
    
    private static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        return formatter
    }()
    
    private static func makeLogWriter(logs: Binding<[String]>) -> (String) -> Void { { message in
            let timestamp = logFormatter.string(from: Date())
            
            let line = "[\(timestamp)] \(message)"
            logs.wrappedValue.append(line)
        }
    }
    
    private func hydrateFromServiceIfNeeded() {
        if credentials.host.isEmpty, let ip = vm.service?.ip, !ip.isEmpty {
            credentials.host = ip
        }
        
        if credentials.password.isEmpty, let servicePassword = vm.service?.password, !servicePassword.isEmpty {
            credentials.password = servicePassword
        }
    }
    
    private func attemptAutoConnectIfPossible() {
        guard !hasAutoConnected else { return }
        
        guard !viewModel.isConnected else {
            hasAutoConnected = true
            return
        }
        
        let trimmedHost = credentials.host.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedHost.isEmpty else { return }
        guard !credentials.username.isEmpty else { return }
        guard let portValue = Int(credentials.port), portValue > 0 else { return }
        
        hasAutoConnected = true
        var sanitizedCredentials = credentials
        sanitizedCredentials.host = trimmedHost
        sanitizedCredentials.port = String(portValue)
        viewModel.connectTapped(credentials: sanitizedCredentials)
    }
}
