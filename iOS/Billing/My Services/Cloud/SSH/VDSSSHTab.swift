import SwiftUI

struct VDSSSHTab: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @StateObject private var viewModel: SSHTerminalVM
    
    @Binding private var host: String
    @Binding private var port: String
    @Binding private var username: String
    @Binding private var password: String
    @Binding private var logs: [String]
    
    init(host: Binding<String>, port: Binding<String>, username: Binding<String>, password: Binding<String>, logs: Binding<[String]>) {
        _host = host
        _port = port
        _username = username
        _password = password
        _logs = logs
        
        let logWriter = Self.makeLogWriter(logs: logs)
        _viewModel = StateObject(wrappedValue: SSHTerminalVM(appendLog: logWriter))
    }
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 12) {
                    if viewModel.isConnected {
                        Button("Disconnect", action: viewModel.disconnectTapped)
                    } else {
                        Button("Connect") {
                            viewModel.connectTapped(host: host, port: port, username: username, password: password)
                        }
                        .buttonStyle(.borderedProminent)
                    }
                    
                    Spacer()
                    
                    Text(viewModel.status)
                        .callout()
                        .secondary()
                }
            }
            .padding()
            .background(.ultraThinMaterial)
            
            SSHTerminalView(viewModel: viewModel)
                .ignoresSafeArea(.keyboard)
        }
        .task {
            hydrateFromServiceIfNeeded()
        }
        .onChange(of: vm.service?.ip) {
            hydrateFromServiceIfNeeded()
        }
        .onChange(of: vm.service?.password) {
            hydrateFromServiceIfNeeded()
        }
        .onDisappear {
            if viewModel.isConnected {
                viewModel.disconnectTapped()
            }
        }
    }
    
    private static let logFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        return formatter
    }()
    
    private static func makeLogWriter(logs: Binding<[String]>) -> (String) -> Void {
        { message in
            let timestamp = logFormatter.string(from: Date())
            
            let line = "[\(timestamp)] \(message)"
            logs.wrappedValue.append(line)
        }
    }
    
    private func hydrateFromServiceIfNeeded() {
        if host.isEmpty, let ip = vm.service?.ip, !ip.isEmpty {
            host = ip
        }
        
        if password.isEmpty, let servicePassword = vm.service?.password, !servicePassword.isEmpty {
            password = servicePassword
        }
    }
}
