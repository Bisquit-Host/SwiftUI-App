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
        self.viewModel = StateObject(wrappedValue: SSHTerminalVM(appendLog: appendLog))
    }
    
    @State private var showLogs = false
    
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
                    
                    Text(viewModel.status)
                        .callout()
                        .secondary()
                    
                    Spacer()
                }
                
                DisclosureGroup("Logs", isExpanded: $showLogs) {
                    ScrollView {
                        ForEach(viewModel.logs, id: \.self) {
                            Text($0)
                                .footnote()
                                .monospaced()
                        }
                    }
                    .frame(height: 160)
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
        .onChange(of: vm.service?.ip) { _, _ in
            hydrateFromServiceIfNeeded()
        }
        .onChange(of: vm.service?.password) { _, _ in
            hydrateFromServiceIfNeeded()
        }
        .onDisappear {
            if viewModel.isConnected {
                viewModel.disconnectTapped()
            }
        }
    }
    
    private func writeLogs(_ message: String) {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss.SSS"
        
        let timestamp = formatter.string(from: Date())
        
        let line = "[\(timestamp())] \(message)"
        logs.append(line)
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
