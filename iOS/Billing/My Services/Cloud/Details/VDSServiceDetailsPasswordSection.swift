import SwiftUI

struct VDSServiceDetailsPasswordSection: View {
    @Environment(VDSServiceDetailsVM.self) private var vm
    
    private let service: CloudServiceDetails
    @Binding private var rootPassword: String
    
    init(_ service: CloudServiceDetails, rootPassword: Binding<String>) {
        self.service = service
        self._rootPassword = rootPassword
    }
    
    var body: some View {
        BillingSectionCard("Root password") {
            VStack(alignment: .leading, spacing: 8) {
                SecureField("New password", text: $rootPassword)
                
                Button("Update password") {
                    Task {
                        await vm.changePassword(rootPassword, serviceId: service.id)
                    }
                }
                .frame(maxWidth: .infinity)
                .buttonStyle(.borderedProminent)
                .disabled(vm.isPerformingAction || rootPassword.count < 8)
            }
        }
    }
}

