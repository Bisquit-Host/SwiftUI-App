import ScrechKit
import PteroNet

struct SftpDetails: View {
    @Environment(ServerSettingsVM.self) var vm
    
    private var sftp: ServerSftpDetails
    
    init(_ sftp: ServerSftpDetails) {
        self.sftp = sftp
    }
    
    private var sftpAddress: String {
        "\(sftp.ip):\(sftp.port)"
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
                        .title3()
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
                        .title3()
                }
            }
        }
        .foregroundStyle(.primary)
        .frame(maxWidth: 500)
    }
    
    private func copy(_ string: String) {
        UIPasteboard.general.string = string
        SystemAlert.copied()
    }
}

//#Preview {
//    SftpDetails(
//        sampleJSON(.serverListAttributes)
//    )
//}
