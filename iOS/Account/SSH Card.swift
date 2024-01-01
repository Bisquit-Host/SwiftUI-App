import ScrechKit
import PteroNet

struct SSHCard: View {
    @Environment(SSHVM.self) private var vm
    
    private let key: SSHKey
    
    init(_ key: SSHKey) {
        self.key = key
    }
    
    var body: some View {
        HStack {
            Image(systemName: "lock.doc")
            
            VStack(alignment: .leading) {
                Text(key.name)
                
                Text(key.fingerprint)
                
                Text(key.createdAt.description)
            }
            .footnote()
        }
        .contextMenu {
            MenuButton("Copy", icon: "doc.on.doc") {
                UIPasteboard.general.string = key.publicKey
            }
            
            ShareLink("Share...", item: key.publicKey)
            
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    vm.deleteKey(key.fingerprint)
                }
            }
        }
    }
}

//#Preview {
//    SSHCard()
//}
