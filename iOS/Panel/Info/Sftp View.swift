import ScrechKit
import PteroNet

struct SftpView: View {
    private var vm = SftpVM()
    
    private var server: ServerListAttributes
    
    init(_ server: ServerListAttributes) {
        self.server = server
    }
    
    private var sftp_address: String {
        "\(server.sftp.ip):\(server.sftp.port)"
    }
    
    var body: some View {
        List {
            Button {
                UIPasteboard.general.string = sftp_address
                
                SystemAlert.copied()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Server address")
                        Text(sftp_address)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "doc.on.doc")
                        .title3()
                }
            }
            
            Button {
                UIPasteboard.general.string = vm.username
                
                SystemAlert.copied()
            } label: {
                HStack {
                    VStack(alignment: .leading) {
                        Text("Login")
                        Text(vm.username)
                    }
                    
                    Spacer()
                    
                    Image(systemName: "doc.on.doc")
                        .title3()
                }
            }
        }
        .presentationDetents([.medium])
        .foregroundStyle(.primary)
        .frame(maxWidth: 500)
        .task {
            vm.accountDetails()
        }
    }
}

#Preview {
    SftpView(
        sampleJSON(.serverListAttributes)
    )
}
