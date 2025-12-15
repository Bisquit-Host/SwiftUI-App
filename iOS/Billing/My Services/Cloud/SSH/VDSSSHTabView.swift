#if canImport(SwiftUI) && canImport(SwiftTerm) && canImport(NIOSSH)
import SwiftUI

struct VDSSSHTabView: View {
    @Environment(VDSServiceDetailsVM.self) private var vm

    @StateObject private var viewModel = SSHTerminalViewModel()

    @State private var host: String = ""
    @State private var port: String = "22"
    @State private var username: String = "root"
    @State private var password: String = ""
    @State private var showLogs = false

    var body: some View {
        VStack(spacing: 0) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    TextField("Host", text: $host)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    TextField("Port", text: $port)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 90)
#if canImport(UIKit)
                        .keyboardType(.numberPad)
#endif
                }

                HStack(spacing: 8) {
                    TextField("Username", text: $username)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)

                    SecureField("Password", text: $password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .textFieldStyle(.roundedBorder)
                }

                HStack(spacing: 12) {
                    if viewModel.isConnected {
                        Button("Disconnect") { viewModel.disconnectTapped() }
                    } else {
                        Button("Connect") {
                            viewModel.connectTapped(host: host, port: port, username: username, password: password)
                        }
                        .buttonStyle(.borderedProminent)
                    }

                    Text(viewModel.status)
                        .font(.callout)
                        .foregroundStyle(.secondary)

                    Spacer()
                }

                if let lastError = viewModel.lastError {
                    Text(lastError)
                        .font(.footnote)
                        .foregroundStyle(.red)
                }

                DisclosureGroup("Logs", isExpanded: $showLogs) {
                    TextEditor(text: $viewModel.logs)
                        .font(.system(.footnote, design: .monospaced))
                        .frame(height: 160)
                        .disabled(true)
                }
            }
            .padding()
            .background(.ultraThinMaterial)

            SSHTerminalView(viewModel: viewModel)
#if canImport(UIKit)
                .ignoresSafeArea(.keyboard)
#endif
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
#endif
