import SwiftUI
import Calagopus

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let id: String
    
    init(_ server: CalagopusServer) {
        self.id = server.id
    }
    
    var body: some View {
        ForEach(vm.backupGroups) { group in
            BackupGroupSectionView(serverID: id, group: group)
        }

        Section {
            ForEach(vm.ungroupedBackups) {
                BackupCard(id, $0)
                    .focusable()
            }
        } header: {
            if !vm.backupGroups.isEmpty {
                Text("No group")
            }
        }

        if !vm.systemBackups.isEmpty {
            Section {
                ForEach(vm.systemBackups) {
                    BackupCard(id, $0, isSystem: true)
                        .focusable()
                }
            } header: {
                Text("System backups")
            } footer: {
                Text("Backups taken automatically by the panel. They cannot be modified or deleted")
            }
        }
    }
}

#Preview {
    List {
        BackupList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
