import ScrechKit
import Calagopus

struct SFTPDetails: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    private let server: CalagopusServer
    private let sftpAddress: String
    
    init(_ server: CalagopusServer) {
        self.server = server
        sftpAddress = "\(server.sftpHost):\(server.sftpPort)"
    }
    
    var body: some View {
        Group {
            SFTPDetailsRow("Server address", value: sftpAddress, copy: copy)
            SFTPDetailsRow("Username", value: sftpUsername, copy: copy)
            
            SFTPDetailsRow(
                "Password",
                value: vm.sftpPassword,
                displayValue: passwordDisplayValue,
                isLoading: vm.isLoadingSFTPPassword,
                copy: copy
            )
            
            ZStack {
                Button("Regenerate password", action: regeneratePassword)
                    .disabled(vm.isRegeneratingSFTPPassword)
                
                if vm.isRegeneratingSFTPPassword {
                    ProgressView()
                        .frame(maxWidth: .infinity, alignment: .trailing)
                }
            }
        }
        .foregroundStyle(.primary)
        .frame(maxWidth: 500)
    }
    
    private func regeneratePassword() {
        Task {
            await vm.regenerateSFTPPassword()
        }
    }
    
    private var sftpUsername: String? {
        guard !vm.username.isEmpty else {
            return nil
        }
        
        return "\(vm.username).\(server.uuidShort)"
    }
    
    private var passwordDisplayValue: String? {
        guard vm.sftpPassword?.isEmpty == false else {
            return nil
        }
        
        return "********"
    }
    
    private func copy(_ string: String) {
        Pasteboard.copy(string)
        SystemAlert.copied()
    }
}

#Preview {
    List {
        SFTPDetails(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
