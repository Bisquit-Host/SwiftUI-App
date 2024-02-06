import SwiftUI
import PteroNet

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let server: ServerAttributes
    
    init(_ server: ServerAttributes) {
        self.server = server
    }
    
    var body: some View {
        List {
            ForEach(vm.backups, id: \.uuid) { backup in
                BackupCard(backup)
            }
            .onDelete(perform: vm.deleteBackups)
            
            Section {
                Button {
                    vm.createBackup()
                } label: {
                    Text("Create a new backup")
                }
            }
        }
    }
}

#Preview {
    BackupList(PreviewProperty.serverAttributes)
}
