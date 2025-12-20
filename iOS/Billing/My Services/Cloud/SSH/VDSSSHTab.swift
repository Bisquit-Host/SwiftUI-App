import SwiftUI

struct VDSSSHTab: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    @StateObject private var viewModel = SSHTerminalVM()
    
    @Binding private var host: String
    @Binding private var port: String
    @Binding private var username: String
    @Binding private var password: String
    
    init(host: Binding<String>, port: Binding<String>, username: Binding<String>, password: Binding<String>) {
        _host = host
        _port = port
        _username = username
        _password = password
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
    
    private func hydrateFromServiceIfNeeded() {
        if host.isEmpty, let ip = vm.service?.ip, !ip.isEmpty {
            host = ip
        }
        
        if password.isEmpty, let servicePassword = vm.service?.password, !servicePassword.isEmpty {
            password = servicePassword
        }
    }
}
