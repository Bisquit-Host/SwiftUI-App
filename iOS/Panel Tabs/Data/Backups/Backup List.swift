import SwiftUI

struct BackupList: View {
    @Environment(BackupVM.self) private var vm
    
    private let id: String
    private let backupLimit: Int
    
    init(_ id: String, backupLimit: Int) {
        self.id = id
        self.backupLimit = backupLimit
    }
    
    var body: some View {
        @Bindable var vm = vm
        
        Section {
            ForEach(vm.backups, id: \.uuid) { backup in
                BackupCard(id, backup)
#if !os(tvOS)
                    .focusable() // Applies to DB's & schedules as well
#endif
            }
            .onDelete { offsets in
                vm.deleteBackups(offsets)
            }
            
            CreateBackupButton(backupLimit)
        } header: {
            SectionHeader("Backups", type: .backup(vm.backups.count, limit: backupLimit))
        }
        .environment(vm)
        .alert("Name Backup", isPresented: $vm.alertCreateBackup) {
            TextField("Backup at \(vm.dateAndTime)", text: $vm.textCreateBackup)
                .autocorrectionDisabled()
                .limitInputLength($vm.textCreateBackup, length: 191)
            
            Button("Cancel", role: .cancel) {}
            
            Button("Create") {
                vm.createBackup()
            }
        }
    }
}

#Preview {
    List {
        BackupList("", backupLimit: 4)
            .environment(BackupVM(""))
    }
}
