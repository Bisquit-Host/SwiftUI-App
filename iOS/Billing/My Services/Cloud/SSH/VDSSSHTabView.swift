import SwiftUI

struct VDSSSHTabView: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    @StateObject private var viewModel = SSHTerminalVM()
    
    @State private var host = ""
    @State private var port = "22"
    @State private var username = "root"
    @State private var password = ""
    @State private var showLogs = false
    
    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TextField("Host", text: $host)
                        .sshTextFielgStyle()
                    
                    TextField("Port", text: $port)
                        .sshTextFielgStyle()
                        .limitInputLength($port, length: 5)
                        .frame(width: 90)
                        .keyboardType(.numberPad)
                }
                
                HStack(spacing: 8) {
                    TextField("Username", text: $username)
                        .sshTextFielgStyle()
                    
                    SecureField("Password", text: $password)
                        .sshTextFielgStyle()
                }
                
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
                    TextEditor(text: $viewModel.logs)
                        .footnote()
                        .monospaced()
                        .frame(height: 160)
                        .disabled(true)
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
    
    private func hydrateFromServiceIfNeeded() {
        if host.isEmpty, let ip = vm.service?.ip, !ip.isEmpty {
            host = ip
        }
        
        if password.isEmpty, let servicePassword = vm.service?.password, !servicePassword.isEmpty {
            password = servicePassword
        }
    }
}
