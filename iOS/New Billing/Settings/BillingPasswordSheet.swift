import SwiftUI

struct BillingPasswordSheet: View {
    @Environment(BillingSettingsVM.self) private var vm
    @Environment(\.dismiss) private var dismiss
    
    let hasPassword: Bool
    let onSuccess: () async -> Void
    
    var body: some View {
        @Bindable var vm = vm
        
        Form {
            if hasPassword {
                Section("Current") {
                    SecureField("Current password", text: $vm.currentPassword)
                        .textContentType(.password)
                }
            }
            
            Section("New password") {
                SecureField("New password", text: $vm.newPassword)
                    .textContentType(.newPassword)
                
                SecureField("Confirm new password", text: $vm.confirmPassword)
                    .textContentType(.newPassword)
            }
        }
        .navigationTitle(hasPassword ? "Change password" : "Set password")
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button(role: .cancel) {
                    vm.resetPasswordFields()
                    dismiss()
                } label: {
                    Image(systemName: "xmark")
                        .foregroundStyle(.red)
                }
            }
            
            ToolbarItem(placement: .confirmationAction) {
                Button {
                    Task {
                        await vm.changePassword(hasExistingPassword: hasPassword) {
                            await onSuccess()
                            dismiss()
                        }
                    }
                } label: {
                    if vm.isUpdatingPassword {
                        ProgressView()
                    } else {
                        Text("Save")
                    }
                }
                .disabled(vm.isUpdatingPassword)
            }
        }
    }
}
