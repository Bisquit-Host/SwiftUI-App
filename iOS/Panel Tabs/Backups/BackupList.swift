import SwiftUI
import Calagopus

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let id: String
    private let backupLimit: Int
    
    init(_ server: ServerAttributes) {
        self.id = server.id
        self.backupLimit = server.featureLimits.backups
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.backups) {
                BackupCard(id, $0)
#if !os(tvOS)
                    .focusable() // Applies to DB's & schedules as well
#endif
            }
            .onDelete { indexSet in
                Task {
                    await vm.deleteBackups(indexSet)
                }
            }
        } header: {
            if !vm.backups.isEmpty {
                SectionHeader("Backups", type: .backup(vm.backups.count, limit: backupLimit))
            }
        }
        
        Section {
            CreateBackupButton(backupLimit)
        }
        .environment(vm)
    }
}

#Preview {
    List {
        BackupList(PreviewProp.serverAttributes)
    }
    .darkSchemePreferred()
    .environment(BackupVM(""))
}
