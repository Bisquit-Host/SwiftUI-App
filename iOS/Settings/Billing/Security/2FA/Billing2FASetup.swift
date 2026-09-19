import ScrechKit

struct Billing2FASetup: View {
    @Environment(Billing2FAVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        Group {
            if let setup = vm.setup, !vm.isLoading {
                BillingTwoFASetupContent(setup)
            } else {
                Form {
                    Section {
                        Billing2FASetupHeader()
                    }
                    
                    Section {
                        if vm.isLoading {
                            HStack {
                                ProgressView()
                                Text("Preparing setup…")
                            }
                        } else {
                            Text("Unable to start 2FA setup")
                                .secondary()
                            
                            BillingTwoFARetryButton()
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Cancel", systemImage: "xmark", role: .cancel) {
                    dismiss()
                }
                .labelStyle(.iconOnly)
                .tint(.red)
                .foregroundStyle(.red)
            }
        }
        .presentationDragIndicator(.visible)
        .task {
            await vm.fetchSetup()
        }
    }
}
