import ScrechKit
import PteroNet

struct SftpDetails: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    private let sftp: ServerSftpDetails
    private let sftpAddress: String
    
    init(_ sftp: ServerSftpDetails) {
        self.sftp = sftp
        sftpAddress = "\(sftp.ip):\(sftp.port)"
    }
    
    var body: some View {
        Group {
            Button {
                copy(sftpAddress)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Server address")
                        
                        Text(sftpAddress)
                            .secondary()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "doc.on.doc")
                        .secondary()
                }
            }
            
            Button {
                copy(vm.username)
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Username")
                        
                        Text(vm.username)
                            .secondary()
                    }
                    
                    Spacer()
                    
                    Image(systemName: "doc.on.doc")
                        .secondary()
                }
            }
        }
        .foregroundStyle(.primary)
        .frame(maxWidth: 500)
    }
    
    private func copy(_ string: String) {
        Pasteboard.copy(string)
        SystemAlert.copied()
    }
}

#Preview {
    List {
        SftpDetails(PreviewProp.serverAttributes.sftp)
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
