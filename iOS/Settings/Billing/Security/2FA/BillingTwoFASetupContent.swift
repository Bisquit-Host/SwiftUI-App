import ScrechKit
import BisquitoNet

struct BillingTwoFASetupContent: View {
    @Environment(Billing2FAVM.self) private var vm
    @Environment(DashboardVM.self) private var dashboardVM
    @Environment(\.dismiss) private var dismiss
    @FocusState private var codeFocused: Bool
    @State private var copied = false
    @State private var isSubmitting = false

    private let setup: Billing2FASetupResponse

    init(_ setup: Billing2FASetupResponse) {
        self.setup = setup
    }

    var body: some View {
        @Bindable var vm = vm

        Form {
            Section {
                Billing2FASetupHeader()
            }

            Section {
                Button(copied ? "Secret copied" : "Copy 2FA secret",
                       systemImage: copied ? "checkmark" : "doc.on.doc") {
                    Pasteboard.copy(setup.secret)
                    copied = true
                }

                ApplePasswords2FAButton(
                    serviceName: "bisquit.host",
                    accountName: setup.accountName,
                    secret: setup.secret
                )

                DisclosureGroup("Show QR code") {
                    Billing2FASetupContentQRCode(setup)
                }
            } header: {
                Text("1. Save your setup key")
            }

            Section {
                TextField("Code", text: $vm.code)
                    .keyboardType(.numberPad)
                    .textContentType(.oneTimeCode)
                    .title2()
                    .monospacedDigit()
                    .focused($codeFocused)
                    .limitInputLength($vm.code, length: 6)
                    .accessibilityHint("Six-digit verification code")
            } header: {
                Text("2. Enter verification code")
            } footer: {
                Text("Enter the 6-digit code from your password manager")
            }
        }
        .safeAreaInset(edge: .bottom) {
            Button(action: enableTwoFA) {
                Group {
                    if isSubmitting || vm.isEnabling {
                        ProgressView()
                            .accessibilityLabel("Enabling 2FA")
                    } else {
                        Text("Enable 2FA")
                            .bold()
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
            }
#if os(visionOS)
            .buttonStyle(.borderedProminent)
#else
            .buttonStyle(.glassProminent)
#endif
            .tint(.green)
            .disabled(vm.code.trimmingCharacters(in: .whitespaces).count < 6 || isSubmitting || vm.isEnabling || vm.isLoading)
            .padding()
        }
    }

    private func enableTwoFA() {
        guard !isSubmitting else { return }
        codeFocused = false
        isSubmitting = true

        Task {
            defer { isSubmitting = false }
            let success = await vm.enable(code: vm.code.trimmingCharacters(in: .whitespaces))

            if success {
                if !vm.isMock {
                    await dashboardVM.fetchUserInfo()
                }
                dismiss()
            }
        }
    }
}
