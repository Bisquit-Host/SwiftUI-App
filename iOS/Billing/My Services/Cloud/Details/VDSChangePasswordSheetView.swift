import ScrechKit

struct VDSChangePasswordSheetView: View {
    @Environment(VDSServiceDetailsVM.self) private var serviceVM
    @Environment(\.dismiss) private var dismiss
    @State private var vm = VDSChangePasswordVM()
    @FocusState private var isPasswordFocused: Bool

    let serviceId: Int

    var body: some View {
        Form {
            Section {
                HStack {
                    Group {
                        if vm.isPasswordVisible {
                            TextField("New password", text: $vm.password)
                        } else {
                            SecureField("New password", text: $vm.password)
                        }
                    }
                    .textContentType(.newPassword)
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .focused($isPasswordFocused)

                    Button(
                        vm.isPasswordVisible ? "Hide password" : "Show password",
                        systemImage: vm.isPasswordVisible ? "eye.slash" : "eye"
                    ) {
                        vm.isPasswordVisible.toggle()
                    }
                    .labelStyle(.iconOnly)
                    .buttonStyle(.borderless)
                }

                Button("Generate random password", systemImage: "dice", action: vm.generatePassword)
            } footer: {
                Text("Use 8–32 characters")
            }
            .disabled(serviceVM.isPerformingAction)
        }
        .navigationTitle("Change password")
        .navigationBarTitleDisplayMode(.inline)
        .interactiveDismissDisabled(serviceVM.isPerformingAction)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                DismissButton()
                    .accessibilityLabel("Dismiss")
                    .disabled(serviceVM.isPerformingAction)
            }

            ToolbarItem(placement: .confirmationAction) {
                AsyncButton("Save", systemImage: "checkmark") {
                    isPasswordFocused = false

                    if await serviceVM.changePassword(vm.password, for: serviceId) {
                        dismiss()
                    }
                }
                .labelStyle(.iconOnly)
                .disabled(!vm.isValid || serviceVM.isPerformingAction)
            }
        }
    }
}
