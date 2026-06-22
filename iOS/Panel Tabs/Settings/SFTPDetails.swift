import ScrechKit
import Calagopus

struct SFTPDetails: View {
    @Environment(ServerSettingsVM.self) private var vm
    
    private let sftpAddress: String
    
    init(_ server: CalagopusServer) {
        sftpAddress = "\(server.sftpHost):\(server.sftpPort)"
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
        SFTPDetails(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(ServerSettingsVM(""))
}
