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
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
                
                Text(key.createdAt)
            }
            .footnote()
        }
        .contextMenu {
            MenuButton("Copy", icon: "doc.on.doc") {
                Pasteboard.copy(key.publicKey)
            }
            
            ShareLink("Share...", item: key.publicKey)
            
            Section {
                MenuButton("Delete", role: .destructive, icon: "trash") {
                    Task {
                        await vm.deleteKey(key.fingerprint)
                    }
                }
            }
        }
    }
}

//#Preview {
//    SSHCard()
//        .environment(SSHVM())
//}
